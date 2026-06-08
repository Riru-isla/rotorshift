# RotorShift

Helicopter pilot scheduling application for emergency/rescue companies.

Managers create monthly shift rosters that auto-generate schedules respecting each pilot's rotation pattern, holidays, training, vacations, and unavailability. Pilots log in to view their own schedule.

## Quick Start (Docker)

```bash
git clone <repo-url> && cd rotorshift
docker compose up --build
```

Wait for all services to be healthy, then seed the database:

```bash
docker compose exec backend rails db:seed
```

Open http://localhost:5173 and sign in:

- **Admin:** `boss@skyrescue.com` / `password123`
- **Pilots:** `pilot1@skyrescue.com` through `pilot12@skyrescue.com` / `password123`

## What You Can Do

1. **Sign in** as the admin (boss)
2. **Create a roster** — pick a month, set minimum active/on-hold pilots, hit "Generate Roster"
3. **View the schedule grid** — all pilots across all days of the month, color-coded by entry type
4. **Edit entries** — click any cell to cycle through types (on duty, off duty, training, etc.)
5. **Publish** — finalize the roster so pilots can see it
6. **View a single pilot's schedule** — click a pilot name in the grid
7. **Sign in as a pilot** — see "My Schedule" with today highlighted

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Rails 8.1 (API-only), Ruby 3.3 |
| Frontend | Vue 3, TypeScript, Pinia, Vue Router, Vite |
| Database | PostgreSQL 17 |
| Cache | Redis 7 |
| Auth | Devise + devise-jwt (JWT with JTI revocation) |
| Authorization | Rolify + Pundit |
| Testing | RSpec, FactoryBot, Shoulda Matchers |

## Project Structure

```
rotorshift/
├── backend/                # Rails 8.1 API
│   ├── app/
│   │   ├── controllers/    # API::V1 namespaced controllers
│   │   ├── models/         # 11 models (User, Organization, Schedule, etc.)
│   │   ├── services/       # ScheduleGenerator
│   │   └── policies/       # Pundit policies
│   ├── db/
│   │   ├── migrate/        # Database migrations
│   │   └── seeds.rb        # Demo data (1 org, 12 pilots, admin)
│   └── spec/               # RSpec tests (105 examples)
├── frontend/               # Vue 3 SPA
│   └── src/
│       ├── api/            # Axios client with JWT interceptor
│       ├── stores/         # Pinia stores (auth, schedules)
│       ├── router/         # Vue Router with auth guards
│       └── views/          # 6 page components
├── docker-compose.yml      # Full dev environment
└── README.md
```

## Services (Docker)

| Service | Internal Port | Host Port |
|---------|--------------|-----------|
| PostgreSQL 17 | 5432 | 5433 |
| Redis 7 | 6379 | 6379 |
| Rails backend | 3000 | 3000 |
| Vue frontend | 5173 | 5173 |

## Local Development (without Docker)

```bash
# Backend (requires PostgreSQL and Redis running locally)
cd backend
bundle install
rails db:create db:migrate db:seed
rails server

# Frontend
cd frontend
npm install
npm run dev
```

## Testing

```bash
# Via Docker
docker compose exec backend bundle exec rspec

# Local
cd backend && bundle exec rspec
```

## API

All endpoints under `/api/v1/`. Authentication via JWT bearer token in the `Authorization` header.

Key endpoints:

- `POST /api/v1/auth/sign_in` — returns JWT token
- `GET /api/v1/schedules` — list rosters
- `POST /api/v1/schedules` — create roster (with `auto_generate: true` to trigger scheduling engine)
- `GET /api/v1/schedules/:id` — roster detail with all entries
- `PATCH /api/v1/schedules/:id/schedule_entries/:entry_id` — edit a single entry
- `PATCH /api/v1/schedules/:id/publish` — publish roster
