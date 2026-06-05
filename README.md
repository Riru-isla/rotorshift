# RotorShift

Helicopter pilot scheduling application for emergency/rescue companies.

## Structure

- `backend/` — Rails 8 API (Ruby 3.3, PostgreSQL)
- `frontend/` — Vue.js SPA (TypeScript, Pinia, Vue Router)

## Development

### Backend

```bash
cd backend
bundle install
rails db:create db:migrate
rails server
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```
