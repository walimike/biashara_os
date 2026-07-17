<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import AuthLayout from '@/layouts/AuthLayout.vue'

const auth = useAuthStore()
const router = useRouter()
const email = ref('demo@biashara.test')
const password = ref('password123')

async function submit() {
  await auth.login(email.value, password.value)
  router.push('/')
}
</script>

<template>
  <AuthLayout title="Welcome back" subtitle="Run your biashara from your phone — track orders, sell in-store, know your profit.">
    <form @submit.prevent="submit">
      <div class="field">
        <label>Email</label>
        <input v-model="email" type="email" autocomplete="email" required />
      </div>
      <div class="field">
        <label>Password</label>
        <input v-model="password" type="password" autocomplete="current-password" required />
      </div>
      <p v-if="auth.error" class="error">{{ auth.error }}</p>
      <button class="btn btn-primary btn-block btn-lg" :disabled="auth.loading">
        {{ auth.loading ? 'Signing in…' : 'Sign in' }}
      </button>
    </form>
    <p class="auth-footer">New here? <RouterLink to="/register">Create your business</RouterLink></p>
  </AuthLayout>
</template>
