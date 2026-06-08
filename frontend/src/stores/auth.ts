import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import api from '@/api/client'

interface User {
  id: number
  email: string
  first_name: string
  last_name: string
  organization_id: number
  roles: string[]
  pilot_profile?: { id: number; license_number: string; active: boolean } | null
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))

  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.roles.includes('admin') ?? false)
  const isPilot = computed(() => !!user.value?.pilot_profile)
  const fullName = computed(() =>
    user.value ? `${user.value.first_name} ${user.value.last_name}` : '',
  )

  async function signIn(email: string, password: string) {
    const { data } = await api.post('/api/v1/auth/sign_in', { user: { email, password } })
    token.value = data.token
    user.value = data.user
    localStorage.setItem('token', data.token)
  }

  async function signOut() {
    try {
      await api.delete('/api/v1/auth/sign_out')
    } finally {
      token.value = null
      user.value = null
      localStorage.removeItem('token')
    }
  }

  async function fetchMe() {
    if (!token.value) return
    try {
      const { data } = await api.get('/api/v1/me')
      user.value = data.user
    } catch {
      token.value = null
      localStorage.removeItem('token')
    }
  }

  return { user, token, isAuthenticated, isAdmin, isPilot, fullName, signIn, signOut, fetchMe }
})
