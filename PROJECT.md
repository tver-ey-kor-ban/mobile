# Garage Management Mobile App

A Flutter mobile application for car service booking and garage management.  
Backend: `https://backend-1-s2fl.onrender.com/api/v1`  
Branch: `24-code-refactor`

> **Note:** The backend runs on Render free tier — first request after inactivity may take 30–60 s (cold start).

---

## Table of Contents

- [Roles](#roles)
- [Project Structure](#project-structure)
- [Features by Role](#features-by-role)
- [API Endpoints Connected](#api-endpoints-connected)
- [Screen Flow](#screen-flow)
- [State Management](#state-management)
- [Token Persistence](#token-persistence)
- [Running the App](#running-the-app)
- [Test Accounts](#test-accounts)
- [Known Limitations](#known-limitations)
- [Dependencies](#dependencies)

---

## Roles

| Role | Description | Access |
|------|-------------|--------|
| `user` | Regular customer | Book services, manage vehicles, view invoices |
| `mechanic` | Shop mechanic | Accept/reject bookings, manage repairs |
| `owner` | Shop owner | All mechanic features + performance analytics |
| `admin` | Superuser | Full platform access |

The app detects the user's role after login via `GET /auth/me/roles` and adjusts the UI automatically.

---

## Project Structure

```
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart          # HTTP client (GET, POST, PUT, DELETE)
│   │   ├── api_constants.dart       # All endpoint constants
│   │   └── api_config.dart          # Base URL configuration
│   └── errors/
│       └── exceptions.dart          # ServerException, UnauthorizedException, etc.
│
├── shared/
│   ├── services/
│   │   └── auth_service.dart        # Auth state (ChangeNotifier) — token, roles, userId
│   │                                # Persists session via SharedPreferences
│   └── widgets/
│       ├── custom_bottom_nav.dart   # Role-aware bottom navigation
│       └── ...
│
└── features/
    ├── auth/                        # Login, Register
    ├── home/                        # Shop browse (reloads on login/logout)
    │                                # + shortcut banner → ProductSearchPage
    ├── booking/                     # Unified booking flow, history
    ├── appointments/                # Customer appointments CRUD
    ├── vehicle/                     # My vehicles CRUD (primary feature)
    ├── vehicles/                    # My vehicles CRUD (legacy, kept for compatibility)
    ├── notifications/               # Notifications + mark as read
    ├── repair_progress/             # Repair stage tracker
    ├── quotations/                  # Quotations (approve/reject)
    ├── invoices/                    # Invoices with payment records
    ├── activity/                    # Activity hub (appointments + orders)
    ├── mechanic/                    # Mechanic/owner dashboard & tools
    ├── shop/
    │   ├── data/models/
    │   │   ├── shop_model.dart      # ShopResponse, ShopsListResponse
    │   │   └── browse_models.dart   # ShopProduct, ShopServiceItem, response wrappers
    │   ├── services/
    │   │   ├── shop_api_service.dart    # GET /shops (handles flat-list & paginated responses)
    │   │   └── browse_api_service.dart  # GET browse/products & browse/services per shop
    │   └── presentation/pages/
    │       ├── shop_list_page.dart      # Tab 1 — shop list
    │       ├── shop_detail_page.dart    # Shop profile → ShopProductsPage (products/services tab)
    │       ├── shop_products_page.dart  # Tabbed Products / Services for one shop
    │       ├── product_search_page.dart # Global search across all shops (debounced, parallel)
    │       └── create_shop_page.dart    # Owner — create new shop
    ├── ratings/                     # Product, service & mechanic ratings
    ├── search/                      # Image search (mock data — endpoint not ready)
    └── profile/                     # Profile page (navigation hub)
```

---

## Features by Role

### Customer (`user`)

| Feature | Page | API |
|---------|------|-----|
| Browse shops | `HomePage` | `GET /shops` |
| Search products & services | `ProductSearchPage` | `GET /customers/shops/{id}/browse/products` + `browse/services` (parallel, all shops) |
| Browse shop products | `ShopProductsPage` (Products tab) | `GET /customers/shops/{id}/browse/products` |
| Browse shop services | `ShopProductsPage` (Services tab) | `GET /customers/shops/{id}/browse/services` |
| Book service / products | `BookingPage` | `POST /product-orders/unified-booking` |
| View appointments | `MyAppointmentsPage` | `GET /customers/my-appointments` |
| Cancel appointment | `MyAppointmentsPage` | `PUT /customers/my-appointments/{id}/cancel` |
| Manage vehicles | `MyVehiclesPage` | `GET/POST/PUT/DELETE /my-vehicles` |
| Track repair progress | `MyRepairsPage` | `GET /repair-progress/my-repairs` |
| View quotations | `MyQuotationsPage` | `GET /quotations/my-quotations` |
| Approve / reject quotation | `MyQuotationsPage` | `POST /quotations/my-quotations/{id}/action` |
| View invoices | `MyInvoicesPage` | `GET /invoices/my-invoices` |
| Notifications | `NotificationsPage` | `GET /mechanic/my-notifications` |
| Order history | `ActivityPage` | `GET /product-orders/my-orders` |

### Mechanic (`mechanic`)

| Feature | Page | API |
|---------|------|-----|
| Dashboard overview | `MechanicDashboardPage` | `GET /shops/my-shops` |
| Pending bookings | `PendingBookingsPage` | `GET /mechanic/shops/{id}/pending-bookings` |
| Accept / reject booking | `PendingBookingsPage` | `POST /mechanic/shops/{id}/bookings/{id}/action` |
| Today's bookings | `TodayBookingsPage` | `GET /mechanic/shops/{id}/today-bookings` |
| Pending orders | `PendingOrdersPage` | `GET /mechanic/shops/{id}/pending-orders` |
| Accept / reject order | `PendingOrdersPage` | `POST /mechanic/shops/{id}/orders/{id}/action` |
| Mark order ready | `PendingOrdersPage` | `PUT /mechanic/shops/{id}/orders/{id}/ready` |
| My performance | `MechanicPerformancePage` | `GET /shops/{id}/mechanics/my-performance` |
| Notifications | `NotificationsPage` | `GET /mechanic/my-notifications` |

### Shop Owner (`owner`)

All mechanic features plus:

| Feature | Page | API |
|---------|------|-----|
| Team performance | `MechanicPerformancePage` | `GET /shops/{id}/mechanics/performance` |
| Create shop | `CreateShopPage` | `POST /shops` |
| Manage products | — | `GET/POST/PUT/DELETE /shops/{id}/products` |
| Manage services | — | `GET/POST/PUT/DELETE /shops/{id}/services` |

---

## API Endpoints Connected

### Authentication
```
POST /auth/login           (form-encoded: username, password, grant_type=password)
POST /auth/register
POST /auth/refresh
GET  /auth/me
GET  /auth/me/roles
POST /auth/logout
```

### Shop Browse
```
GET  /shops                (requires auth — handles both flat-list and paginated responses)
GET  /shops/{id}
```

### Shop Product & Service Browse (public)
```
GET  /customers/shops/{id}/browse/products    (ShopProductsPage, ProductSearchPage)
GET  /customers/shops/{id}/browse/services    (ShopProductsPage, ProductSearchPage)
GET  /customers/shops/{id}/browse/shop-info   (defined, not yet used in UI)
```

### Customer Appointments & Orders
```
GET  /customers/my-appointments
GET  /customers/my-appointments/{id}
PUT  /customers/my-appointments/{id}/cancel
GET  /customers/my-service-history
GET  /product-orders/my-orders
GET  /product-orders/my-orders/{id}
PUT  /product-orders/my-orders/{id}/cancel
POST /product-orders/unified-booking
POST /product-orders/calculate-price
POST /product-orders              (product-only order)
GET  /product-orders              (list product orders)
```

### My Vehicles
```
GET    /my-vehicles
POST   /my-vehicles
GET    /my-vehicles/{id}
PUT    /my-vehicles/{id}
DELETE /my-vehicles/{id}
POST   /my-vehicles/{id}/set-primary
GET    /my-vehicles/primary
```

### Vehicle Database (public lookup)
```
GET /vehicles/makes
GET /vehicles/makes/{makeId}/models
GET /vehicles/models/{modelId}/years
GET /vehicles/years/{yearId}/engines
```

### Notifications
```
GET /mechanic/my-notifications
PUT /mechanic/notifications/{id}/read
```

### Repair Progress
```
GET  /repair-progress/my-repairs          (customer)
GET  /repair-progress/my-repairs/{id}     (customer)
GET  /repair-progress/shops/{id}          (mechanic)
POST /repair-progress/shops/{id}          (mechanic - create)
PUT  /repair-progress/shops/{id}/{pid}    (mechanic - update stage)
```

### Quotations
```
GET  /quotations/my-quotations
GET  /quotations/my-quotations/{id}
POST /quotations/my-quotations/{id}/action   (approve / reject)
GET  /quotations/shops/{id}
POST /quotations/shops/{id}
POST /quotations/shops/{id}/{qid}/send
```

### Invoices
```
GET  /invoices/my-invoices
GET  /invoices/my-invoices/{id}
GET  /invoices/shops/{id}
POST /invoices/shops/{id}
POST /invoices/shops/{id}/{iid}/send
POST /invoices/shops/{id}/{iid}/payments
```

### Mechanic / Shop
```
GET  /shops/my-shops
GET  /mechanic/shops/{id}/pending-bookings
GET  /mechanic/shops/{id}/bookings/{apptId}
POST /mechanic/shops/{id}/bookings/{apptId}/action
GET  /mechanic/shops/{id}/today-bookings
GET  /mechanic/shops/{id}/pending-orders
POST /mechanic/shops/{id}/orders/{oid}/action
PUT  /mechanic/shops/{id}/orders/{oid}/ready
GET  /shops/{id}/mechanics/my-performance
GET  /shops/{id}/mechanics/performance
```

### Ratings
```
POST /ratings/products/{id}
POST /ratings/services/{id}
POST /shops/{shopId}/mechanics/{mechanicId}/rate
GET  /ratings/products/{id}/reviews
GET  /ratings/services/{id}/reviews
```

---

## Screen Flow

```
App Launch
│
├── tryRestoreSession()       ← restores JWT from SharedPreferences
│
├── HomePage (shop browse — requires auth)
│   ├── Reloads automatically on login / logout
│   ├── [Search banner] → ProductSearchPage (global product/service search)
│   └── ShopCard → ShopDetailPage
│           ├── "Book a Service"   → ShopProductsPage (Services tab, initialTab: 1)
│           └── "Browse Products"  → ShopProductsPage (Products tab, initialTab: 0)
│               └── Book button on each card → BookingPage
│
├── ProductSearchPage (tab 2 — "Search")
│   ├── Idle   → shop browser list → ShopProductsPage
│   └── Search → queries all shops in parallel (debounced 500 ms)
│               → results tabbed: All / Products / Services
│               → Book button → BookingPage
│
├── ActivityPage (tab 3)
│   ├── Customer → Appointments tab + Orders tab
│   └── Mechanic / Owner → MechanicDashboardPage
│       ├── PendingBookingsPage
│       │   └── BookingDetailMechanicPage (accept / reject)
│       ├── TodayBookingsPage
│       ├── PendingOrdersPage
│       └── MechanicPerformancePage
│
└── ProfilePage (tab 4)
    ├── (logged out) → Login / Register modal
    └── (logged in)
        ├── Customer menu
        │   ├── MyAppointmentsPage → AppointmentDetailPage
        │   ├── MyVehiclesPage (add / edit / delete / set primary)
        │   ├── MyRepairsPage (stage progress bar)
        │   ├── MyQuotationsPage (approve / reject)
        │   └── MyInvoicesPage (items + payments)
        ├── Mechanic/Owner menu
        │   └── MechanicDashboardPage
        └── NotificationsPage (all roles)
```

---

## State Management

The app uses **Provider** with a single `AuthService` (`ChangeNotifier`).

```dart
AuthService
  ├── isAuthenticated     bool
  ├── token               String?       // JWT Bearer token (in-memory + SharedPreferences)
  ├── refreshToken        String?
  ├── userId              int?
  ├── userName            String?       // full_name or username fallback
  ├── username            String?       // login username
  ├── userEmail           String?
  ├── userRoles           UserRolesResponse?
  ├── shopId              int?          // selected shop for mechanic/owner
  ├── isAdmin             bool
  ├── isShopOwner         bool
  ├── isMechanic          bool
  ├── isCustomer          bool
  ├── apiClient           ApiClient     // shared client, token already set
  ├── tryRestoreSession()               // called at startup — loads token from prefs
  ├── loginWithCredentials()            // POST /auth/login → /auth/me → /auth/me/roles → saves to prefs
  ├── register()                        // POST /auth/register → auto-login
  └── logout()                          // clears memory + SharedPreferences
```

All feature services inject the token at call time:
```dart
final auth = context.read<AuthService>();
if (auth.token != null) service.setAuthToken(auth.token!);
```

---

## Token Persistence

Session is saved to `SharedPreferences` on login and restored on app startup:

| Key | Value |
|-----|-------|
| `auth_token` | JWT access token |
| `auth_refresh_token` | Refresh token |
| `auth_user_id` | User ID (int) |
| `auth_user_name` | Display name |
| `auth_username` | Login username |
| `auth_user_email` | Email |

On restore, roles are re-verified via `GET /auth/me/roles`. If the token is expired or invalid, the session is cleared automatically and the user is shown as logged out.

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build debug APK
flutter build apk --debug

# Analyze code
flutter analyze --no-fatal-infos --no-fatal-warnings
```

---

## Test Accounts

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Shop Owner | `owner1` | `owner123` |
| Mechanic | `mechanic1` | `mechanic123` |
| Customer | `customer1` | `customer123` |

> Accounts must exist on `backend-1-s2fl.onrender.com`. If migrating from the old backend (`backend-1-qgqd`), re-register — they are separate databases.

---

## Repair Progress Stages

```
received → diagnosing → waiting_parts → in_progress → quality_check → ready_for_pickup → completed
```

Displayed as a linear progress bar with percentage in `MyRepairsPage`.

---

## Known Limitations

| Area | Status |
|------|--------|
| Image search | Returns mock data — backend endpoint not yet available |
| Home/shop list | Hardcoded service/product categories in `ServicesListPage` |
| Booking car data | Car brands/models/services are hardcoded demo data |
| Token refresh | Refresh token is saved but auto-refresh on expiry is not yet wired up |
| Product search | No global search endpoint — `ProductSearchPage` fetches all shops' products in parallel and filters client-side |
| `browse/shop-info` | Endpoint defined in `ApiConstants` but not yet surfaced in UI |
| `oracleJdk-26/` folder | Accidentally placed inside `lib/features/home/presentation/pages/` — should be deleted |

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | `^6.1.1` | State management |
| `http` | `^1.2.0` | HTTP requests |
| `http_parser` | `^4.0.2` | Multipart/form uploads |
| `shared_preferences` | `^2.3.0` | JWT token persistence across restarts |
| `image_picker` | `^1.0.7` | Image selection for search |
| `permission_handler` | `^11.3.0` | Camera/storage permissions |
