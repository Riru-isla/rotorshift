<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSchedulesStore } from '@/stores/schedules'

const store = useSchedulesStore()
const router = useRouter()

const now = new Date()
const year = ref(now.getFullYear())
const month = ref(now.getMonth() + 1)
const minimumActive = ref(5)
const minimumOnHold = ref(2)
const error = ref('')

const monthOptions = [
  { value: 1, label: 'January' },
  { value: 2, label: 'February' },
  { value: 3, label: 'March' },
  { value: 4, label: 'April' },
  { value: 5, label: 'May' },
  { value: 6, label: 'June' },
  { value: 7, label: 'July' },
  { value: 8, label: 'August' },
  { value: 9, label: 'September' },
  { value: 10, label: 'October' },
  { value: 11, label: 'November' },
  { value: 12, label: 'December' },
]

async function handleCreate() {
  error.value = ''
  try {
    const schedule = await store.createSchedule(
      year.value,
      month.value,
      minimumActive.value,
      minimumOnHold.value,
    )
    router.push(`/shifts/${schedule.id}`)
  } catch (e: any) {
    error.value = e.response?.data?.errors?.join(', ') || 'Failed to create roster'
  }
}
</script>

<template>
  <div>
    <div class="page-header">
      <h2>Create New Roster</h2>
    </div>

    <div class="card form-card">
      <form @submit.prevent="handleCreate">
        <div class="form-row">
          <div class="field">
            <label for="month">Month</label>
            <select id="month" v-model="month">
              <option v-for="m in monthOptions" :key="m.value" :value="m.value">{{ m.label }}</option>
            </select>
          </div>
          <div class="field">
            <label for="year">Year</label>
            <input id="year" v-model.number="year" type="number" min="2024" max="2030" />
          </div>
        </div>

        <div class="form-row">
          <div class="field">
            <label for="active">Minimum Active Pilots</label>
            <input id="active" v-model.number="minimumActive" type="number" min="1" max="50" />
            <span class="hint">Must be on duty each day</span>
          </div>
          <div class="field">
            <label for="onhold">On-Hold Pilots</label>
            <input id="onhold" v-model.number="minimumOnHold" type="number" min="0" max="20" />
            <span class="hint">Extra pilots moved from off-duty if needed</span>
          </div>
        </div>

        <div v-if="error" class="error">{{ error }}</div>

        <div class="form-actions">
          <RouterLink to="/shifts" class="btn btn-secondary">Cancel</RouterLink>
          <button type="submit" class="btn btn-primary" :disabled="store.loading">
            {{ store.loading ? 'Generating...' : 'Generate Roster' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
.form-card {
  max-width: 600px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1.25rem;
}

.field label {
  display: block;
  font-size: 0.8rem;
  font-weight: 600;
  color: #555;
  margin-bottom: 0.35rem;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.field input,
.field select {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 0.95rem;
}

.field input:focus,
.field select:focus {
  outline: none;
  border-color: #4361ee;
  box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
}

.hint {
  font-size: 0.75rem;
  color: #999;
  margin-top: 0.25rem;
  display: block;
}

.error {
  background: #fee;
  color: #c00;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  font-size: 0.875rem;
  margin-bottom: 1rem;
}

.form-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  padding-top: 0.5rem;
}

.page-header {
  margin-bottom: 1.5rem;
}
</style>
