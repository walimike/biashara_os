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

## Deploy (production)

The monorepo deploys as **two independent services** from one GitHub repo — Rails API and Vue PWA — so you can host them on separate platforms (e.g. Render + Cloudflare Pages, or both on a VPS).

### Option A — Docker Compose (VPS / single server)

```bash
cp .env.production.example .env.production
# Fill in RAILS_MASTER_KEY, SECRET_KEY_BASE, and public URLs

docker compose -f docker-compose.prod.yml --env-file .env.production up --build -d
```

- PWA: http://localhost:8080 (or `WEB_PORT`)
- API: http://localhost:3000 (or `API_PORT`)

Set `VITE_API_URL` to the **browser-facing** API URL before building the web image. Set `CORS_ORIGINS` to the **public PWA URL**.

### Option B — Split hosting

| Service | Build | Typical hosts |
|---------|-------|---------------|
| **API** | `api/Dockerfile` | Render, Railway, Fly.io, Kamal |
| **Web** | `web/Dockerfile` | Any static host, or nginx container |

Web build arg: `VITE_API_URL=https://api.yourdomain.com/api/v1`

API env: `DATABASE_URL`, `RAILS_MASTER_KEY`, `SECRET_KEY_BASE`, `CORS_ORIGINS`

GitHub repo: [walimike/biashara_os](https://github.com/walimike/biashara_os) (private)

## Roadmap

- [ ] M-Pesa STK Push
- [ ] Inventory auto-deduct on POS sale
- [ ] Offline POS queue
- [ ] KRA/eTIMS invoicing module
