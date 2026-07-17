<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import AuthLayout from '@/layouts/AuthLayout.vue'

const auth = useAuthStore()
const router = useRouter()
const businessName = ref('')
const name = ref('')
const email = ref('')
const password = ref('')

async function submit() {
  await auth.register({
    organization: { name: businessName.value },
    user: { name: name.value, email: email.value, password: password.value, password_confirmation: password.value }
  })
  router.push('/')
}
</script>

<template>
  <AuthLayout title="Start free" subtitle="Set up OrderPad & POS in under 2 minutes. Built for Nairobi vendors, salons & shops.">
    <form @submit.prevent="submit">
      <div class="field"><label>Business name</label><input v-model="businessName" placeholder="e.g. Nia Styles" required /></div>
      <div class="field"><label>Your name</label><input v-model="name" required /></div>
      <div class="field"><label>Email</label><input v-model="email" type="email" required /></div>
      <div class="field"><label>Password</label><input v-model="password" type="password" minlength="8" required /></div>
      <p v-if="auth.error" class="error">{{ auth.error }}</p>
      <button class="btn btn-primary btn-block btn-lg" :disabled="auth.loading">
        {{ auth.loading ? 'Creating…' : 'Create workspace' }}
      </button>
    </form>
    <p class="auth-footer">Already have an account? <RouterLink to="/login">Sign in</RouterLink></p>
  </AuthLayout>
</template>
