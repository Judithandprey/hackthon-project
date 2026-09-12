# H@B Application Portal

A miniature hackathon management platform by Yisha Tang for the Cal Hacks FA26 tech team take-home.

**Ruby on Rails · MVC · Active Record · ERB · RSpec · Cucumber · Render**

If you downloaded the source ZIP, see [how to upload it to GitHub](docs/GITHUB_UPLOAD.md).

This project uses the structure taught in CS169. It is a normal website: people register, sign in with email and password, and create their own applications. The database starts empty.

## What works

- **Hacker and mentor accounts:** each account type has its own application questions. Mentors also provide availability.
- **Email and password authentication:** Rails `has_secure_password` uses bcrypt. Database sessions expire after seven days and are revoked on logout.
- **Drafts and submission:** applicants save incomplete drafts, resume later, and submit when complete. Submitted applications become read-only.
- **Organizer workspace:** search and filter applications by role and status, read responses, and save a three-criterion rubric, private notes, and a decision.
- **Extra features:** a live application checklist, a status journey, and blind review that hides identity fields from the rendered organizer page.
- **Concurrent editing protection:** Rails optimistic locking protects drafts; row locks and transactions keep reviews and decisions consistent.

## Run locally

Use Ruby 3.3.10 and Bundler. Development and tests use SQLite; Render uses managed PostgreSQL.

```sh
bundle install
bin/rails db:prepare
bin/rails server
```

Open `http://localhost:3000`. Select **Create an account**, choose Hacker or Mentor, and enter an email and password. Passwords must be at least 12 characters.

To create an organizer account locally, first generate a private invitation code:

```sh
ruby -rsecurerandom -e 'puts SecureRandom.hex(32)'
```

Set the result as `ORGANIZER_INVITE_CODE` in the terminal that starts Rails. Then register a **separate organizer account**, choosing Organizer and entering that code. Do not commit the code to GitHub.

## Deploy to Render

The repository includes a `render.yaml` Blueprint for a free Ruby web service and a free managed PostgreSQL database. Render generates `SECRET_KEY_BASE` and injects `DATABASE_URL`. Enter a private `ORGANIZER_INVITE_CODE` of at least 32 characters when applying the Blueprint.

[Create the Render Blueprint](https://dashboard.render.com/blueprint/new?repo=https://github.com/Judithandprey/hackthon-project)

1. Select this repository and apply the Blueprint.
2. Wait for `hab-portal-yisha` to report **Live**.
3. Open the public URL shown by Render. `/up` checks the database connection.
4. Register a separate Organizer account using the invitation code you entered during deployment. You can retrieve it from the service's **Environment** page. Keep that code out of the recording.

The build runs `bundle install`. Startup runs `rails db:prepare` and Puma. Running migrations on startup supports Render's free web plan, which does not provide a pre-deploy command. No asset compiler, Node.js, or external login provider is needed.

Free Render web services may sleep when idle; free PostgreSQL databases expire after 30 days. If the free database quota is unavailable, choose an existing suitable database or review paid options yourself before proceeding. See [Render's free plan documentation](https://render.com/docs/free).

## CS169 structure

| CS169 concept | Code to read |
|---|---|
| MVC: models and domain rules | `app/models/user.rb`, `hack_application.rb`, `review.rb` |
| MVC: request handling and authorization | `app/controllers/` |
| MVC: server-rendered HTML | `app/views/` with ERB and `form_with` |
| RESTful routes | `config/routes.rb` |
| Active Record associations | A user has one application; an application has one review |
| Database migrations | `db/migrate/20260911000001_create_portal.rb` |
| Strong parameters | Applicant and review controllers permit specific fields |
| RSpec request tests | `spec/requests/portal_spec.rb` |
| Cucumber / Given–When–Then | `features/applications.feature` and its step definitions |

Read [the Chinese walkthrough](docs/CS169_WALKTHROUGH.md) for a request-by-request explanation.

## Test

```sh
RAILS_ENV=test bundle exec rails db:prepare
bundle exec rspec
bundle exec cucumber --format progress
bundle exec rails zeitwerk:check
```

Tests use Rails controllers, rendered ERB views, real Active Record queries, and a local SQLite database. Cucumber drives the application through Capybara's Rack test adapter; it does not execute browser JavaScript. Test accounts stay in the test database. This is not a claim that a live Render deployment has been verified.

## Data and security

- `users`: name, normalized unique email, bcrypt password digest, and account role.
- `login_sessions`: SHA-256 digest of a random login token, owner, and expiration. The browser receives the token in an encrypted, HttpOnly, SameSite cookie; production cookies are Secure.
- `hack_applications`: answers, status, submission time, and `lock_version`.
- `reviews`: one current rubric per application, organizer identity, and private notes.
- `login_attempts`: database-backed limits for registration and login attempts per email.

Rails provides CSRF protection and ERB output escaping. Applicants can only load and change their own application. Organizer endpoints enforce permissions on the server. Registration requires a private server secret to create an organizer. Review notes are never rendered in applicant pages.

## Scope

This is one event with one current review per application. There are no email verification/reset messages, notifications, uploads, deadlines, or review history. Blind review hides structured identity fields; applicants may identify themselves in free text. Draft saving is explicit. Account type is chosen at registration; use separate accounts when recording the applicant and organizer flows.

[Recording outline](docs/RECORDING_GUIDE.md) · [Render instructions in Chinese](docs/RENDER_DEPLOY.md)
