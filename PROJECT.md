# Garage Management Mobile App

A Flutter mobile application for car service booking and garage management.  
Backend: `https://backend-1-qgqd.onrender.com/api/v1`

---

## Table of Contents

- [Roles](#roles)
- [Project Structure](#project-structure)
- [Features by Role](#features-by-role)
- [API Endpoints Connected](#api-endpoints-connected)
- [Screen Flow](#screen-flow)
- [State Management](#state-management)
- [Running the App](#running-the-app)
- [Test Accounts](#test-accounts)

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
│   │   ├── api_constants.dart       # All 60+ endpoint constants
│   │   └── api_config.dart          # Base URL configuration
│   └── errors/
│       └── exceptions.dart          # ServerException, UnauthorizedException, etc.
│
├── shared/
│   ├── services/
│   │   └── auth_service.dart        # Auth state (ChangeNotifier) — token, roles, userId
│   └── widgets/
│       ├── custom_bottom_nav.dart   # Role-aware bottom navigation
│       └── ...
│
└── features/
    ├── auth/                        # Login, Register
    ├── home/                        # Home page, Services list
    ├── booking/                     # Unified booking flow, history
    ├── appointments/                # Customer appointments CRUD
    ├── vehicles/                    # My vehicles CRUD
    ├── notifications/               # Notifications + mark as read
    ├── repair_progress/             # Repair stage tracker
    ├── quotations/                  # Quotations (approve/reject)
    ├── invoices/                    # Invoices with payment records
    ├── activity/                    # Activity hub (appointments + orders)
    ├── mechanic/                    # Mechanic/owner dashboard & tools
    ├── shop/                        # Shop creation
    ├── ratings/                     # Product & service ratings
    ├── search/                      # Image search
    └── profile/                     # Profile page
```

---

## Features by Role

### Customer (`user`)

| Feature | Page | API |
|---------|------|-----|
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
POST /auth/login
POST /auth/register
POST /auth/refresh
GET  /auth/me
GET  /auth/me/roles
POST /auth/logout
```

### Customer Appointments & Orders
```
GET  /customers/my-appointments
GET  /customers/my-appointments/{id}
PUT  /customers/my-appointments/{id}/cancel
GET  /customers/my-service-history
GET  /product-orders/my-orders
PUT  /product-orders/my-orders/{id}/cancel
POST /product-orders/unified-booking
POST /product-orders/calculate-price
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
POST /shops/{id}/mechanics/{mid}/rate
GET  /ratings/products/{id}/reviews
GET  /ratings/services/{id}/reviews
```

---

## Screen Flow

```
App Launch
│
├── HomePage (public)
│   ├── ServicesListPage
│   └── BookingPage (requires auth prompt)
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
  ├── isAuthenticated  bool
  ├── token            String?       // JWT Bearer token
  ├── userId           int?
  ├── userName         String?       // full_name
  ├── username         String?       // login username
  ├── userEmail        String?
  ├── userRoles        UserRolesResponse?
  ├── shopId           int?          // selected shop for mechanic/owner
  ├── isAdmin          bool
  ├── isShopOwner      bool
  ├── isMechanic       bool
  ├── apiClient        ApiClient     // shared client, token already set
  └── loginWithCredentials()         // calls /auth/login → /auth/me → /auth/me/roles
```

All feature services use the same pattern:
```dart
final auth = context.read<AuthService>();
final service = SomeApiService();
if (auth.token != null) service.setAuthToken(auth.token!);
```

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run with a custom backend URL
flutter run --dart-define=BASE_API_URL=http://localhost:8000
```

---

## Test Accounts

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Shop Owner | `owner1` | `owner123` |
| Mechanic | `mechanic1` | `mechanic123` |
| Customer | `customer1` | `customer123` |

> After login the app fetches roles from `/auth/me/roles` and redirects the UI accordingly.

---

## Repair Progress Stages

```
received → diagnosing → waiting_parts → in_progress → quality_check → ready_for_pickup → completed
```

Displayed as a linear progress bar with percentage in `MyRepairsPage`.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider ^6.1.1` | State management |
| `http ^1.2.0` | HTTP requests |
| `http_parser ^4.0.2` | Multipart/form uploads |
| `image_picker ^1.0.7` | Image selection for search |
| `permission_handler ^11.3.0` | Camera/storage permissions |
