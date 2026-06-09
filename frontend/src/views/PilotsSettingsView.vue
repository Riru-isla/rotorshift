<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { usePilotsStore } from '@/stores/pilots'

const store = usePilotsStore()

const newPatternName = ref('')
const newDaysOn = ref(7)
const newDaysOff = ref(7)
const patternError = ref('')
const editingPilotId = ref<number | null>(null)
const editPatternId = ref<number | null>(null)
const editRotationDate = ref('')

function startEdit(pilot: { id: number; shift_pattern_id: number; rotation_start_date: string }) {
  editingPilotId.value = pilot.id
  editPatternId.value = pilot.shift_pattern_id
  editRotationDate.value = pilot.rotation_start_date
}

function cancelEdit() {
  editingPilotId.value = null
}

async function saveEdit(pilotId: number) {
  await store.updatePilot(pilotId, {
    shift_pattern_id: editPatternId.value!,
    rotation_start_date: editRotationDate.value,
  })
  editingPilotId.value = null
  await store.fetchPatterns()
}

async function togglePilotActive(pilot: { id: number; active: boolean }) {
  await store.updatePilot(pilot.id, { active: !pilot.active })
}

async function createPattern() {
  patternError.value = ''
  try {
    await store.createPattern({
      name: newPatternName.value,
      days_on: newDaysOn.value,
      days_off: newDaysOff.value,
    })
    newPatternName.value = ''
    newDaysOn.value = 7
    newDaysOff.value = 7
  } catch (e: any) {
    patternError.value = e.response?.data?.errors?.join(', ') || 'Failed to create pattern'
  }
}

async function deletePattern(id: number) {
  try {
    await store.deletePattern(id)
  } catch (e: any) {
    patternError.value = e.response?.data?.errors?.join(', ') || 'Cannot delete pattern'
  }
}

onMounted(async () => {
  store.loading = true
  await Promise.all([store.fetchPilots(), store.fetchPatterns()])
  store.loading = false
})
</script>

<template>
  <div v-if="store.loading" class="loading">Loading...</div>

  <div v-else>
    <h2>Pilot Schedules</h2>
    <p class="page-subtitle">Manage shift patterns and assign them to pilots.</p>

    <section class="section">
      <h3>Shift Patterns</h3>

      <div class="patterns-grid">
        <div v-for="p in store.patterns" :key="p.id" class="pattern-card card">
          <div class="pattern-header">
            <strong>{{ p.name }}</strong>
            <span class="pattern-cycle">{{ p.days_on }} on / {{ p.days_off }} off</span>
          </div>
          <div class="pattern-meta">
            <span class="pilot-count">{{ p.pilot_count }} pilot{{ p.pilot_count !== 1 ? 's' : '' }}</span>
            <span :class="['active-badge', p.active ? 'active' : 'inactive']">
              {{ p.active ? 'Active' : 'Inactive' }}
            </span>
          </div>
          <button
            v-if="p.pilot_count === 0"
            class="btn-delete"
            @click="deletePattern(p.id)"
          >
            Delete
          </button>
        </div>

        <div class="pattern-card card new-pattern">
          <strong>New Pattern</strong>
          <div class="new-pattern-form">
            <input v-model="newPatternName" type="text" placeholder="Name (e.g. Standard)" class="input-sm" />
            <div class="days-inputs">
              <label>
                On
                <input v-model.number="newDaysOn" type="number" min="1" max="60" class="input-sm input-num" />
              </label>
              <label>
                Off
                <input v-model.number="newDaysOff" type="number" min="1" max="60" class="input-sm input-num" />
              </label>
            </div>
            <button
              class="btn btn-primary btn-sm"
              :disabled="!newPatternName.trim()"
              @click="createPattern"
            >
              Add
            </button>
          </div>
          <div v-if="patternError" class="error-sm">{{ patternError }}</div>
        </div>
      </div>
    </section>

    <section class="section">
      <h3>Pilots</h3>

      <div class="table-wrapper card">
        <table class="pilots-table">
          <thead>
            <tr>
              <th>Pilot</th>
              <th>Email</th>
              <th>License</th>
              <th>Pattern</th>
              <th>Rotation Start</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="pilot in store.pilots" :key="pilot.id" :class="{ inactive: !pilot.active }">
              <td class="pilot-name">{{ pilot.name }}</td>
              <td>{{ pilot.email }}</td>
              <td>{{ pilot.license_number || '—' }}</td>

              <template v-if="editingPilotId === pilot.id">
                <td>
                  <select v-model="editPatternId" class="input-sm">
                    <option v-for="p in store.patterns" :key="p.id" :value="p.id">
                      {{ p.name }} ({{ p.days_on }}/{{ p.days_off }})
                    </option>
                  </select>
                </td>
                <td>
                  <input v-model="editRotationDate" type="date" class="input-sm" />
                </td>
                <td>
                  <button class="btn-toggle" @click="togglePilotActive(pilot)">
                    {{ pilot.active ? 'Active' : 'Inactive' }}
                  </button>
                </td>
                <td class="actions">
                  <button class="btn btn-primary btn-sm" @click="saveEdit(pilot.id)">Save</button>
                  <button class="btn btn-secondary btn-sm" @click="cancelEdit">Cancel</button>
                </td>
              </template>

              <template v-else>
                <td>
                  <span class="pattern-badge">{{ pilot.shift_pattern }}</span>
                </td>
                <td>{{ pilot.rotation_start_date }}</td>
                <td>
                  <span :class="['active-badge', pilot.active ? 'active' : 'inactive']">
                    {{ pilot.active ? 'Active' : 'Inactive' }}
                  </span>
                </td>
                <td class="actions">
                  <button class="btn btn-secondary btn-sm" @click="startEdit(pilot)">Edit</button>
                </td>
              </template>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<style scoped>
.loading {
  text-align: center;
  padding: 3rem;
  color: #888;
}

h2 {
  margin-bottom: 0.25rem;
}

.page-subtitle {
  color: #888;
  font-size: 0.9rem;
  margin-bottom: 1.5rem;
}

.section {
  margin-bottom: 2rem;
}

.section h3 {
  font-size: 1.1rem;
  margin-bottom: 0.75rem;
  color: #333;
}

.patterns-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 0.75rem;
}

.pattern-card {
  padding: 1rem;
}

.pattern-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.pattern-cycle {
  font-size: 0.8rem;
  color: #888;
  font-weight: 500;
}

.pattern-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pilot-count {
  font-size: 0.8rem;
  color: #888;
}

.active-badge {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 0.15rem 0.5rem;
  border-radius: 10px;
  text-transform: uppercase;
}

.active-badge.active {
  background: #d4edda;
  color: #155724;
}

.active-badge.inactive {
  background: #e2e3e5;
  color: #383d41;
}

.btn-delete {
  margin-top: 0.5rem;
  background: none;
  border: none;
  color: #ef476f;
  font-size: 0.8rem;
  cursor: pointer;
  padding: 0;
}

.btn-delete:hover {
  text-decoration: underline;
}

.new-pattern {
  border: 2px dashed #ddd;
  box-shadow: none;
}

.new-pattern-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.days-inputs {
  display: flex;
  gap: 0.75rem;
}

.days-inputs label {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 0.8rem;
  color: #555;
}

.input-sm {
  padding: 0.35rem 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.85rem;
}

.input-sm:focus {
  outline: none;
  border-color: #4361ee;
  box-shadow: 0 0 0 2px rgba(67, 97, 238, 0.1);
}

.input-num {
  width: 60px;
}

.error-sm {
  font-size: 0.8rem;
  color: #ef476f;
  margin-top: 0.25rem;
}

.table-wrapper {
  padding: 0;
  overflow-x: auto;
}

.pilots-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.pilots-table th {
  text-align: left;
  padding: 0.65rem 0.75rem;
  background: #fafafa;
  font-size: 0.75rem;
  font-weight: 600;
  color: #555;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  border-bottom: 1px solid #eee;
}

.pilots-table td {
  padding: 0.55rem 0.75rem;
  border-bottom: 1px solid #f5f5f5;
}

.pilots-table tr:last-child td {
  border-bottom: none;
}

.pilots-table tr.inactive {
  opacity: 0.5;
}

.pilot-name {
  font-weight: 500;
}

.pattern-badge {
  background: #e8f0fe;
  color: #4361ee;
  font-size: 0.8rem;
  font-weight: 600;
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
}

.btn-toggle {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 0.8rem;
  color: #4361ee;
  text-decoration: underline;
}

.actions {
  display: flex;
  gap: 0.35rem;
}

.btn-sm {
  padding: 0.3rem 0.6rem;
  font-size: 0.8rem;
}
</style>
