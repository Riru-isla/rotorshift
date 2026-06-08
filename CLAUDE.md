# RotorShift

Helicopter pilot scheduling application for emergency/rescue companies.

## Project Structure

- `backend/` — Rails 8.1 API (Ruby 3.3, PostgreSQL)
- `frontend/` — Vue 3 SPA (TypeScript, Pinia, Vue Router, Vite)
- `docker-compose.yml` — Full dev environment orchestration
- `.claude/context/` — Background context documents (domain knowledge, decisions)
- `.claude/plans/` — Implementation plans for features and milestones
- `.claude/issues/` — Bug reports, known issues, and investigation notes
- `.claude/commands/` — Custom Claude Code slash commands

## Architecture

Monorepo with a strict API boundary between backend and frontend. The backend is a JSON API consumed by the Vue SPA. No server-rendered views. All API endpoints live under `/api/v1/`.

Authentication uses Devise + devise-jwt (JTI revocation strategy). Authorization uses Rolify (flexible roles scoped to organizations) + Pundit (policy objects).

## Domain

Pilots work rotating shifts (e.g. 7 days on / 7 days off) at emergency/rescue helicopter bases. The app helps managers generate monthly schedules that respect shift patterns, minimum staffing requirements, holidays, mandatory training, vacation approvals, and hard unavailability ("do not disturb") days set by pilots.

## Key Design Principles

- Roles and permissions are flexible and configurable, not hardcoded
- Shift patterns are per-pilot and configurable (v1 default: 7-on/7-off)
- Multi-tenancy ready from day one (organizations/bases)
- Schedule auto-generation with manual override
- Build for configurability and scalability — avoid shortcuts that constrain future growth

## Development (Docker)

```bash
docker compose up --build        # start all services (db, redis, backend, frontend)
docker compose exec backend rails db:seed  # seed the database
```

Services: PostgreSQL 17 (port 5433), Redis 7 (port 6379), Rails backend (port 3000), Vue frontend (port 5173).

The backend entrypoint runs `bundle install` and `rails db:prepare` on every start. The frontend uses a named volume for node_modules — if you add new npm packages, remove the volume and rebuild: `docker compose rm -f frontend && docker volume rm rotorshift_frontend_node_modules && docker compose up -d --build frontend`.

## Development (Local)

```bash
# Backend
cd backend && bundle install && rails db:create db:migrate db:seed && rails server

# Frontend
cd frontend && npm install && npm run dev
```

## Testing

```bash
docker compose exec backend bundle exec rspec  # run all specs
```

## Commits

Do not add Co-Authored-By lines to any commit.
