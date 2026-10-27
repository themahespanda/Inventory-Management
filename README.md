# SmartStock AI ? Intelligent Inventory Management Agent

An autonomous AI agent for real-time inventory monitoring, threshold reasoning, and automated multi-channel reorder execution.

[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.7-blue.svg)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-18.3-cyan.svg)](https://react.dev/)
[![TailwindCSS](https://img.shields.io/badge/Tailwind-3.4-38bdf8.svg)](https://tailwindcss.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)

---

## 1. Project Overview

**SmartStock AI** demonstrates how autonomous AI agents operate beyond simple chatbots. By implementing the classical agent paradigm:

$$\text{SENSORS} \longrightarrow \text{PERCEPTION} \longrightarrow \text{REASONING} \longrightarrow \text{ACTION} \longrightarrow \text{ACTUATORS}$$

the system autonomously senses physical stock levels, normalizes and validates telemetry, calculates dynamic safety thresholds based on supplier lead times and burn rates, issues mathematically reasoned reorder requisitions, and triggers multi-channel actuators via **WhatsApp** and **Email**.

Designed for high-impact college and production demonstrations, the system works completely out-of-the-box in **Zero-Configuration Demo Mode** while offering full production-grade connectivity to **Twilio WhatsApp / Meta WhatsApp Cloud API**, **Resend Email**, and **Supabase PostgreSQL**.

---

## 2. Core AI Agent Architecture

```
                 ?????????????????
                 ?    SENSORS    ?
                 ? Stock / Input ?
                 ?????????????????
                         ?
                 ?????????????????
                 ?  PERCEPTION   ?
                 ? Validate data ?
                 ? Normalize     ?
                 ?????????????????
                         ?
                 ?????????????????
                 ?   REASONING   ?
                 ? Stock analysis?
                 ? Threshold     ?
                 ? Decision      ?
                 ?????????????????
                         ?
                 ?????????????????
                 ?     ACTION    ?
                 ? Reorder item  ?
                 ? Create event  ?
                 ?????????????????
                         ?
                 ?????????????????????
                 ?     ACTUATORS     ?
                 ? WhatsApp + Email  ?
                 ?????????????????????
```

### Stage Details

1. **SENSORS**: Continuously ingests physical inventory counters, scan events, and POS terminal logs across catalog items.
2. **PERCEPTION**: Validates schema constraints (bounds checks, prevents negative quantities, sanitizes SKU formats, clamps supplier lead times to valid positive ranges).
3. **REASONING**: Computes dynamic reorder points accounting for demand variance, burn rate, and lead time buffer:
   $$\text{Dynamic ROP} = (\text{Daily Demand} \times \text{Supplier Lead Time}) + \text{Safety Stock}$$
   Synthesizes transparent, human-readable natural language justifications explaining *why* the agent decided to reorder or wait.
4. **ACTION**: Evaluates policies, prioritizes risk levels (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`), sizes batch purchase orders:
   $$\text{Reorder Quantity} = \max(0, \text{Target Stock} - \text{Current Stock})$$
   and logs an immutable audit event.
5. **ACTUATORS**: Dispatches formatted notifications to warehouse managers and suppliers via WhatsApp and Email relays through serverless Netlify Functions.

---

## 3. Technology Stack

- **Frontend**: React 18, TypeScript, Vite, Tailwind CSS, Lucide Icons, Recharts, Canvas-Confetti
- **Backend / Serverless**: Netlify Functions (TypeScript), Node.js v24 runtime
- **Data Persistence**: Resilient LocalStorage DB with automatic fallback + Supabase (PostgreSQL) adapter ready
- **Notifications (Actuators)**:
  - **WhatsApp**: Twilio WhatsApp API & Meta WhatsApp Cloud API with automatic mock simulation
  - **Email**: Resend API & SMTP relay with automatic mock simulation
- **Deployment Target**: Netlify with single-command CI/CD (`netlify.toml`)

---

## 4. Application Pages & Features

| Page | Description |
| :--- | :--- |
| **Dashboard** | Executive KPI cards (Total Products, Stock Units, Low Stock, Critical Items, Pending Reorders, Total Valuation in ?), stock vs dynamic ROP charts, category breakdown, quick agent triggers. |
| **Inventory** | Master stock registry with live search, multi-category filters, sorting, quick inline stock adjustment modals, and product CRUD. |
| **Agent Monitor** | Command center featuring the visual 5-stage pipeline, active telemetry inspector, live execution terminal console, and past agent run history. |
| **Reorder Center** | Comprehensive purchase order lifecycle management (`Recommended` ? `Pending Approval` ? `Approved` ? `Ordered` ? `Received`). Receiving an order automatically restocks the warehouse! |
| **Notifications** | Actuator delivery audit with channel filters (WhatsApp / Email), real vs demo indicators, and full message payload preview drawers. |
| **Activity Log** | Immutable chronological audit trail of stock adjustments (e.g. `20 ? 12`), agent decisions, and PO approvals. |
| **Settings** | Global inventory defaults (safety stock days, lead times), recipient phone and email configuration, demo mode toggle, and Supabase health status. |

---

## 5. Quick Demonstration (2-Minute Presentation Flow)

For presentations or college viva examinations:

1. Open the **Dashboard**.
2. Click **"Run Demo Scenario (Wireless Mouse)"**.
3. **Observe the Autonomous Workflow**:
   - The stock of *Wireless Mouse Pro (WM-001)* drops from `32` to `12` units.
   - The **Sensors** detect the new stock level (`12 units`).
   - The **Perception Engine** validates input constraints.
   - The **Reasoning Engine** computes:
     $$\text{Dynamic ROP} = (4 \text{ units/day} \times 5 \text{ lead days}) + 5 \text{ safety units} = 25 \text{ units}$$
   - Since $12 < 25$, the agent detects a stockout risk with only $3.0$ days of inventory remaining.
   - The **Decision/Action Module** formulates a purchase order for $50 - 12 = 38$ units ($\text{?}30,362$).
   - The **Actuators** dispatch simulated WhatsApp and Email alerts.
   - The activity log, KPI cards, and charts update in real-time with celebratory confetti.

---

## 6. Local Setup & Installation

### Prerequisites
- Node.js (v18 or higher recommended)
- npm or pnpm

### Steps

```bash
# 1. Clone or navigate to the repository
cd smartstock-ai

# 2. Install dependencies
npm install

# 3. Start local development server
npm run dev

# 4. Open in browser
# http://localhost:3000
```

---

## 7. Environment Variables & Production Integration

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

### Key Configurations

```env
# Mode ('demo' for safe simulation, 'production' for live API dispatches)
VITE_APP_MODE=demo

# Supabase PostgreSQL (Optional)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI...

# WhatsApp Options: Twilio OR Meta Cloud API
WHATSAPP_PROVIDER=twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886
WHATSAPP_RECIPIENT_NUMBER=+919876543210

# Alternative: Meta Cloud API
WHATSAPP_API_TOKEN=EAAxxxxxxx
WHATSAPP_PHONE_NUMBER_ID=100xxxxxxxxxxx

# Email Relay: Resend
EMAIL_PROVIDER=resend
RESEND_API_KEY=re_xxxxxxxxxxxx
ALERT_EMAIL_FROM=alerts@yourdomain.com
ALERT_EMAIL=manager@smartstock-ai.com
```

> **Security Note**: All secrets are accessed **strictly server-side** inside Netlify Functions (`netlify/functions/`). No API tokens or passwords are exposed to frontend client code.

---

## 8. Netlify Deployment

This project includes a fully configured `netlify.toml`:

```toml
[build]
  command = "npm run build"
  publish = "dist"
  functions = "netlify/functions"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### One-Click Deploy via Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build and deploy
netlify deploy --build --prod
```

Or connect your GitHub repository directly to Netlify. Netlify will auto-detect Vite and build to `dist/`.

---

## 9. Supabase Database Schema

To enable PostgreSQL persistence, run the SQL script located in `schema.sql` inside the Supabase SQL Editor. It creates tables for:
- `products` (SKU, current stock, reorder level, target stock, unit cost, demand, lead time, safety stock)
- `reorders` (Requisitions, status lifecycle, total cost)
- `notifications` (WhatsApp and Email dispatches)
- `agent_runs` (Telemetry logs and evaluation metrics)
- `activity_logs` (Audit trails)

---

## 10. License

Developed for educational, research, and enterprise autonomous inventory management. Released under the **MIT License**.
