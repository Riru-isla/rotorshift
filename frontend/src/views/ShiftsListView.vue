<script setup lang="ts">
import { onMounted } from 'vue'
import { useSchedulesStore } from '@/stores/schedules'

const store = useSchedulesStore()

const monthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
]

function statusLabel(status: string) {
  return status.charAt(0).toUpperCase() + status.slice(1)
}

function statusClass(status: string) {
  return `status-${status}`
}

onMounted(() => store.fetchSchedules())
</script>

<template>
  <div>
    <div class="page-header">
      <h2>Shift Rosters</h2>
      <RouterLink to="/shifts/new" class="btn btn-primary">+ New Roster</RouterLink>
    </div>

    <div v-if="store.schedules.length === 0" class="card empty-state">
      <p>No rosters yet. Create your first shift roster to get started.</p>
    </div>

    <div v-else class="schedules-grid">
      <RouterLink
        v-for="s in store.schedules"
        :key="s.id"
        :to="`/shifts/${s.id}`"
        class="schedule-card card"
      >
        <div class="schedule-month">{{ monthNames[s.month] }} {{ s.year }}</div>
        <div class="schedule-meta">
          <span :class="['status-badge', statusClass(s.status)]">{{ statusLabel(s.status) }}</span>
          <span v-if="s.published_by" class="published-by">by {{ s.published_by }}</span>
        </div>
      </RouterLink>
    </div>
  </div>
</template>

<style scoped>
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.5rem;
}

h2 {
  font-size: 1.5rem;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #888;
}

.schedules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1rem;
}

.schedule-card {
  text-decoration: none;
  color: inherit;
  transition: transform 0.15s, box-shadow 0.15s;
  cursor: pointer;
}

.schedule-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.schedule-month {
  font-size: 1.2rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
}

.schedule-meta {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.status-draft {
  background: #fff3cd;
  color: #856404;
}

.status-published {
  background: #d4edda;
  color: #155724;
}

.status-archived {
  background: #e2e3e5;
  color: #383d41;
}

.published-by {
  font-size: 0.8rem;
  color: #888;
}
</style>
