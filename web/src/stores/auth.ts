import { defineStore } from 'pinia'
import { api } from '@/lib/api'

type User = { id: number; name: string; email: string; role: string }
type Organization = {
  id: number
  name: string
  slug: string
  currency: string
  plan: string
  enabled_modules: string[]
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('biashara_token') || '',
    user: null as User | null,
    organization: null as Organization | null,
    loading: false,
    error: ''
  }),
  getters: {
    isAuthenticated: (s) => !!s.token
  },
  actions: {
    async bootstrap() {
      if (!this.token) return
      try {
        const data = await api.me() as { user: User; organization: Organization }
        this.user = data.user
        this.organization = data.organization
      } catch {
        this.logout()
      }
    },
    async login(email: string, password: string) {
      this.loading = true
      this.error = ''
      try {
        const data = await api.login({ email, password }) as { token: string; user: User; organization: Organization }
        this.token = data.token
        this.user = data.user
        this.organization = data.organization
        localStorage.setItem('biashara_token', data.token)
      } catch (e: unknown) {
        this.error = e instanceof Error ? e.message : 'Login failed'
        throw e
      } finally {
        this.loading = false
      }
    },
    async register(payload: { organization: { name: string }; user: { name: string; email: string; password: string; password_confirmation: string } }) {
      this.loading = true
      this.error = ''
      try {
        const data = await api.register(payload) as { token: string; user: User; organization: Organization }
        this.token = data.token
        this.user = data.user
        this.organization = data.organization
        localStorage.setItem('biashara_token', data.token)
      } catch (e: unknown) {
        this.error = e instanceof Error ? e.message : 'Registration failed'
        throw e
      } finally {
        this.loading = false
      }
    },
    logout() {
      this.token = ''
      this.user = null
      this.organization = null
      localStorage.removeItem('biashara_token')
    }
  }
})
