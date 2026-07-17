<script setup lang="ts">
import { RouterView } from 'vue-router'
import AppShell from '@/components/AppShell.vue'
import { useAuthStore } from '@/stores/auth'
import { onMounted } from 'vue'

const auth = useAuthStore()
onMounted(() => auth.bootstrap())
</script>

<template>
  <AppShell v-if="auth.isAuthenticated">
    <RouterView />
  </AppShell>
  <RouterView v-else />
</template>
