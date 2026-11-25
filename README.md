# Punchbowl Weather: notes for reviewers

## Setup

Start with all the setup instructions in [CHALLENGE_INSTRUCTIONS.md](CHALLENGE_INSTRUCTIONS.md). Then seed the database:

```sh
cd backend
bin/rails db:seed
```

The seed script creates the preset locations and one user. The app treats that user as the signed-in user, and the script makes that user an admin. The script is safe to run more than once.

## Admin dashboard

An admin sees an "Admin dashboard" link in the sidebar. The page is at `/admin`. It shows how many users had each location as a favorite on each of the last 30 days. Days are in UTC.

A new database has one user, so the dashboard has little to show. This task adds 60 sample users with favorites and unfavorites across the last 45 days:

```sh
cd backend
bin/rails sample_data:favorites
```

Each run adds 60 more users. The task does not run in production.

To see the page as a user who is not an admin, change the role and reload:

```sh
bin/rails runner 'User.first.update!(role: :member)'
```

Run `bin/rails db:seed` to make that user an admin again.

## Audit events

Each favorite and each unfavorite writes one row to `audit_events`. The dashboard reads the present count from `user_favorites` and the past from these events.

Each account-wide pause of the OpenWeather calls also writes one row. The row holds the error class, the HTTP status, and the time the pause ends.

A favorite made before this table existed has no event. This task writes the missing events, with the time of each favorite. It is safe to run more than once:

```sh
cd backend
bin/rails backfill:favorite_audit_events
```

A favorite that was removed before this table existed left no record, so the dashboard cannot show it.
