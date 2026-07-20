# BiasharaOS

Modular business OS for Kenyan SMEs. MVP includes **OrderPad** (IG/DM order tracking) and **POS** (in-store sales).

## Stack

- **API** — Rails 7.2 API (`/api`)
- **Web** — Vue 3 + Vite PWA (`/web`)
- **DB** — PostgreSQL

## Quick start (local)

### 1. Database

```bash
docker compose up -d db
```

Postgres runs on **localhost:5433**.

### 2. API

```bash
cd api
cp .env.example .env
bundle install   # use Ruby 3.3.3 (rbenv)
bin/rails db:create db:migrate db:seed
bin/rails server -p 3000
```

Demo login: `demo@biashara.test` / `password123`

### 3. PWA

```bash
cd web
cp .env.example .env
npm install
npm run dev
```

Open http://localhost:5173

## API endpoints (v1)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/register` | Create org + owner |
| POST | `/api/v1/auth/login` | Login |
| GET | `/api/v1/me` | Current user/org |
| GET | `/api/v1/dashboard` | Today stats |
| CRUD | `/api/v1/products` | Product catalog |
| CRUD | `/api/v1/customers` | Customers |
| GET/POST/PATCH | `/api/v1/orders` | Orders (OrderPad + POS) |

Auth: `Authorization: Bearer <token>`

## Modules

Organizations have `enabled_modules` (jsonb): `order_pad`, `pos`, `inventory`, `invoicing`.

## Docker (development)

```bash
docker compose up --build
```

API: http://localhost:3002

## Deploy (cheapest — ~€4/month)

**One VPS runs everything:** Postgres, Rails API, Vue PWA, and free HTTPS (Caddy + Let's Encrypt).

| Provider | Cost | Notes |
|----------|------|-------|
| [Hetzner CX22](https://www.hetzner.com/cloud) | ~€3.79/mo | Recommended — simple, reliable |
| [Oracle Cloud Free](https://www.oracle.com/cloud/free/) | $0 | ARM VM, more setup |
| [DigitalOcean](https://www.digitalocean.com/pricing/droplets) | ~$6/mo | Easier docs if you're new |

### 1. Create a VPS

Ubuntu 24.04, 2 GB RAM minimum. Open ports **80** and **443**.

Install Docker on the server:

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

### 2. Point DNS at the VPS

| Record | Host | Value |
|--------|------|-------|
| A | `app` | VPS IP |
| A | `api` | VPS IP |

Example: `app.yourdomain.com` and `api.yourdomain.com`.

### 3. Deploy

On the VPS, clone the repo and run:

```bash
git clone https://github.com/walimike/biashara_os.git
cd biashara_os
cp .env.production.example .env.production
```

Edit `.env.production`:

| Variable | Example |
|----------|---------|
| `APP_DOMAIN` | `app.yourdomain.com` |
| `API_DOMAIN` | `api.yourdomain.com` |
| `VITE_API_URL` | `https://api.yourdomain.com/api/v1` |
| `CORS_ORIGINS` | `https://app.yourdomain.com` |
| `RAILS_MASTER_KEY` | output of `cat api/config/master.key` (from your machine) |
| `SECRET_KEY_BASE` | output of `cd api && bin/rails secret` |
| `DB_PASSWORD` | long random string |

```bash
chmod +x scripts/deploy-vps.sh
./scripts/deploy-vps.sh
```

- **App:** https://app.yourdomain.com
- **API health:** https://api.yourdomain.com/up

Caddy obtains and renews SSL certificates automatically.

### Updates

```bash
git pull
docker compose -f docker-compose.prod.yml --env-file .env.production up --build -d
```

GitHub repo: [walimike/biashara_os](https://github.com/walimike/biashara_os) (public)

## Roadmap

- [ ] M-Pesa STK Push
- [ ] Inventory auto-deduct on POS sale
- [ ] Offline POS queue
- [ ] KRA/eTIMS invoicing module
