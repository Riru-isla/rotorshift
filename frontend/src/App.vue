<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()

async function handleSignOut() {
  await auth.signOut()
  router.push('/login')
}
</script>

<template>
  <div class="app">
    <header v-if="auth.isAuthenticated" class="app-header">
      <div class="header-left">
        <RouterLink to="/shifts" class="logo">RotorShift</RouterLink>
      </div>
      <nav class="header-nav">
        <RouterLink to="/shifts">Shifts</RouterLink>
        <RouterLink to="/pilots">Pilots</RouterLink>
        <RouterLink v-if="auth.isPilot" to="/my-schedule">My Schedule</RouterLink>
      </nav>
      <div class="header-right">
        <span class="user-name">{{ auth.fullName }}</span>
        <button class="btn-link" @click="handleSignOut">Sign out</button>
      </div>
    </header>
    <main class="app-main">
      <RouterView />
    </main>
  </div>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #f5f5f5;
  color: #1a1a1a;
}

.app-header {
  background: #1a1a2e;
  color: white;
  padding: 0 1.5rem;
  height: 56px;
  display: flex;
  align-items: center;
  gap: 2rem;
}

.header-left .logo {
  font-size: 1.25rem;
  font-weight: 700;
  color: white;
  text-decoration: none;
}

.header-nav {
  display: flex;
  gap: 1rem;
}

.header-nav a {
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  font-size: 0.9rem;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: all 0.15s;
}

.header-nav a:hover,
.header-nav a.router-link-active {
  color: white;
  background: rgba(255, 255, 255, 0.1);
}

.header-right {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.user-name {
  font-size: 0.875rem;
  opacity: 0.8;
}

.btn-link {
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.7);
  cursor: pointer;
  font-size: 0.875rem;
}

.btn-link:hover {
  color: white;
}

.app-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1.5rem;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s;
  text-decoration: none;
}

.btn-primary {
  background: #4361ee;
  color: white;
}

.btn-primary:hover {
  background: #3651d4;
}

.btn-success {
  background: #2ec4b6;
  color: white;
}

.btn-success:hover {
  background: #25a89c;
}

.btn-danger {
  background: #dc3545;
  color: white;
}

.btn-danger:hover {
  background: #c82333;
}

.btn-warning {
  background: #ffc107;
  color: #333;
}

.btn-warning:hover {
  background: #e0a800;
}

.btn-secondary {
  background: #e0e0e0;
  color: #333;
}

.btn-secondary:hover {
  background: #d0d0d0;
}

.card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}
</style>
