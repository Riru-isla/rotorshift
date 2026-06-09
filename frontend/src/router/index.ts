import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { public: true },
    },
    {
      path: '/',
      name: 'home',
      redirect: '/shifts',
    },
    {
      path: '/shifts',
      name: 'shifts',
      component: () => import('@/views/ShiftsListView.vue'),
    },
    {
      path: '/shifts/new',
      name: 'shifts-new',
      component: () => import('@/views/ShiftCreateView.vue'),
    },
    {
      path: '/shifts/:id',
      name: 'shift-detail',
      component: () => import('@/views/ShiftDetailView.vue'),
    },
    {
      path: '/shifts/:id/pilot/:pilotId',
      name: 'pilot-schedule',
      component: () => import('@/views/PilotScheduleView.vue'),
    },
    {
      path: '/pilots',
      name: 'pilots',
      component: () => import('@/views/PilotsSettingsView.vue'),
    },
    {
      path: '/my-schedule',
      name: 'my-schedule',
      component: () => import('@/views/MyScheduleView.vue'),
    },
  ],
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()

  if (auth.isAuthenticated && !auth.user) {
    await auth.fetchMe()
  }

  if (!to.meta.public && !auth.isAuthenticated) {
    return { name: 'login' }
  }

  if (to.name === 'login' && auth.isAuthenticated) {
    return { name: 'home' }
  }
})

export default router
