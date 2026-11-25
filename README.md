# Punchbowl Weather: notes for reviewers

## Setup

Start with all the setup instructions in [CHALLENGE_INSTRUCTIONS.md](CHALLENGE_INSTRUCTIONS.md). Then seed the database:

```sh
cd backend
bin/rails db:seed
```

The seed script creates the preset locations and one user. The app treats that user as the signed-in user. The script is safe to run more than once.
