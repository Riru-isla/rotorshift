<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useSchedulesStore } from '@/stores/schedules'

const route = useRoute()
const store = useSchedulesStore()

const scheduleId = computed(() => Number(route.params.id))
const pilotId = computed(() => Number(route.params.pilotId))

const monthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
]

const typeLabels: Record<string, string> = {
  on_duty: 'On Duty',
  off_duty: 'Off Duty',
  training: 'Training',
  holiday: 'Holiday',
  vacation: 'Vacation',
  unavailable: 'Unavailable',
}

const typeColors: Record<string, string> = {
  on_duty: '#2ec4b6',
  off_duty: '#e0e0e0',
  training: '#ffd166',
  holiday: '#a8dadc',
  vacation: '#ff9f1c',
  unavailable: '#ef476f',
}

const pilotEntries = computed(() =>
  store.entries
    .filter((e) => e.pilot.id === pilotId.value)
    .sort((a, b) => a.date.localeCompare(b.date)),
)

const pilotName = computed(() => pilotEntries.value[0]?.pilot.name || 'Pilot')

const stats = computed(() => {
  const counts: Record<string, number> = {}
  for (const e of pilotEntries.value) {
    counts[e.entry_type] = (counts[e.entry_type] || 0) + 1
  }
  return counts
})

function dayOfWeek(dateStr: string) {
  const d = new Date(dateStr + 'T00:00:00')
  return ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][d.getDay()]
}

function isWeekend(dateStr: string) {
  const d = new Date(dateStr + 'T00:00:00')
  return d.getDay() === 0 || d.getDay() === 6
}

onMounted(() => store.fetchSchedule(scheduleId.value))
</script>

<template>
  <div v-if="store.loading" class="loading">Loading schedule...</div>

  <div v-else-if="store.currentSchedule">
    <div class="page-header">
      <div>
        <h2>{{ pilotName }}</h2>
        <p class="subtitle">
          {{ monthNames[store.currentSchedule.month] }} {{ store.currentSchedule.year }}
        </p>
      </div>
      <RouterLink :to="`/shifts/${scheduleId}`" class="btn btn-secondary">Back to Roster</RouterLink>
    </div>

    <div class="stats-row">
      <div
        v-for="(count, type) in stats"
        :key="type"
        class="stat-card"
        :style="{ borderLeftColor: typeColors[type as string] }"
      >
        <span class="stat-count">{{ count }}</span>
        <span class="stat-label">{{ typeLabels[type as string] || type }}</span>
      </div>
    </div>

    <div class="schedule-list card">
      <div
        v-for="entry in pilotEntries"
        :key="entry.id"
        :class="['day-row', { weekend: isWeekend(entry.date) }]"
      >
        <div class="day-date">
          <span class="day-name">{{ dayOfWeek(entry.date) }}</span>
          <span class="day-num">{{ entry.date }}</span>
        </div>
        <span
          class="day-type"
          :style="{ background: typeColors[entry.entry_type], color: entry.entry_type === 'off_duty' ? '#555' : '#fff' }"
        >
          {{ typeLabels[entry.entry_type] }}
        </span>
      </div>
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
  margin-bottom: 1.5rem;
}

.page-header h2 {
  margin-bottom: 0.15rem;
}

.subtitle {
  color: #888;
  font-size: 0.9rem;
}

.stats-row {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.stat-card {
  background: white;
  padding: 0.75rem 1rem;
  border-radius: 6px;
  border-left: 3px solid;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  min-width: 100px;
}

.stat-count {
  font-size: 1.5rem;
  font-weight: 700;
  color: #333;
}

.stat-label {
  font-size: 0.75rem;
  color: #888;
  text-transform: uppercase;
}

.schedule-list {
  padding: 0;
  overflow: hidden;
}

.day-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.65rem 1.25rem;
  border-bottom: 1px solid #f0f0f0;
}

.day-row:last-child {
  border-bottom: none;
}

.day-row.weekend {
  background: #fafafa;
}

.day-date {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.day-name {
  font-size: 0.8rem;
  color: #888;
  width: 80px;
}

.day-num {
  font-weight: 500;
  font-size: 0.9rem;
}

.day-type {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
}
</style>
