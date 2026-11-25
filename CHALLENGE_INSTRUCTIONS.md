# README

## Intro

Punchbowl-Weather displays the current weather using the free [OpenWeather API](https://openweathermap.org/).
The user may choose from a list of preset locations.

The application uses a Ruby on Rails backend API located in the `backend` directory and a Next.js frontend located in
the `frontend` directory.

# The Challenge

This project was started by a junior developer and you are taking over ownership of it. Extend the application to meet the following [acceptance criteria](#acceptance-criteria).

**At the end of the challenge the project should be something you are happy to share with coworkers and work with ops to ship.**

[Setup](#setup) and acceptance criteria ([Step 0](#step0), [Step 1](#step1), [Step 2](#step2), [Step
3](#step3), [Step 4](#step4), [Step 5](#step5), [Step 6](#step6), [Step 7](#step7), [Step 8](#step8)) are below. Please complete all steps.

This is not a timed exercise, but expect it to take 2-3 hours to complete. You are free to take as much or as little 
time as you would like. You will be graded on completing and returning the project by the deadline, completing
the required steps, and the overall quality.

## Returning your challenge

To return your code challenge:

1. Remove the `node_modules` directories
2. Archive your project as `.zip` or `.tar.gz` file. Include the `.git` directory — we review your
commit history
3. Email your archived project to your recruiting contact. You may need to upload your
archive to a file sharing service like Dropbox or Google Drive.

# Setup
## Dependencies

This application requires:

* Ruby v4.0+
* Node v24+
* yarn (or npm)

See the [Ruby on Rails Installation Guide](https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails)
for more information about installing Ruby.

The is a monorepo with the following directories:

* `backend` – Rails 8.1 API application
* `frontend` – Next.js v16 application (React, Typescript, and TailwindCSS)

## Backend

### Install

Run the following steps in the `backend` directory.

```bash
bundle install
```

Run migrations to initialize the sqlite database.

```bash
bin/rails db:migrate
```

### Tests

Validate your installation by running the tests.

```bash
❯ bin/rake test
Running 7 tests in a single process (parallelization threshold is 50)
Run options: --seed 43004

# Running:

S...S..

Finished in 0.179480s, 39.0016 runs/s, 50.1449 assertions/s.
7 runs, 9 assertions, 0 failures, 0 errors, 2 skips

You have skipped tests. Run with --verbose for details.
```

### Development Server

Run the Rails server on port 3001 using following command.

```bash
❯ bin/rails server -p 3001
=> Booting Puma
=> Rails 8.1.3.1 application starting in development 
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 8.0.2 ("Into the Arena")
* Ruby version: ruby 4.0.6 (2026-07-14 revision 03b6d3f889)
*  Min threads: 5
*  Max threads: 5
*  Environment: development
*          PID: 84298
* Listening on http://127.0.0.1:3001
* Listening on http://[::1]:3001
Use Ctrl-C to stop
```

## Frontend

### Install

Run the following steps in the `frontend` directory.

```bash
yarn install
```

### Development Server

Run the development server on port 3000 using the following command.

```bash
yarn run dev
```

At this point, you should be able to connect to the weather app at:

<a href="http://localhost:3000" target="_blank">http://localhost:3000</a>.


# Acceptance Criteria

## <a name="criteria0"></a> Criteria 0: Set up a git repository

This monorepo is not currently a git repository. Set up a local git repository and commit your changes.

## <a name="criteria1"></a> Criteria 1: The locations data should be databased-backed instead of hardcoded

## <a name="criteria2"></a> Criteria 2: Allow users to mark multiple cities as favorites

Allow a user to mark multiple cities as favorites. Highlight the favorites with a star in the sidebar and
a button on the page to mark the currently selected location as a favorite.

For this step, don't worry about authentication. You can assume `User.first` is the current user.

## <a name="criteria3"></a> Criteria 3: Create a Locations API endpoint in the backend and use the Locations API in the frontend

Update the frontend to use the new Locations API. The sidebar should show all of the locations from the API

## <a name="criteria4"></a> Criteria 4: Weather API rate-limiting and optimization

Our weather app is very popular with a large number of concurrent
users and only a limited number of supported locations. The third-party OpenWeather API
is rate-limiting us which is causing our API to throw errors. Create a solution
that will resolve the API rate-limit issues.

## <a name="criteria5"></a> Criteria 5: Severe Weather Alerts

Add a feature to alert users of severe weather in the locations they have marked as favorites.

NOTE: You do not need to connect to any real email/sms/push notifications. You can stub a notify method with something like:

```
class Notifier
  # This is the final send to a message delivery API.
  # Assume this sends the given message to the user with no additional internal business logic.
  # All other logic should be written by you outside of this class.
  def self.notify(user_id, message)
    puts "Notified user_id #{user_id}: #{message}"
  end
end
```

## <a name="criteria6"></a> Criteria 6: Dynamic locations

Suppose we want to support a dynamic list of any locations instead of only a list that is hardcoded or seeded in the database. Implement support for this.

## <a name="criteria7"></a> Criteria 7: Metrics

Our app needs an admin dashboard to see how many users favorited each location and display this data over time

## <a name="criteria8"></a> Criteria 8: Document your process

We expect you to use AI on this challenge, and we are as interested in how you worked as in what
you built. Once the steps above are complete, run this skill from the repository root:

```
/challenge-wrap-up
```

Then return your challenge after the skill is complete.
