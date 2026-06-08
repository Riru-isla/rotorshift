# RotorShift Backend

Rails 8.1 API application. Ruby 3.3, PostgreSQL.

## Setup

```bash
bundle install
rails db:create db:migrate db:seed
rails server # runs on port 3000
```

## Stack

- **Framework:** Rails 8.1 (API-only mode)
- **Database:** PostgreSQL (rotorshift_development / rotorshift_test)
- **Auth:** Devise + devise-jwt (JTI revocation strategy)
- **Authorization:** Rolify + Pundit
- **Background jobs:** Solid Queue
- **Caching:** Solid Cache
- **Testing:** RSpec, FactoryBot, Shoulda Matchers, Faker
- **Linting:** RuboCop (rails-omakase config)
- **Security:** Brakeman, bundler-audit

## API Endpoints

All routes under `/api/v1/`:

- `POST /api/v1/auth/sign_in` — JWT login (returns token + user)
- `DELETE /api/v1/auth/sign_out` — revoke JWT
- `POST /api/v1/auth/sign_up` — registration
- `GET /api/v1/me` — current user profile
- `GET/POST /api/v1/schedules` — list/create schedules (create accepts `auto_generate`, `minimum_active`, `minimum_on_hold`)
- `PATCH /api/v1/schedules/:id/publish` — publish a draft schedule
- `GET/PATCH /api/v1/schedules/:id/schedule_entries` — list/update entries
- `GET/POST /api/v1/pilot_profiles` — manage pilots
- `GET/POST /api/v1/holidays` — org holidays
- `GET/POST /api/v1/vacation_requests` — with `approve`/`deny` member actions
- `GET/POST /api/v1/unavailable_days` — pilot DND days
- `GET/POST /api/v1/training_events` — mandatory training
- `GET/POST /api/v1/staffing_requirements` — seasonal minimums
- `GET/POST /api/v1/shift_patterns` — rotation patterns (e.g. 7-on/7-off)

## Models

- **User** — Devise authenticatable, has roles via Rolify, optional pilot_profile
- **Organization** — multi-tenant root; has many users, schedules, shift_patterns, holidays, staffing_requirements
- **PilotProfile** — 1:1 with User, belongs to shift_pattern, has rotation_start_date
- **ShiftPattern** — days_on/days_off (e.g. 7/7), assigned per pilot
- **Schedule** — monthly schedule per org (draft/published/archived)
- **ScheduleEntry** — one per pilot per day per schedule (on_duty/off_duty/training/holiday/vacation/unavailable)
- **VacationRequest** — pending/approved/denied/cancelled, reviewed_by user
- **Holiday** — org-wide holidays
- **TrainingEvent** — mandatory training per pilot
- **UnavailableDay** — hard DND days set by pilots
- **StaffingRequirement** — minimum active pilots per date range

## Services

- **ScheduleGenerator** — auto-generates monthly schedule entries respecting shift rotation, unavailability, vacations, holidays, training, then balances to meet minimum staffing

## Conventions

- API-only — no views, no asset pipeline
- JSON responses, RESTful endpoints
- Models use `ApplicationRecord` base class
- Keep business logic in models and service objects, not controllers
- Controllers should be thin: validate params, call service, render response
- Use concerns for shared model behavior
- Database constraints should mirror model validations
- `include Devise::JWT::RevocationStrategies::JTIMatcher` MUST come before the `devise` call in the User model

## Seed Data

`rails db:seed` creates: 1 org (SkyRescue Operations), 1 admin (boss@skyrescue.com / password123), 12 pilots with staggered rotation starts, 2 shift patterns (7/7 and 5/2), 3 holidays, 2 staffing requirements.

## Key Commands

```bash
bundle exec rspec           # run tests (105 examples)
rails db:migrate            # run migrations
rails db:rollback           # undo last migration
rails db:seed               # seed demo data
bundle exec rubocop         # lint
bundle exec brakeman        # security scan
bundle exec bundler-audit   # dependency audit
```
