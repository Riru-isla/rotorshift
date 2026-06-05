# RotorShift Backend

Rails 8.1 API application. Ruby 3.3, PostgreSQL.

## Setup

```bash
bundle install
rails db:create db:migrate
rails server # runs on port 3000
```

## Stack

- **Framework:** Rails 8.1 (API-only mode)
- **Database:** PostgreSQL (rotorshift_development / rotorshift_test)
- **Background jobs:** Solid Queue
- **Caching:** Solid Cache
- **Linting:** RuboCop (rails-omakase config)
- **Security:** Brakeman, bundler-audit

## Conventions

- API-only — no views, no asset pipeline
- JSON responses, RESTful endpoints
- Models use `ApplicationRecord` base class
- Keep business logic in models and service objects, not controllers
- Controllers should be thin: validate params, call service, render response
- Use concerns for shared model behavior
- Database constraints should mirror model validations

## Key Commands

```bash
rails db:migrate          # run migrations
rails db:rollback         # undo last migration
bundle exec rubocop       # lint
bundle exec brakeman      # security scan
bundle exec bundler-audit # dependency audit
```
