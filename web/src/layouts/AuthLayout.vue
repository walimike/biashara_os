<script setup lang="ts">
import BrandLogo from '@/components/BrandLogo.vue'

defineProps<{ title: string; subtitle?: string }>()
</script>

<template>
  <div class="auth-screen">
    <div class="auth-hero">
      <BrandLogo />
      <h1>BiasharaOS</h1>
      <p>{{ subtitle || 'The business OS built for Kenyan SMEs — orders, POS & M-Pesa in one app.' }}</p>
      <div class="auth-features">
        <span class="auth-feature">OrderPad</span>
        <span class="auth-feature">POS</span>
        <span class="auth-feature">M-Pesa ready</span>
      </div>
    </div>
    <div class="auth-panel">
      <div class="auth-card">
        <h2>{{ title }}</h2>
        <slot />
      </div>
    </div>
  </div>
</template>
