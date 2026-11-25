# AI collaboration summary

This file is Claude's account of how Parker and Claude built this challenge. The source is the session logs (`AI-TRANSCRIPT.md`) and `git log`. Where the logs do not give a reason for a decision, this file says so with a `TODO:` line.

## Approach

Parker set the plan in the first real request: one commit per criteria, with the subject prefix `Criteria N:`. A defect outside a criteria got its own `Bugfix:` commit.

The order was Criteria 1, 2, 3, 4, 5, 6, then the second part of Criteria 4, then 7.

- Criteria 4 has two commits. The first saves weather per location. The second pauses all OpenWeather calls after an account-wide failure. Parker first wanted the second part before Criteria 5, then moved it to after Criteria 6 and called it premature optimization at that point.
- Criteria 7 has two commits: a table with trend lines, then a line chart. One follow-up commit records each OpenWeather pause as an audit event.
- After the criteria, Parker asked for a sidebar regroup, a Settings page for Fahrenheit or Celsius, removal of unused packages, and a bug scan. Three `Bugfix:` commits came from the scan.

## Working with Claude

Parker opened most criteria with a lean and asked Claude to question it. Claude replied with numbered questions. Each question had options and a recommendation with a confidence figure. Parker answered by number. Claude then built the change and left it uncommitted for review. Parker reviewed each change and made several of the commits directly.

What Parker directed:

- The commit plan and the order of work.
- Database-backed weather with a "Last updated" label (Criteria 4).
- A scheduled job for alerts, and no second data provider (Criteria 5).
- A search bar in the top bar that adds a location or opens the one we already have (Criteria 6).
- An admin role on the user in place of a shared password, and a general `AuditEvent` table in place of a favorites-only history (Criteria 7).
- The backfill in its own rake file, not on the model.

What Claude proposed without a request:

- The conditional `UPDATE` claim that lets one request per location call OpenWeather.
- A 30 minute age limit, so old weather during an outage cannot send alerts.
- The fix for the scaffold's swapped stat labels ("Wind Speed" over the feels-like temperature).
- The fix for the weather card that was wider than a phone screen.
- The sample data task for the dashboard.

## Decisions with real alternatives

**Caching strategy (Criteria 4).** Chosen: the last reading is saved on the `locations` row and stays fresh for 10 minutes. The first request after expiry claims the refresh with a conditional `UPDATE` and calls OpenWeather inside the request. All other requests get the saved reading. Alternatives: a scheduled job that refreshes every location, a 5 minute window (Parker's first lean), and a background job for the call. Reasons: a job calls OpenWeather for locations nobody views, and 10 minutes is OpenWeather's own guidance. Parker asked how this stops a thundering herd and if two requests a millisecond apart could both win. They cannot, because the condition runs inside the `UPDATE` against the current row.

**Account-wide failures (Criteria 4, second commit).** Chosen: one saved "paused until" time for the whole account. A 429 pauses calls for 10 minutes. A 401, a 5xx, or a timeout pauses them for 1 minute. One call tests OpenWeather after the pause. Saved weather still shows during a pause. Alternative: also count calls and stop at 50 per minute. Claude recommended the pause only. Parker did not answer that question, so the pause-only version is what is committed.

**How favorite metrics survive an unfavorite (Criteria 7).** Claude recommended an `unfavorited_at` column on `user_favorites`. Parker chose an event table and made it a general `AuditEvent` model with an `action` enum and a `data` JSON column. Parker's reason: a schema changed for tracking stops being a clean picture of the present, and any app with analytics gains from an audit table. The dashboard reads the present count from `user_favorites` and walks back through the events. Also considered: a job that saves a daily count.

**How alerts avoid a repeat (Criteria 5).** Chosen: one alert per user, location, and event type every 6 hours, from a table of sent alerts. A tornado after a thunderstorm alert still sends. Alternative: track when each storm starts and ends, which needs a second table and a rule for when a storm is over.

**What counts as severe (Criteria 5).** Chosen: the saved OpenWeather condition codes and a sustained wind of 40 mph or more. Alternative: National Weather Service alerts. Parker called a second provider overengineering for this project.

**How duplicate locations are detected (Criteria 6).** Chosen: the server builds the name from city, state, and country. A name we already have returns the saved row with a 200 and makes no OpenWeather call. A unique index on the name covers a race. For a new name the server asks OpenWeather again and takes the coordinates from that answer, so the browser cannot set them. Claude recommended a signed search result to save that second call. Parker said that was more complex than a second lookup, and Claude built Parker's form.

**Favorites UI (Criteria 2).** Parker chose a star on every sidebar row and a click on the star to toggle. Claude had recommended stars on favorites only and no click.

## Corrections

Places where Claude was wrong, and how each was caught:

- **Retry backoff.** Claude's first error retry kept the SWR default, which grows the wait without a useful limit. A page in the 503 state did not recover for minutes. Claude saw this in its own browser check and replaced it with a retry that doubles from 1 second and stops at 30 seconds.
- **Deleted its own work.** During a mutation check Claude ran `git checkout --` on a file with uncommitted code and lost it. Claude rewrote the file, ran the tests, and told Parker.
- **Broke the running frontend.** The chart library needs a peer package that Claude did not install. Parker's dev server returned 500 on every page for about a minute.
- **Backfill on the model.** Claude put the backfill method on `UserFavorite`. Parker moved it to a rake file for separation of concerns.
- **Recommendations Parker overruled.** The signed search result, the `unfavorited_at` column, no backfill, and a table with no line chart. Parker chose differently each time.
- **Favorites first.** Parker chose a sidebar that moves favorites to the top. Parker saw it, called it jarring, and reversed it. The later regroup into sections was Parker's design.
- **Column type.** Claude and Parker agreed on `decimal(9,6)` for coordinates. Claude then found that a decimal goes to OpenWeather as `0.407128e2`, used `float`, and told Parker.
- **Defects found by the final scan in Claude's own earlier work.** A new location with no city or no country returned 500 (fixed). Two unfavorite requests at the same moment write two audit events (not fixed). A page for a location that does not exist requests its weather without end (not fixed).
- **Scan results.** Two subagents did the scan. Claude checked each finding before the report and rejected six. Three were false and three were the intended design. Claude's brief to the subagents also said that users sign in by name, which is wrong.

## Verification

Tests that pass:

- The backend suite: 113 runs, 0 failures at the last commit. It was 7 runs at the start.
- A test with real threads shows one OpenWeather call for many requests at the same moment.
- The TypeScript type check passes. The frontend has no tests.

Mutation checks. Claude took out one rule at a time and saw the tests fail. The rules were the pause condition (7 failures), the alert age limit (2), the repeat rule (4), the admin check, and the unfavorite sign.

Watched in the running app:

- 50 parallel requests for one stale location gave 50 responses with HTTP 200 and 1 OpenWeather call.
- With a pause set, search and add returned 503 and saved weather returned 200. After the pause, the next call cleared it.
- The scheduled job ran on its timer. A planted tornado reading printed one notification and saved one sent alert.
- Each UI change was checked in a browser at 1280 px and 390 px, for an admin and for a member.
- Parker planned a manual clickthrough of the app. The logs do not show its results.

Not proven live: real severe weather, the 6 hour repeat rule, and recovery after a crash. Tests with time travel cover the last two.

## Deliberately not done

- **Sign-in.** The first user is the signed-in user. The challenge allows this, and the scaffold already did it.
- **A cap on calls per minute.** See the pause decision above.
- **A second weather alert provider.**
- **Redis for the pause.** Parker asked if Redis was the right tool. One database row does the same job with no second service to run.
- **An optimistic favorite toggle.** The button waits for the server.
- **Removal of a location.** The list only grows.
- **A password on the admin page.** This was Parker's first idea. Parker replaced it with the admin role.
- **Real delivery of alerts.** `Notifier` prints, as the challenge allows.

## Known gaps and next steps

- Two unfavorite requests at the same moment write two `unfavorite` events, so the history for that location reads one too high.
- A failure that arrives after a 429 can cut the 10 minute pause to 1 minute. The cost is one early call.
- The place search calls OpenWeather on each typing pause, with no cache.
- Two overlapping runs of the alert job could send one duplicate.
- The temperature unit is saved per browser, not per user.
- The sidebar shows no message if its requests fail.
- "Chicago, IL" finds nothing, because OpenWeather wants the full state name. openweathermap.org does the same.
- Next steps: real sign-in, the call cap if traffic grows, frontend tests, and an index on `user_favorites.location_id` when the table is large.
