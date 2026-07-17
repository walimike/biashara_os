<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { api, formatMoney } from '@/lib/api'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const stats = ref<{ today: { orders_count: number; revenue_cents: number; unpaid_orders_count: number } } | null>(null)

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return 'Good morning'
  if (hour < 17) return 'Good afternoon'
  return 'Good evening'
})

onMounted(async () => {
  stats.value = await api.dashboard() as typeof stats.value
})
</script>

<template>
  <div>
    <p class="muted" style="margin:0 0 1rem;font-weight:600">
      {{ greeting }}, {{ auth.user?.name?.split(' ')[0] || 'there' }} 👋
    </p>

    <div class="stat-grid">
      <div class="stat-card hero">
        <div class="stat-label">Today's revenue</div>
        <div class="stat-value">
          {{ stats ? formatMoney(stats.today.revenue_cents, auth.organization?.currency) : '—' }}
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Orders</div>
        <div class="stat-value">{{ stats?.today.orders_count ?? '—' }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Unpaid</div>
        <div class="stat-value">{{ stats?.today.unpaid_orders_count ?? '—' }}</div>
      </div>
    </div>

    <div class="quick-actions">
      <RouterLink to="/order-pad" class="quick-action">
        <strong>📦 OrderPad</strong>
        <span>Log IG & DM orders</span>
      </RouterLink>
      <RouterLink to="/pos" class="quick-action">
        <strong>🛒 POS</strong>
        <span>Checkout in-store</span>
      </RouterLink>
    </div>

    <div class="card" style="margin-top:1rem">
      <div class="stat-label">Active modules</div>
      <p style="margin:0.5rem 0 0">
        <span
          v-for="mod in auth.organization?.enabled_modules"
          :key="mod"
          class="badge badge-module"
          style="margin-right:0.35rem"
        >{{ mod.replace('_', ' ') }}</span>
      </p>
    </div>
  </div>
</template>
