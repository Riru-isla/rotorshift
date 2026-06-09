<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useSchedulesStore, type ScheduleEntry } from '@/stores/schedules'

const route = useRoute()
const router = useRouter()
const store = useSchedulesStore()

const scheduleId = computed(() => Number(route.params.id))

const monthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
]

const entryTypes = ['on_duty', 'off_duty', 'training', 'holiday', 'vacation', 'unavailable']

const typeLabels: Record<string, string> = {
  on_duty: 'On',
  off_duty: 'Off',
  training: 'Trn',
  holiday: 'Hol',
  vacation: 'Vac',
  unavailable: 'N/A',
}

const typeColors: Record<string, string> = {
  on_duty: '#2ec4b6',
  off_duty: '#e0e0e0',
  training: '#ffd166',
  holiday: '#a8dadc',
  vacation: '#ff9f1c',
  unavailable: '#ef476f',
}

const pilots = computed(() => {
  const map = new Map<number, { id: number; name: string; license: string }>()
  for (const e of store.entries) {
    if (!map.has(e.pilot.id)) {
      map.set(e.pilot.id, { id: e.pilot.id, name: e.pilot.name, license: e.pilot.license_number })
    }
  }
  return Array.from(map.values()).sort((a, b) => a.name.localeCompare(b.name))
})

const dates = computed(() => {
  if (!store.currentSchedule) return []
  const s = store.currentSchedule
  const start = new Date(s.year, s.month - 1, 1)
  const end = new Date(s.year, s.month, 0)
  const result: string[] = []
  for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
    result.push(d.toISOString().slice(0, 10))
  }
  return result
})

const entryMap = computed(() => {
  const map = new Map<string, ScheduleEntry>()
  for (const e of store.entries) {
    map.set(`${e.pilot.id}-${e.date}`, e)
  }
  return map
})

const dailyStats = computed(() => {
  const stats: Record<string, Record<string, number>> = {}
  for (const date of dates.value) {
    const counts: Record<string, number> = {}
    for (const pilot of pilots.value) {
      const entry = entryMap.value.get(`${pilot.id}-${date}`)
      const type = entry?.entry_type || 'off_duty'
      counts[type] = (counts[type] || 0) + 1
    }
    stats[date] = counts
  }
  return stats
})

function getEntry(pilotId: number, date: string) {
  return entryMap.value.get(`${pilotId}-${date}`)
}

function dayOfWeek(dateStr: string) {
  const d = new Date(dateStr + 'T00:00:00')
  return ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'][d.getDay()]
}

function dayNum(dateStr: string) {
  return parseInt(dateStr.slice(8))
}

function isWeekend(dateStr: string) {
  const d = new Date(dateStr + 'T00:00:00')
  return d.getDay() === 0 || d.getDay() === 6
}

async function cycleEntryType(entry: ScheduleEntry | undefined) {
  if (!entry || store.currentSchedule?.status === 'published') return
  const currentIdx = entryTypes.indexOf(entry.entry_type)
  const nextType = entryTypes[(currentIdx + 1) % entryTypes.length]
  await store.updateEntry(scheduleId.value, entry.id, nextType)
}

const actionError = ref('')

const canUnpublish = computed(() => {
  const s = store.currentSchedule
  if (!s || s.status !== 'published') return false
  const now = new Date()
  const currentYear = now.getFullYear()
  const currentMonth = now.getMonth() + 1
  if (s.year > currentYear) return true
  if (s.year === currentYear && s.month > currentMonth) return true
  return false
})

async function handlePublish() {
  actionError.value = ''
  try {
    await store.publishSchedule(scheduleId.value)
  } catch (e: any) {
    actionError.value = e.response?.data?.errors?.join(', ') || 'Failed to publish roster'
  }
}

async function handleUnpublish() {
  if (!confirm('Unpublish this roster? It will revert to draft.')) return
  actionError.value = ''
  try {
    await store.unpublishSchedule(scheduleId.value)
  } catch (e: any) {
    actionError.value = e.response?.data?.errors?.join(', ') || 'Failed to unpublish roster'
  }
}

const deleting = ref(false)

async function handleDelete() {
  if (!confirm('Delete this draft roster? This cannot be undone.')) return
  deleting.value = true
  try {
    await store.deleteSchedule(scheduleId.value)
    router.push('/shifts')
  } finally {
    deleting.value = false
  }
}

onMounted(() => store.fetchSchedule(scheduleId.value))
</script>

<template>
  <div v-if="store.loading" class="loading">Loading roster...</div>

  <div v-else-if="store.currentSchedule">
    <div class="page-header">
      <div>
        <h2>
          {{ monthNames[store.currentSchedule.month] }} {{ store.currentSchedule.year }}
          <span v-if="store.currentSchedule.name" class="roster-name">— {{ store.currentSchedule.name }}</span>
        </h2>
        <p v-if="store.currentSchedule.description" class="roster-desc">{{ store.currentSchedule.description }}</p>
        <span :class="['status-badge', `status-${store.currentSchedule.status}`]">
          {{ store.currentSchedule.status }}
        </span>
      </div>
      <div class="header-actions">
        <RouterLink to="/shifts" class="btn btn-secondary">Back</RouterLink>
        <button
          v-if="store.currentSchedule.status === 'draft'"
          class="btn btn-danger"
          :disabled="deleting"
          @click="handleDelete"
        >
          {{ deleting ? 'Deleting...' : 'Delete Draft' }}
        </button>
        <button
          v-if="canUnpublish"
          class="btn btn-warning"
          @click="handleUnpublish"
        >
          Unpublish
        </button>
        <button
          v-if="store.currentSchedule.status === 'draft'"
          class="btn btn-success"
          @click="handlePublish"
        >
          Publish
        </button>
      </div>
    </div>

    <div v-if="actionError" class="action-error">{{ actionError }}</div>

    <div class="legend">
      <span v-for="t in entryTypes" :key="t" class="legend-item">
        <span class="legend-dot" :style="{ background: typeColors[t] }"></span>
        {{ typeLabels[t] }}
      </span>
      <span v-if="store.currentSchedule.status === 'draft'" class="legend-hint">
        Click a cell to change its type
      </span>
    </div>

    <div class="grid-wrapper">
      <table class="schedule-grid">
        <thead>
          <tr>
            <th class="pilot-col">Pilot</th>
            <th
              v-for="date in dates"
              :key="date"
              :class="['date-col', { weekend: isWeekend(date) }]"
            >
              <div class="date-header">
                <span class="day-name">{{ dayOfWeek(date) }}</span>
                <span class="day-num">{{ dayNum(date) }}</span>
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pilot in pilots" :key="pilot.id">
            <td class="pilot-col">
              <RouterLink :to="`/shifts/${scheduleId}/pilot/${pilot.id}`" class="pilot-link">
                {{ pilot.name }}
              </RouterLink>
            </td>
            <td
              v-for="date in dates"
              :key="date"
              :class="['entry-cell', { weekend: isWeekend(date), clickable: store.currentSchedule?.status === 'draft' }]"
              :style="{ background: typeColors[getEntry(pilot.id, date)?.entry_type || 'off_duty'] }"
              :title="`${pilot.name} - ${date}: ${getEntry(pilot.id, date)?.entry_type || 'off_duty'}`"
              @click="cycleEntryType(getEntry(pilot.id, date))"
            >
              <span class="entry-label">{{ typeLabels[getEntry(pilot.id, date)?.entry_type || 'off_duty'] }}</span>
            </td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td class="pilot-col stats-label">Active</td>
            <td
              v-for="date in dates"
              :key="date"
              class="stats-cell"
              :class="{ weekend: isWeekend(date) }"
            >
              {{ dailyStats[date]?.on_duty || 0 }}
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<style scoped>
.loading {
  text-align: center;
  padding: 3rem;
  color: #888;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.page-header h2 {
  margin-bottom: 0.25rem;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
}

.status-badge {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 0.15rem 0.5rem;
  border-radius: 10px;
  text-transform: uppercase;
}

.roster-name {
  font-size: 1rem;
  font-weight: 400;
  color: #666;
}

.roster-desc {
  font-size: 0.85rem;
  color: #888;
  margin: 0.15rem 0 0.35rem;
}

.status-draft {
  background: #fff3cd;
  color: #856404;
}

.status-published {
  background: #d4edda;
  color: #155724;
}

.action-error {
  background: #fee;
  color: #c00;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  font-size: 0.875rem;
  margin-bottom: 1rem;
}

.legend {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  align-items: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 0.8rem;
  color: #555;
}

.legend-dot {
  width: 12px;
  height: 12px;
  border-radius: 3px;
}

.legend-hint {
  font-size: 0.75rem;
  color: #999;
  font-style: italic;
  margin-left: auto;
}

.grid-wrapper {
  overflow-x: auto;
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.schedule-grid {
  border-collapse: collapse;
  width: max-content;
  min-width: 100%;
}

.schedule-grid th,
.schedule-grid td {
  border: 1px solid #eee;
  text-align: center;
  font-size: 0.75rem;
}

.pilot-col {
  position: sticky;
  left: 0;
  background: white;
  z-index: 2;
  padding: 0.5rem 0.75rem;
  text-align: left !important;
  white-space: nowrap;
  min-width: 150px;
  font-weight: 500;
}

thead .pilot-col {
  z-index: 3;
}

.pilot-link {
  color: #4361ee;
  text-decoration: none;
}

.pilot-link:hover {
  text-decoration: underline;
}

.date-col {
  padding: 0.35rem 0;
  min-width: 38px;
}

.date-col.weekend {
  background: #f8f8f8;
}

.date-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1px;
}

.day-name {
  font-size: 0.65rem;
  color: #999;
  font-weight: 400;
}

.day-num {
  font-weight: 600;
}

.entry-cell {
  padding: 0.35rem 0;
  min-width: 38px;
  transition: filter 0.1s;
}

.entry-cell.clickable {
  cursor: pointer;
}

.entry-cell.clickable:hover {
  filter: brightness(0.9);
}

.entry-label {
  font-size: 0.65rem;
  font-weight: 600;
  color: rgba(0, 0, 0, 0.5);
}

.stats-label {
  font-weight: 600;
  color: #555;
  background: #fafafa !important;
}

.stats-cell {
  padding: 0.35rem 0;
  background: #fafafa;
  font-weight: 700;
  color: #2ec4b6;
}

.stats-cell.weekend {
  background: #f5f5f5;
}
</style>
