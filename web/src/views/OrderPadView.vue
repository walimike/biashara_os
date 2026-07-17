<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { api, formatMoney } from '@/lib/api'
import { useAuthStore } from '@/stores/auth'

type Customer = { id: number; name: string; phone?: string }
type Order = {
  id: number
  order_number: string
  total_cents: number
  payment_status: string
  customer?: Customer
  notes?: string
}

const auth = useAuthStore()
const orders = ref<Order[]>([])
const customerName = ref('')
const customerPhone = ref('')
const itemName = ref('')
const price = ref('')
const notes = ref('')
const error = ref('')
const saved = ref(false)

async function load() {
  orders.value = await api.orders({ source: 'order_pad', limit: '20' }) as Order[]
}

async function createOrder() {
  error.value = ''
  saved.value = false
  try {
    let customerId: number | undefined
    if (customerName.value.trim()) {
      const customer = await api.createCustomer({
        name: customerName.value.trim(),
        phone: customerPhone.value.trim() || undefined
      }) as Customer
      customerId = customer.id
    }
    await api.createOrder({
      source: 'order_pad',
      status: 'pending',
      payment_status: 'unpaid',
      customer_id: customerId,
      notes: notes.value || undefined,
      order_items_attributes: [{
        name: itemName.value.trim(),
        quantity: 1,
        unit_price_cents: Math.round(parseFloat(price.value) * 100)
      }]
    })
    customerName.value = ''
    customerPhone.value = ''
    itemName.value = ''
    price.value = ''
    notes.value = ''
    saved.value = true
    await load()
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Failed to create order'
  }
}

async function markPaid(order: Order) {
  await api.updateOrder(order.id, { payment_status: 'paid', payment_method: 'mpesa' })
  await load()
}

onMounted(load)
</script>

<template>
  <div class="grid-2" style="align-items:start">
    <div class="card card-elevated">
      <form @submit.prevent="createOrder">
        <div class="field"><label>Customer</label><input v-model="customerName" placeholder="Jane Wanjiku" /></div>
        <div class="field"><label>Phone</label><input v-model="customerPhone" placeholder="07xx xxx xxx" inputmode="tel" /></div>
        <div class="field"><label>Item</label><input v-model="itemName" placeholder="Blue dress, size M" required /></div>
        <div class="field"><label>Price (KES)</label><input v-model="price" type="number" min="0" step="1" placeholder="1500" required /></div>
        <div class="field"><label>Notes</label><textarea v-model="notes" rows="2" placeholder="Paid via M-Pesa? Delivery?" /></div>
        <p v-if="error" class="error">{{ error }}</p>
        <p v-if="saved" class="success-toast">Order saved ✓</p>
        <button class="btn btn-primary btn-block btn-lg">Save order</button>
      </form>
    </div>

    <div class="card">
      <h3 style="margin:0 0 0.75rem;font-size:1rem">Recent orders</h3>
      <div v-if="!orders.length" class="muted">No orders yet — add your first IG order above.</div>
      <article v-for="order in orders" :key="order.id" class="order-card">
        <div class="order-card-top">
          <div>
            <div class="order-card-id">{{ order.order_number }}</div>
            <div class="order-card-meta">
              {{ order.customer?.name || 'Walk-in' }} · {{ formatMoney(order.total_cents, auth.organization?.currency) }}
            </div>
            <div v-if="order.notes" class="order-card-notes">{{ order.notes }}</div>
          </div>
          <span :class="['badge', order.payment_status === 'paid' ? 'badge-paid' : 'badge-unpaid']">
            {{ order.payment_status }}
          </span>
        </div>
        <div v-if="order.payment_status !== 'paid'" class="order-card-actions">
          <button class="btn btn-secondary" @click="markPaid(order)">Mark M-Pesa paid</button>
        </div>
      </article>
    </div>
  </div>
</template>
