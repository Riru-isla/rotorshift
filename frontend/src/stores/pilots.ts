import { ref } from 'vue'
import { defineStore } from 'pinia'
import api from '@/api/client'

export interface ShiftPattern {
  id: number
  name: string
  days_on: number
  days_off: number
  cycle_length: number
  active: boolean
  pilot_count: number
}

export interface Pilot {
  id: number
  name: string
  email: string
  license_number: string
  shift_pattern_id: number
  shift_pattern: string
  rotation_start_date: string
  active: boolean
}

export const usePilotsStore = defineStore('pilots', () => {
  const pilots = ref<Pilot[]>([])
  const patterns = ref<ShiftPattern[]>([])
  const loading = ref(false)

  async function fetchPilots() {
    const { data } = await api.get('/api/v1/pilot_profiles')
    pilots.value = data
  }

  async function updatePilot(id: number, params: Partial<Pick<Pilot, 'shift_pattern_id' | 'rotation_start_date' | 'active'>>) {
    const { data } = await api.patch(`/api/v1/pilot_profiles/${id}`, params)
    const idx = pilots.value.findIndex((p) => p.id === id)
    if (idx !== -1) pilots.value[idx] = data
    return data
  }

  async function fetchPatterns() {
    const { data } = await api.get('/api/v1/shift_patterns')
    patterns.value = data
  }

  async function createPattern(params: { name: string; days_on: number; days_off: number }) {
    const { data } = await api.post('/api/v1/shift_patterns', params)
    patterns.value.push(data)
    return data
  }

  async function updatePattern(id: number, params: Partial<Pick<ShiftPattern, 'name' | 'days_on' | 'days_off' | 'active'>>) {
    const { data } = await api.patch(`/api/v1/shift_patterns/${id}`, params)
    const idx = patterns.value.findIndex((p) => p.id === id)
    if (idx !== -1) patterns.value[idx] = data
    return data
  }

  async function deletePattern(id: number) {
    await api.delete(`/api/v1/shift_patterns/${id}`)
    patterns.value = patterns.value.filter((p) => p.id !== id)
  }

  return {
    pilots,
    patterns,
    loading,
    fetchPilots,
    updatePilot,
    fetchPatterns,
    createPattern,
    updatePattern,
    deletePattern,
  }
})
