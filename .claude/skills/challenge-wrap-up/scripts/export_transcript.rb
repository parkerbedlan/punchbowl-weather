#!/usr/bin/env ruby
# frozen_string_literal: true

# Exports the Claude Code conversation(s) for a project directory to Markdown.
#
# Claude Code appends every session to a JSONL file under
# ~/.claude/projects/<munged-cwd>/<session-id>.jsonl. Reading those files is the
# only way to get a faithful transcript: the assistant's own context is
# compacted as a session grows, so anything it writes from memory is a
# paraphrase with turns missing.
#
# Sessions are located by matching the `cwd` recorded in each file rather than
# by reconstructing the directory-name mangling, so this keeps working if that
# scheme changes, and it will not confuse ~/project with ~/project-old.
#
# Ruby rather than Python because the challenge already requires Ruby, so it is
# guaranteed to be installed. Standard library only.
#
# Usage: ruby export_transcript.rb [options]

require 'json'
require 'optparse'
require 'time'

options = {
  out: 'AI-TRANSCRIPT.md',
  project: Dir.pwd,
  root: File.join(Dir.home, '.claude', 'projects'),
  truncate: 2000,
  thinking: false,
  subagents: false
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby export_transcript.rb [options]'

  opts.on('-o', '--out PATH', 'Output file (default: AI-TRANSCRIPT.md)') { |v| options[:out] = v }
  opts.on('-p', '--project PATH', 'Project directory (default: current directory)') { |v| options[:project] = v }
  opts.on('--root PATH', 'Claude projects directory') { |v| options[:root] = v }
  opts.on('-t', '--truncate N', Integer,
          'Truncate tool output to N characters, 0 for no limit (default: 2000)') { |v| options[:truncate] = v }
  opts.on('--thinking', 'Include the assistant\'s reasoning blocks') { options[:thinking] = true }
  opts.on('--subagents', 'Include messages from subagents') { options[:subagents] = true }
  opts.on('-h', '--help') { puts opts; exit }
end.parse!

PROJECT = File.expand_path(options[:project])

# The cwd of a session, taken from the first record that carries one. Reads
# lazily so a 100MB transcript costs a few lines rather than a full parse.
def session_cwd(path)
  File.foreach(path, encoding: 'UTF-8', invalid: :replace, undef: :replace).lazy.each do |line|
    record = begin
      JSON.parse(line)
    rescue JSON::ParserError
      next
    end
    return record['cwd'] if record.is_a?(Hash) && record['cwd']
  end
  nil
end

# A session belongs to this project if it ran in the project directory or
# anywhere beneath it -- `cd backend && claude` is the same piece of work.
def in_project?(cwd)
  return false if cwd.nil?

  cwd == PROJECT || cwd.start_with?("#{PROJECT}#{File::SEPARATOR}")
end

def parse_time(value)
  Time.parse(value)
rescue StandardError
  nil
end

def truncate(text, limit)
  return text if limit.zero? || text.length <= limit

  "#{text[0, limit]}\n\n... [#{text.length - limit} more characters omitted]"
end

# Tool results and file contents go in fenced blocks. Pick a fence longer than
# any backtick run inside, so a result that itself contains ``` does not end the
# block early and scramble the rest of the document.
def fenced(text)
  longest = text.scan(/`+/).map(&:length).max || 0
  fence = '`' * [longest + 1, 3].max
  "#{fence}\n#{text.rstrip}\n#{fence}"
end

def block_text(content)
  case content
  when String then content
  when Array
    content.filter_map do |part|
      next part if part.is_a?(String)
      part['text'] || part['content'] if part.is_a?(Hash)
    end.join("\n")
  when Hash then content['text'].to_s
  else content.to_s
  end
end

# One line per tool call: enough to follow what happened without reprinting the
# arguments in full. The interesting ones get named explicitly.
def tool_summary(name, input)
  input = {} unless input.is_a?(Hash)

  detail =
    case name
    when 'Bash' then input['command']
    when 'Read', 'Write', 'NotebookEdit' then input['file_path']
    when 'Edit' then input['file_path']
    when 'Glob', 'Grep' then [input['pattern'], input['path']].compact.join(' in ')
    when 'Task', 'Agent' then input['description']
    when 'WebFetch' then input['url']
    when 'WebSearch' then input['query']
    when 'TodoWrite' then nil
    else
      compact = JSON.generate(input)
      compact.length > 200 ? nil : compact
    end

  detail = detail.to_s.strip
  return "**Tool: #{name}**" if detail.empty?

  "**Tool: #{name}** — #{truncate(detail.lines.first.to_s.strip, 160)}"
end

transcripts = Dir.glob(File.join(options[:root], '*', '*.jsonl'))
              .select { |path| in_project?(session_cwd(path)) }

if transcripts.empty?
  warn "No Claude Code sessions found for #{PROJECT}."
  warn "Looked in #{options[:root]}."
  warn 'If you ran Claude from a different directory, pass --project.'
  exit 1
end

sessions = transcripts.map do |path|
  records = []
  File.foreach(path, encoding: 'UTF-8', invalid: :replace, undef: :replace) do |line|
    begin
      record = JSON.parse(line)
    rescue JSON::ParserError
      next
    end
    records << record if record.is_a?(Hash)
  end

  started = records.filter_map { |r| parse_time(r['timestamp']) }.min
  { id: File.basename(path, '.jsonl'), path: path, records: records, started: started }
end

sessions.sort_by! { |s| s[:started] || Time.at(0) }

out = []
out << '# AI conversation transcript'
out << ''
out << 'Exported by the `challenge-wrap-up` skill from the Claude Code session logs.'
out << 'This is the raw record of the conversation, not a summary — see `AI-SUMMARY.md` for that.'
out << ''
out << "- Project: `#{PROJECT}`"
out << "- Sessions: #{sessions.length}"
out << "- Exported: #{Time.now.utc.iso8601}"
out << "- Tool output truncated at: #{options[:truncate].zero? ? 'no limit' : "#{options[:truncate]} characters"}"
out << "- Assistant reasoning blocks: #{options[:thinking] ? 'included' : 'omitted'}"
out << "- Subagent messages: #{options[:subagents] ? 'included' : 'omitted'}"
out << ''

total_turns = 0

sessions.each_with_index do |session, index|
  out << '---'
  out << ''
  started = session[:started] ? session[:started].utc.iso8601 : 'unknown start time'
  out << "## Session #{index + 1} — #{started}"
  out << ''
  out << "<sub>`#{session[:id]}`</sub>"
  out << ''

  # tool_use id -> tool name, so a tool_result can say what it is a result of.
  tool_names = {}

  session[:records].each do |record|
    type = record['type']
    next unless %w[user assistant].include?(type)
    next if record['isMeta']
    next if record['isSidechain'] && !options[:subagents]

    message = record['message']
    next unless message.is_a?(Hash)

    prefix = record['isSidechain'] ? '(subagent) ' : ''
    content = message['content']
    content = [{ 'type' => 'text', 'text' => content }] if content.is_a?(String)
    next unless content.is_a?(Array)

    content.each do |block|
      next unless block.is_a?(Hash)

      case block['type']
      when 'text'
        text = block['text'].to_s.strip
        next if text.empty?

        if type == 'user'
          total_turns += 1
          out << "### #{prefix}Human"
          out << ''
          out << text
        else
          out << "### #{prefix}Claude"
          out << ''
          out << text
        end
        out << ''

      when 'thinking'
        next unless options[:thinking]

        text = block['thinking'].to_s.strip
        next if text.empty?

        out << "<details><summary>#{prefix}Claude — reasoning</summary>"
        out << ''
        out << text
        out << ''
        out << '</details>'
        out << ''

      when 'tool_use'
        tool_names[block['id']] = block['name']
        out << tool_summary(block['name'], block['input'])
        out << ''

      when 'tool_result'
        name = tool_names[block['tool_use_id']] || 'tool'
        text = block_text(block['content']).to_s.strip
        next if text.empty?

        out << "<details><summary>Result — #{name}</summary>"
        out << ''
        out << fenced(truncate(text, options[:truncate]))
        out << ''
        out << '</details>'
        out << ''
      end
    end
  end
end

out << '---'
out << ''
out << "_#{total_turns} human turns across #{sessions.length} session(s)._"
out << ''

File.write(options[:out], out.join("\n"))

size_kb = (File.size(options[:out]) / 1024.0).round
puts "Wrote #{options[:out]} (#{size_kb} KB) from #{sessions.length} session(s), #{total_turns} human turns."
