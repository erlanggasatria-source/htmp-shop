# 🛒 HTMP Shop: Hybrid MPA-to-SPA E-commerce Boilerplate

Build modern, snappy web applications without frontend fatigue. A lightweight, backend-agnostic architecture that starts as a robust Multi-Page Application (MPA) and seamlessly enhances into a Single-Page Application (SPA) using HTMP (HyperText Mutation Projection).

---

## 🎯 The Problem: Frontend Fatigue

Modern web development often forces developers to choose between:

| Approach | Pros | Cons |
|----------|------|------|
| **MPA (Traditional)** | Great for SEO, fast initial load | Clunky full page reloads |
| **SPA (React/Vue/Angular)** | Smooth UX, app-like feel | Heavy build tools, complex state management, Virtual DOM overhead, SEO challenges, poor low-end device performance |

---

## 💡 The Solution: Hybrid MPA-to-SPA

HTMP Shop bridges this gap, delivering the best of both worlds:

- **MPA First**: The server renders complete, semantic HTML with initial JSON data. Crawlers (SEO) see everything instantly. First Contentful Paint (FCP) is blazing fast.
- **SPA Enhancement**: Once loaded, HTMP silently takes over the DOM. Subsequent navigations intercept links, fetch only lightweight JSON payloads, and swap templates instantly—no full page reloads, no heavy build steps, no Node.js required.

---

## 🏗️ Core Architecture: The P1-P2-P3 Pattern (3P HTMP)

To maintain a "No Magic" philosophy, every page follows a strict, highly debuggable modular pattern:

### 1. P1 - Pattern (Template)
Declarative HTML strings using simple HTMP syntax (`{{ }}` for text, `:for` for loops, `:class` for merging, `:style` for visibility). No complex JSX or Virtual DOM.

```javascript
const patterns = {
  dashboard: adminLayout(`
    <div class="stat-card">
      <div class="stat-value">{{ stats.total_products }}</div>
    </div>
  `)
};
```

### 2. P2 - Proxy (State & Helpers)
The single source of truth for data. Contains the shape of your data and read-only helper functions (e.g., `formatRupiah`). It never mutates itself.

```javascript
const proxy = {
  stats: { total_products: 0 },
  formatRupiah: (val) => val.toLocaleString('id-ID')
};
```

### 3. P3 - Program (Logic & Mutations)
The only place where state is allowed to change. Contains event handlers and business logic. It explicitly updates `app.proxy`.

```javascript
const programs = {
  updateStats: (data) => {
    app.proxy.stats.total_products = data.total;
  }
};
```

---

## ⚡ Key Features & Optimizations

| Feature | Description |
|---------|-------------|
| 🚀 **Low-End Device Friendly** | Designed for budget devices (e.g., Redmi A5). Uses Layered Proxy Pagination (Filter → Slice → Render), ensuring the DOM never holds more than ~15 rows at a time, preventing memory leaks and layout shifts. |
| 🔍 **SEO Ready** | Initial load is pure, server-rendered HTML—search engine crawlers index content perfectly without waiting for JavaScript. |
| 🧩 **Backend Agnostic** | Works with PHP (Laravel/CodeIgniter), Go (Gin/Fiber), Python (Django/FastAPI), Ruby on Rails. Backend simply outputs HTML + a `<script type="application/json">` payload. |
| 🎨 **Zero Build Step (Prototype)** | `admin-prototype/` runs directly in browser — no Webpack, no Vite, no `npm install`. Production uses Vite for a single optimized bundle. |
| 🔄 **Cross-Tab Sync Ready** | Architecture supports `localStorage` event listening to sync state (like cart updates) across tabs, while keeping the server as the Single Source of Truth. |
| 🛡️ **No "Magic"** | What you see in the HTML is what gets rendered. Debugging is as simple as checking `app.proxy` in the browser console. |

---

## 🚀 How It Works (The Lifecycle)

1. **Initial Load**: User visits `/admin/products`. The server returns full HTML + embedded JSON initial data.
2. **Mounting**: HTMP reads the JSON, binds it to the proxy, and mounts the pattern to the `#app` div.
3. **Interception**: User clicks a link to `/admin/orders`. HTMP intercepts the click, prevents default browser behavior.
4. **Fetch & Swap**: HTMP fetches the JSON for the new route, swaps the `#app` innerHTML with the new pattern, updates the proxy, and pushes the new URL to the browser history.
5. **Result**: Instant page transition, zero flicker, minimal bandwidth usage.

---

## 📂 Project Structure

```
htmp-shop/
├── admin-prototype/          # 🎯 Standalone prototype - runs directly in browser (no server needed)
│   ├── dashboard.html        # Stats & overview
│   ├── categories.html       # CRUD + Modal + Client-side Pagination
│   ├── products.html         # List with rich data & hybrid filtering
│   ├── products-create.html  # Dynamic form with variant array management
│   └── orders.html           # List with Server-Month / Client-Search hybrid filtering
├── admin/                    # 📦 Production admin (served by backend)
│   ├── index.html            # Entry point - loads compiled SPA bundle
│   └── partials/             # Server-rendered partials (Blade templates for Laravel)
├── css/
│   └── admin.css             # Lightweight, mobile-first utility & component styles
├── js/
│   ├── admin-ui.js           # Vanilla JS for non-reactive UI (sidebar toggle, etc.)
│   ├── pages/                # Page-specific logic (P1-P2-P3 per page)
│   │   ├── dashboard.js
│   │   ├── categories.js
│   │   ├── products.js
│   │   ├── products-create.js
│   │   └── orders.js
│   └── htmp-core.js          # HTMP runtime (template engine, router, proxy)
├── backend/                  # 🔧 Backend implementations (pluggable)
│   └── laravel/              # Laravel integration (first backend)
│       ├── routes/
│       ├── controllers/
│       ├── views/            # Blade templates serving admin/partials
│       └── resources/js/     # Vite entry for compiling SPA bundle
├── dist/                     # 📦 Compiled output (generated)
│   ├── p1-templates.js       # All P1 patterns combined (templates only)
│   └── p2p3-app.js           # All P2 proxies + P3 programs + SPA router + HTMP core
└── README.md
```

### Architecture Flow

| Stage | Description |
|-------|-------------|
| **1. Prototype** | `admin-prototype/` - Pure HTML/JS, open directly in browser. Each page has inline P1-P2-P3. Great for rapid UI iteration. |
| **2. Modularize** | Extract P1-P2-P3 from each prototype page into `pattern.js` (P1+P2+P3 per page) into `app.js` (router, proxy base). |
| **3. Backend Serve** | Laravel serves `admin/index.html` (loads both bundles) + partials via Blade. HTMP takes over for SPA navigation. |

---

## 🛠️ Getting Started

### Option A: Run the Prototype (No Build, No Backend)
Open directly in browser — zero setup required.

```bash
git clone https://github.com/erlanggasatria-source/htmp-shop.git
cd htmp-shop

# Just open admin-prototype/dashboard.html in your browser
# Or serve it (required for ES modules):
python -m http.server 8000
# Then visit http://localhost:8000/admin-prototype/dashboard.html
```

### Option B: Production Setup (Laravel Backend + Compiled SPA)
*Coming in Phase 3 — requires Laravel + Node.js for Vite build.*

```bash
# 1. Setup Laravel backend
cd backend/laravel
composer install
cp .env.example .env
php artisan key:generate

# 2. Serve
php artisan serve
# Visit http://localhost:8000/admin
```

---

## 🎯 Who Is This For?

- **Solo Developers & Agencies**: Deliver premium, app-like UX to clients without maintaining a complex frontend pipeline.
- **Backend Developers**: Love writing HTML/CSS and want to add reactivity without learning a massive JavaScript framework ecosystem.
- **Performance Enthusiasts**: Prioritize Core Web Vitals, low memory footprint, and fast Time-to-Interactive (TTI).

---

## 🗺️ Roadmap

- **Phase 1**: Admin Zone (Dashboard, Categories, Products CRUD, Orders Lifecycle)
- **Phase 2**: User Zone (Public Catalog, Product Detail with Variant Selection, Cart)
- **Phase 3**: Backend Integration (Connecting HTMP fetch calls to PHP/Go API endpoints)
- **Phase 4**: Advanced UX (Cross-tab synchronization, native date-picker library integration)

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE). Feel free to clone, modify, and build your own versions!

---

## 🤝 Contributing & Community

Built with ❤️ by [Elangga Satria](https://github.com/erlanggasatria-source).

If you find this architecture useful, please ⭐ star the repository! If you have ideas, optimizations, or want to discuss the "MPA-to-SPA" philosophy, feel free to open an issue or join the discussion.