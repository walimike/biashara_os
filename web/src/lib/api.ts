const API_URL = import.meta.env.VITE_API_URL

export class ApiError extends Error {
  status: number
  constructor(message: string, status: number) {
    super(message)
    this.status = status
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = localStorage.getItem('biashara_token')
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string> | undefined)
  }
  if (token) headers.Authorization = `Bearer ${token}`

  const response = await fetch(`${API_URL}${path}`, { ...options, headers })
  if (!response.ok) {
    const body = await response.json().catch(() => ({}))
    throw new ApiError(body.error || 'Request failed', response.status)
  }
  if (response.status === 204) return undefined as T
  return response.json()
}

export const api = {
  register: (payload: unknown) => request('/auth/register', { method: 'POST', body: JSON.stringify(payload) }),
  login: (payload: unknown) => request('/auth/login', { method: 'POST', body: JSON.stringify(payload) }),
  me: () => request('/me'),
  dashboard: () => request('/dashboard'),
  products: () => request('/products?active_only=true'),
  customers: (q?: string) => request(`/customers${q ? `?q=${encodeURIComponent(q)}` : ''}`),
  createCustomer: (payload: unknown) => request('/customers', { method: 'POST', body: JSON.stringify({ customer: payload }) }),
  orders: (params?: Record<string, string>) => {
    const query = params ? `?${new URLSearchParams(params)}` : ''
    return request(`/orders${query}`)
  },
  createOrder: (payload: unknown) => request('/orders', { method: 'POST', body: JSON.stringify({ order: payload }) }),
  updateOrder: (id: number, payload: unknown) => request(`/orders/${id}`, { method: 'PATCH', body: JSON.stringify({ order: payload }) })
}

export function formatMoney(cents: number, currency = 'KES') {
  return new Intl.NumberFormat('en-KE', { style: 'currency', currency, minimumFractionDigits: 0 }).format(cents / 100)
}
