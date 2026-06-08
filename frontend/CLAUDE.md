# RotorShift Frontend

Vue 3 SPA with TypeScript. Consumes the Rails API backend.

## Setup

```bash
npm install
npm run dev   # Vite dev server on port 5173
npm run build # production build
```

## Stack

- **Framework:** Vue 3.5 (Composition API)
- **Language:** TypeScript 6
- **State management:** Pinia 3
- **Routing:** Vue Router 5
- **HTTP client:** Axios
- **Build tool:** Vite 8
- **Node:** >=22.12.0 or ^20.19.0

## Pages

- `/login` — sign in with email/password
- `/shifts` — list of all shift rosters (schedule cards)
- `/shifts/new` — create a new roster with auto-generation params
- `/shifts/:id` — schedule grid: all pilots x all days, click cells to edit entry type, publish button
- `/shifts/:id/pilot/:pilotId` — single pilot's monthly schedule (day-by-day list with stats)
- `/my-schedule` — logged-in pilot sees their own published schedule with "today" highlight

## Architecture

- `src/api/client.ts` — Axios instance with JWT bearer token interceptor, auto-redirect to /login on 401
- `src/stores/auth.ts` — Pinia store for authentication (signIn, signOut, fetchMe, role checks)
- `src/stores/schedules.ts` — Pinia store for schedules CRUD, entries, pilots
- `src/router/index.ts` — routes with auth guard (redirects to /login if no token, fetches /me on refresh)
- `src/views/` — page-level components
- `src/components/` — reusable components
- `src/assets/` — global CSS reset

## Conventions

- Use Composition API with `<script setup lang="ts">` in all components
- State lives in Pinia stores (`src/stores/`)
- Views are page-level components (`src/views/`), components are reusable pieces (`src/components/`)
- API calls go through Pinia stores which use the Axios client, not directly in components
- Type all props, emits, and store state
- Mobile-first responsive design
- Global styles (buttons, cards, layout) in `App.vue`, page-specific styles use `<style scoped>`

## Key Commands

```bash
npm run dev        # start dev server
npm run build      # type-check + production build
npm run type-check # TypeScript check only
npm run preview    # preview production build
```
