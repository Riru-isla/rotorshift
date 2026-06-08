# Domain Context

RotorShift is built for helicopter emergency/rescue companies (HEMS — Helicopter Emergency Medical Service) where pilots work rotating shifts at bases.

## How Scheduling Works

1. **Shift patterns** define rotation cycles per pilot (e.g. 7 days on, 7 days off). Each pilot has a `rotation_start_date` that anchors their cycle — two pilots on the same 7/7 pattern but with different start dates will be offset.

2. **Monthly schedules** are the core unit. A manager creates a schedule for a given month, specifying minimum staffing (active pilots and on-hold pilots per day).

3. **Auto-generation** fills the schedule by evaluating each pilot for each day in priority order:
   - Unavailable days (hard block, set by pilot)
   - Approved vacation
   - Org-wide holidays
   - Mandatory training events
   - Shift pattern rotation (on_duty or off_duty based on cycle position)
   After initial assignment, a balancing pass moves off_duty pilots to on_duty to meet minimum staffing requirements.

4. **Manual override** — after generation, any entry can be changed by clicking the cell in the grid view. Schedules start as "draft" and can be "published" when finalized.

5. **Pilot view** — once published, pilots can log in and see their own schedule for the month.

## Entry Types

- `on_duty` — actively working
- `off_duty` — rest day per rotation
- `training` — mandatory training event
- `holiday` — org-wide holiday
- `vacation` — approved vacation
- `unavailable` — hard "do not disturb" day

## Roles

- **Admin** (boss/manager) — can create/edit schedules, manage pilots, approve vacations
- **Pilot** — can view their own schedule, request vacations, set unavailable days

Roles are flexible via Rolify, scoped to organizations. Not hardcoded.

## Multi-Tenancy

Each organization is independent. Users belong to one organization. All queries are scoped through `current_organization` (derived from the logged-in user).
