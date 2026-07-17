<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import BrandLogo from '@/components/BrandLogo.vue'

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()

const tabs = [
  { to: '/', label: 'Home', icon: '🏠' },
  { to: '/order-pad', label: 'Orders', icon: '📦' },
  { to: '/pos', label: 'POS', icon: '🛒' }
]

const title = computed(() => {
  if (route.path === '/order-pad') return 'OrderPad'
  if (route.path === '/pos') return 'POS'
  return 'Dashboard'
})

function logout() {
  auth.logout()
  router.push('/login')
}
</script>

<template>
  <div class="shell">
    <header class="topbar">
      <div class="brand">
        <BrandLogo />
        <div>
          <strong>BiasharaOS</strong>
          <span>{{ auth.organization?.name }}</span>
        </div>
      </div>
      <button class="btn btn-ghost" @click="logout">Logout</button>
    </header>

    <main class="container">
      <div class="page-header">
        <h1>{{ title }}</h1>
        <p v-if="route.path === '/'">Today's snapshot for your biashara</p>
        <p v-else-if="route.path === '/order-pad'">Track IG & WhatsApp orders</p>
        <p v-else-if="route.path === '/pos'">Fast checkout for your shop</p>
      </div>
      <slot />
    </main>

    <nav class="bottom-nav" aria-label="Main">
      <RouterLink v-for="tab in tabs" :key="tab.to" :to="tab.to" class="nav-item">
        <span class="nav-icon">{{ tab.icon }}</span>
        <span>{{ tab.label }}</span>
      </RouterLink>
    </nav>
  </div>
</template>

<style scoped>
.shell {
  min-height: 100vh;
  background: var(--bg);
}
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.85rem 1rem;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  position: sticky;
  top: 0;
  z-index: 30;
}
.brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}
.brand strong {
  display: block;
  font-size: 0.95rem;
  letter-spacing: -0.02em;
}
.brand span {
  display: block;
  font-size: 0.75rem;
  color: var(--muted);
  max-width: 160px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.bottom-nav {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  height: calc(var(--nav-height) + var(--safe-bottom));
  padding-bottom: var(--safe-bottom);
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  background: rgba(255, 255, 255, 0.96);
  backdrop-filter: blur(12px);
  border-top: 1px solid var(--border);
  z-index: 40;
}
.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.15rem;
  color: var(--muted);
  font-size: 0.72rem;
  font-weight: 700;
}
.nav-icon { font-size: 1.15rem; line-height: 1; }
.nav-item.router-link-active {
  color: var(--brand-dark);
}
</style>
