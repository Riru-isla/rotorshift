# RotorShift Frontend

Vue 3 SPA with TypeScript. Consumes the Rails API backend.

## Setup

```bash
npm install
npm run dev   # Vite dev server
npm run build # production build
```

## Stack

- **Framework:** Vue 3.5 (Composition API)
- **Language:** TypeScript 6
- **State management:** Pinia 3
- **Routing:** Vue Router 5
- **Build tool:** Vite 8
- **Node:** >=22.12.0 or ^20.19.0

## Conventions

- Use Composition API with `<script setup lang="ts">` in all components
- State lives in Pinia stores (`src/stores/`)
- Views are page-level components (`src/views/`), components are reusable pieces (`src/components/`)
- API calls go through a dedicated service layer, not directly in components
- Type all props, emits, and store state
- Mobile-first responsive design

## Key Commands

```bash
npm run dev        # start dev server
npm run build      # type-check + production build
npm run type-check # TypeScript check only
npm run preview    # preview production build
```
