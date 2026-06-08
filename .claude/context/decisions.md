# Technical Decisions

## Auth: Devise + devise-jwt with JTI Revocation

JWT tokens stored in localStorage on the frontend. JTI (JWT ID) column on the users table allows token revocation on sign-out. The `include Devise::JWT::RevocationStrategies::JTIMatcher` line MUST come before the `devise` call in the User model.

Devise 5 changed the signature of `respond_to_on_destroy` — it now passes an argument, so the override uses `def respond_to_on_destroy(_resource_or_scope = nil)`.

## Authorization: Rolify + Pundit

Rolify provides flexible, database-backed roles that can be scoped to resources (e.g. admin of a specific organization). Pundit provides policy objects for fine-grained authorization. Organization model has `resourcify` for scoped roles.

## Docker Dev Environment

PostgreSQL runs inside Docker on internal port 5432, mapped to host port 5433 (to avoid conflicts with local Postgres). Redis on 6379. Backend on 3000. Frontend on 5173.

The backend entrypoint (`bin/docker-entrypoint-dev`) runs `bundle install` and `rails db:prepare` on every container start. This ensures migrations run automatically. Database operations cannot run during `docker build` because the Postgres container isn't available at build time.

The frontend uses a named Docker volume (`frontend_node_modules`) to persist node_modules separately from the host bind mount. If npm dependencies change, the volume must be removed and the container rebuilt.

## Schedule Generation

The `ScheduleGenerator` service uses `insert_all` for bulk creation of schedule entries. It processes constraints in priority order (unavailability > vacation > holiday > training > shift rotation) then runs a balancing pass to meet minimum staffing by promoting off_duty pilots.

## API Design

All endpoints under `/api/v1/`. Schedule creation accepts `auto_generate`, `minimum_active`, and `minimum_on_hold` params alongside the standard `year`/`month` to trigger auto-generation in a single request.
