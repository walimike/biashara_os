import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', component: () => import('@/views/LoginView.vue'), meta: { guest: true } },
    { path: '/register', component: () => import('@/views/RegisterView.vue'), meta: { guest: true } },
    { path: '/', component: () => import('@/views/DashboardView.vue') },
    { path: '/order-pad', component: () => import('@/views/OrderPadView.vue') },
    { path: '/pos', component: () => import('@/views/PosView.vue') }
  ]
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  if (!auth.user && auth.token) await auth.bootstrap()
  if (!auth.isAuthenticated && !to.meta.guest) return '/login'
  if (auth.isAuthenticated && to.meta.guest) return '/'
})

export default router
