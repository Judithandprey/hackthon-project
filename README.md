# H@B Application Portal

A miniature hackathon management platform by Yisha Tang for the Cal Hacks FA26 tech team take-home.

**Ruby on Rails · MVC · Active Record · ERB · RSpec · Cucumber · Render**



## What works

- **Hacker and mentor accounts:** each account type has its own application questions. Mentors also provide availability.
- **Email and password authentication:** Rails `has_secure_password` uses bcrypt. Database sessions expire after seven days and are revoked on logout.
- **Drafts and submission:** applicants save incomplete drafts, resume later, and submit when complete. Submitted applications become read-only.
- **Organizer workspace:** search and filter applications by role and status, read responses, and save a three-criterion rubric, private notes, and a decision.
- **Extra features:** a live application checklist, a status journey, and blind review that hides identity fields from the rendered organizer page.
- **Concurrent editing protection:** Rails optimistic locking protects drafts; row locks and transactions keep reviews and decisions consistent.


| MVC: models and domain rules | `app/models/user.rb`, `hack_application.rb`, `review.rb` |
| MVC: request handling and authorization | `app/controllers/` |
| MVC: server-rendered HTML | `app/views/` with ERB and `form_with` |
| RESTful routes | `config/routes.rb` |
| Active Record associations | A user has one application; an application has one review |
| Database migrations | `db/migrate/20260911000001_create_portal.rb` |
| Strong parameters | Applicant and review controllers permit specific fields |
| RSpec request tests | `spec/requests/portal_spec.rb` |
| Cucumber / Given–When–Then | `features/applications.feature` and its step definitions |


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


