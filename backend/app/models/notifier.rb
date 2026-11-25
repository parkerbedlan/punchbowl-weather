class Notifier
  # This is the final send to a message delivery API.
  # Assume this sends the given message to the user with no additional internal business logic.
  # All other logic should be written by you outside of this class.
  def self.notify(user_id, message)
    puts "Notified user_id #{user_id}: #{message}"
  end
end
