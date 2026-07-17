<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { api, formatMoney } from '@/lib/api'
import { useAuthStore } from '@/stores/auth'

type Product = { id: number; name: string; price_cents: number }
type CartItem = Product & { quantity: number }

const auth = useAuthStore()
const products = ref<Product[]>([])
const cart = ref<CartItem[]>([])
const paymentMethod = ref<'cash' | 'mpesa'>('mpesa')
const message = ref('')

const totalCents = computed(() => cart.value.reduce((sum, item) => sum + item.price_cents * item.quantity, 0))
const itemCount = computed(() => cart.value.reduce((sum, item) => sum + item.quantity, 0))

function addToCart(product: Product) {
  const existing = cart.value.find((i) => i.id === product.id)
  if (existing) existing.quantity += 1
  else cart.value.push({ ...product, quantity: 1 })
}

function clearCart() {
  cart.value = []
}

async function checkout() {
  if (!cart.value.length) return
  message.value = ''
  await api.createOrder({
    source: 'pos',
    status: 'completed',
    payment_method: paymentMethod.value,
    payment_status: 'paid',
    order_items_attributes: cart.value.map((item) => ({
      product_id: item.id,
      name: item.name,
      quantity: item.quantity,
      unit_price_cents: item.price_cents
    }))
  })
  cart.value = []
  message.value = `Sale complete · ${formatMoney(totalCents.value, auth.organization?.currency)}`
  setTimeout(() => { message.value = '' }, 2500)
}

onMounted(async () => {
  products.value = await api.products() as Product[]
})
</script>

<template>
  <div class="pos-layout">
    <div>
      <div class="product-grid">
        <button
          v-for="product in products"
          :key="product.id"
          type="button"
          class="product-tile"
          @click="addToCart(product)"
        >
          <span class="product-tile-name">{{ product.name }}</span>
          <span class="product-tile-price">{{ formatMoney(product.price_cents, auth.organization?.currency) }}</span>
        </button>
      </div>
      <p v-if="!products.length" class="muted" style="margin-top:1rem">No products yet — add some via the API seed or admin.</p>
    </div>

    <div class="card card-elevated desktop-cart">
      <h3 style="margin:0 0 0.75rem">Cart · {{ itemCount }} items</h3>
      <div v-if="!cart.length" class="muted">Tap a product to start a sale</div>
      <div v-for="item in cart" :key="item.id" class="order-card-meta" style="display:flex;justify-content:space-between;padding:0.35rem 0">
        <span>{{ item.name }} × {{ item.quantity }}</span>
        <strong>{{ formatMoney(item.price_cents * item.quantity, auth.organization?.currency) }}</strong>
      </div>
      <hr style="border:none;border-top:1px solid var(--border);margin:0.75rem 0" />
      <div style="display:flex;justify-content:space-between;font-weight:800;font-size:1.1rem">
        <span>Total</span>
        <span>{{ formatMoney(totalCents, auth.organization?.currency) }}</span>
      </div>
      <div class="field" style="margin-top:1rem">
        <label>Payment</label>
        <select v-model="paymentMethod">
          <option value="mpesa">M-Pesa</option>
          <option value="cash">Cash</option>
        </select>
      </div>
      <div style="display:grid;gap:0.5rem;margin-top:0.75rem">
        <button class="btn btn-primary btn-block btn-lg" :disabled="!cart.length" @click="checkout">Complete sale</button>
        <button v-if="cart.length" class="btn btn-secondary btn-block" type="button" @click="clearCart">Clear cart</button>
      </div>
      <p v-if="message" class="success-toast" style="margin-top:0.75rem">{{ message }}</p>
    </div>
  </div>

  <div v-if="cart.length" class="pos-cart-bar">
    <div>
      <strong>{{ itemCount }} items</strong>
      <div class="muted">{{ formatMoney(totalCents, auth.organization?.currency) }}</div>
    </div>
    <button class="btn btn-primary" @click="checkout">Pay</button>
  </div>
</template>

<style scoped>
.desktop-cart { display: none; }
@media (min-width: 900px) {
  .desktop-cart { display: block; }
  .pos-cart-bar { display: none !important; }
}
</style>
