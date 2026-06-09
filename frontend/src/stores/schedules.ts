import { ref } from 'vue'
import { defineStore } from 'pinia'
import api from '@/api/client'

interface Pilot {
  id: number
  name: string
  license_number: string
}

export interface ScheduleEntry {
  id: number
  date: string
  entry_type: string
  notes: string | null
  pilot: Pilot
}

export interface Schedule {
  id: number
  name: string | null
  description: string | null
  year: number
  month: number
  status: string
  published_at: string | null
  published_by: string | null
  created_at: string
}

export interface PilotProfile {
  id: number
  name: string
  email: string
  license_number: string
  shift_pattern: string
  rotation_start_date: string
  active: boolean
}

export const useSchedulesStore = defineStore('schedules', () => {
  const schedules = ref<Schedule[]>([])
  const currentSchedule = ref<Schedule | null>(null)
  const entries = ref<ScheduleEntry[]>([])
  const pilots = ref<PilotProfile[]>([])
  const loading = ref(false)

  async function fetchSchedules() {
    const { data } = await api.get('/api/v1/schedules')
    schedules.value = data
  }

  async function fetchSchedule(id: number) {
    loading.value = true
    try {
      const { data } = await api.get(`/api/v1/schedules/${id}`)
      currentSchedule.value = data.schedule
      entries.value = data.entries
    } finally {
      loading.value = false
    }
  }

  async function createSchedule(params: {
    year: number
    month: number
    name?: string
    description?: string
    minimumActive: number
    minimumOnHold: number
  }) {
    loading.value = true
    try {
      const { data } = await api.post('/api/v1/schedules', {
        year: params.year,
        month: params.month,
        name: params.name,
        description: params.description,
        auto_generate: true,
        minimum_active: params.minimumActive,
        minimum_on_hold: params.minimumOnHold,
      })
      currentSchedule.value = data.schedule
      entries.value = data.entries
      return data.schedule
    } finally {
      loading.value = false
    }
  }

  async function deleteSchedule(id: number) {
    await api.delete(`/api/v1/schedules/${id}`)
    schedules.value = schedules.value.filter((s) => s.id !== id)
  }

  async function updateEntry(scheduleId: number, entryId: number, entryType: string) {
    const { data } = await api.patch(
      `/api/v1/schedules/${scheduleId}/schedule_entries/${entryId}`,
      { entry_type: entryType },
    )
    const idx = entries.value.findIndex((e) => e.id === entryId)
    if (idx !== -1) entries.value[idx] = data
  }

  async function publishSchedule(id: number) {
    const { data } = await api.patch(`/api/v1/schedules/${id}/publish`)
    currentSchedule.value = data.schedule
  }

  async function unpublishSchedule(id: number) {
    const { data } = await api.patch(`/api/v1/schedules/${id}/unpublish`)
    currentSchedule.value = data.schedule
  }

  async function fetchPilots() {
    const { data } = await api.get('/api/v1/pilot_profiles')
    pilots.value = data
  }

  return {
    schedules,
    currentSchedule,
    entries,
    pilots,
    loading,
    fetchSchedules,
    fetchSchedule,
    createSchedule,
    deleteSchedule,
    updateEntry,
    publishSchedule,
    unpublishSchedule,
    fetchPilots,
  }
})
