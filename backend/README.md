# Entertainment Tracker Backend 🎬🎮📺

Welcome to the backend repository for the **Entertainment Tracker** application. This is a robust, production-grade REST API built using **NestJS** and **TypeScript**, integrated with **Supabase (PostgreSQL)**, and designed to manage users, libraries, custom lists, reviews, and cross-media tracking metadata consolidated from external APIs (**TMDb** and **IGDB**).

---

## 🚀 Key Features & Responsibilities

- **Unified Media API:** Centralizes data orchestration across different entertainment types—Movies, TV Shows, and Video Games—reducing client-side computational overhead.
- **Secure Integration Layer:** Safely acts as a proxy for third-party media endpoints (**TMDb** and **IGDB**), hiding private API credentials from the client application binary.
- **Data Consolidation & Optimization:** Formats, structures, and caches multi-source metadata before serving it down to the frontend, optimizing network requests and device battery life.
- **Modular Business Logic:** Built with strict decoupling across key business functions: Authentication, Profile Management, Custom Playlists/Lists, Reviews/Ratings, and Yearly Performance Summaries.
- **Robust Security Framework:** Implements strict data validation, exception filtering, and secure JWT session handling complementing Supabase's Row-Level Security (RLS) policies.

---

## 🛠️ Tech Stack & Prerequisites

### Architecture & Framework
- **Runtime Environment:** Node.js (v18.x or v20.x recommended)
- **Backend Framework:** NestJS (v10.x)
- **Language:** TypeScript
- **Database Backend:** Supabase Cloud (PostgreSQL)

### Critical Dependencies
- `@nestjs/config` — Environment configurations management
- `@nestjs/jwt` & `@nestjs/passport` — Authentication structures
- `class-validator` & `class-transformer` — DTO runtime schema validation
- `dio` / `axios` / `@nestjs/axios` — Downstream API client requests

---

## 📂 Repository Structure

The code is organized according to strict NestJS domain-driven modular standards:


```

```text
Backend README.md successfully created.

```text
backend/
├── src/
│   ├── auth/                 # Identity validation, token decoding, and access guards
│   ├── users/                # User profile schemas, metadata, and custom preferences
│   ├── entertainment/        # Proxy services for TMDb (Movies/TV) and IGDB (Video Games)
│   ├── library/              # Main state tables managing tracking status (Plan to Watch, Completed, etc.)
│   ├── reviews/              # Core rating matrices and community textual evaluations
│   ├── lists/                # Structured compilation of personal collections & item attachments
│   ├── statistics/           # High-performance analytical aggregates and annual breakdown engines
│   ├── main.ts               # Application bootstrapping entrypoint
│   └── app.module.ts         # Global core system configuration matrix
├── test/                     # End-to-End integration test configurations
├── .env.example              # Template file for secret key initializations
├── nest-cli.json             # Core framework compilation layout parameters
└── tsconfig.json             # TypeScript structural compiler constraints

```

---

## ⚙️ Installation & Workspace Alignment

Follow these steps to establish your local runtime workspace:

### 1. Clone & Position

Navigate to the root directory containing your infrastructure:

```bash
cd EntertainmentTracker/backend

```

### 2. Supply System Configurations

Instantiate your local runtime configuration sheet:

```bash
cp .env.example .env

```

Open the newly created `.env` file and populate it with your environment parameters:

```env
PORT=3000
SUPABASE_URL=[https://your-supabase-project.supabase.co](https://your-supabase-project.supabase.co)
SUPABASE_KEY=your-supabase-anon-or-service-role-key
JWT_SECRET=your-high-entropy-jwt-secret-string
TMDB_API_KEY=your-tmdb-developer-key
IGDB_CLIENT_ID=your-twitch-developer-client-id
IGDB_CLIENT_SECRET=your-twitch-developer-client-secret

```

### 3. Fetch Packages

Deploy npm to orchestrate the retrieval of explicit workspace dependencies:

```bash
npm install

```

---

## 🏃 Running the Application

### Local Development Mode

Launches the service with hot-reloading active. Whenever code modifications are persisted, the engine reconstructs and hot-swaps live:

```bash
npm run start:dev

```

The application will default to listening on: `http://localhost:3000`

### Production Compilation & Launch

To compile TypeScript into optimized production JavaScript artifacts and deploy:

```bash
npm run build
npm run start:prod

```

---

## 🧪 Testing and Quality Control

Execute standard automated functional verification sweeps:

```bash
# Unit tests
npm run test

# End-to-End integration suites
npm run test:e2e

# Code formatting and linting inspections
npm run lint

```

---

## 📡 API Routing Overview (Core Paths)

| Route Path | HTTP Method | Scope / Description | Access Rules |
| --- | --- | --- | --- |
| `/auth/register` | `POST` | Setup new profile credentials | Public |
| `/auth/login` | `POST` | Verify signature & issue JWT tokens | Public |
| `/entertainment/search` | `GET` | Cross-query items inside TMDb & IGDB indices | Authenticated |
| `/library` | `GET` | Retrieve logged titles for the calling profile | Authenticated |
| `/library` | `POST` | Record a title to tracking indexes | Authenticated |
| `/reviews` | `POST` | Author a text evaluation and point metric rating | Authenticated |
| `/lists` | `POST` | Construct a custom-themed tracking directory | Authenticated |
| `/statistics/summary` | `GET` | Extract calculated annual/genre metric insights | Authenticated |

---

## 👥 Authors & Collaborators

* **Ratib Hoque** (Lead Engineering & Architecture)
* **Danial Siddique** (Lead Implementation & Systems Design)