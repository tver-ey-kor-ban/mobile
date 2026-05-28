# Thread Summary — API Fix + Shop UI Build

## What Was Done

---

### 1. API Config — Base URL Fix
**File:** `lib/core/network/api_config.dart`
- Changed default base URL from stale `backend-1-qgqd.onrender.com` → `backend-1-s2fl.onrender.com`
- Now matches `api_constants.dart`

---

### 2. Ratings — Wrong Endpoint Pattern
**File:** `lib/core/network/api_constants.dart`

**Before (wrong):**
```dart
static String rateProduct(int productId) => '.../ratings/products/$productId';
static String rateService(int serviceId) => '.../ratings/services/$serviceId';
```
**After (correct — ID goes in body, not URL):**
```dart
static const String rateProduct = '.../ratings/products';
static const String rateService = '.../ratings/services';
```
Also added missing rating constants:
- `productRatingSummary(int id)` → `GET /ratings/products/{id}/summary`
- `serviceRatingSummary(int id)` → `GET /ratings/services/{id}/summary`
- `shopTopProducts(int id)`, `shopTopServices(int id)`
- `myRatings` → `GET /ratings/my-ratings`

---

### 3. Rating Models — Wrong Field Names
**File:** `lib/features/ratings/data/models/rating_model.dart`

- Replaced single `RatingRequest` class with 3 typed classes:
  - `ProductRatingRequest` — fields: `product_id`, `rating`, `review`, `order_id`
  - `ServiceRatingRequest` — fields: `service_id`, `rating`, `review`, `appointment_id`
  - `MechanicRatingRequest` — fields: `appointment_id`, `rating`, `review`
- `RatingResponse.comment` renamed to `review`
- Added `RatingSummary` model for the `/summary` endpoints
- Fixed `RatingsListResponse` to check `items` key first (matches API pagination envelope)

---

### 4. Ratings Service — Updated Signatures
**File:** `lib/features/ratings/services/ratings_api_service.dart`

- `rateProduct(ProductRatingRequest)` — no longer takes `productId` param
- `rateService(ServiceRatingRequest)` — no longer takes `serviceId` param
- `rateMechanic(shopId, mechanicId, MechanicRatingRequest)`
- Added: `getProductRatingSummary(int productId)`
- Added: `getServiceRatingSummary(int serviceId)`
- Added: `getMyRatings()`

---

### 5. Rating Dialog — Renamed `comment` → `review`
**File:** `lib/features/ratings/presentation/widgets/rating_dialog.dart`
- All occurrences of `comment` renamed to `review` to match API field name

---

### 6. API Constants — All Missing Endpoints Added
**File:** `lib/core/network/api_constants.dart`

New constants added:
| Group | New Constants |
|-------|--------------|
| Browse | `browseProduct(shopId, productId)`, `browseService(shopId, serviceId)` |
| Categories | `categoriesTree`, `categoryProducts(id)`, `categoriesByService(serviceId)`, `categoryServiceLinks` |
| Vehicles | `vehicleFuelTypes`, `vehicleHierarchy`, `vehicleSearch`, `vehicleValidate` |
| Customer Vehicles | `filterProductsByVehicle` |
| Orders | `myOrderPriceBreakdown(id)` |
| Mechanic Performance | `topMechanics(shopId)`, `mechanicPerformanceHistory(shopId, mechanicId)`, `recordMechanicPerformance(shopId, mechanicId)` |
| Chat | `markMessageRead(roomId, messageId)`, `chatUnreadCount(roomId)`, `closeChatRoom(roomId)` |
| Global Search | `globalSearch` → `GET /search` |
| Shop | `shopServicesByType(shopId)`, `shopProductsByService(shopId, serviceId)` |
| Admin | `adminUsers`, `adminUser(id)`, `adminUserRole(id)`, `adminUserStatus(id)`, `adminShops`, `adminShop(id)`, `adminAppointments`, `adminOrders`, `adminRatings`, `adminDeleteProductRating(id)`, `adminDeleteServiceRating(id)`, `adminStatistics`, `adminDailyStatistics` |
| Shop Members | `shopMemberRole(shopId, userId)` |

---

### 7. New Shop-Side UI Pages Built

All models and API services already existed. Only UI was missing.

#### Quotations (shop side)
| File | Description |
|------|-------------|
| `lib/features/quotations/presentation/pages/shop_quotations_page.dart` | Tabbed list (All/Draft/Sent/Approved/Rejected/Expired) + FAB to create |
| `lib/features/quotations/presentation/pages/shop_quotation_detail_page.dart` | Line items, pricing breakdown, Send to Customer button (draft only) |
| `lib/features/quotations/presentation/pages/create_quotation_page.dart` | Form with dynamic line items, cost fields, live total preview |

#### Repair Progress (shop side)
| File | Description |
|------|-------------|
| `lib/features/repair_progress/presentation/pages/shop_repairs_page.dart` | Tabbed by stage, progress bar per card |
| `lib/features/repair_progress/presentation/pages/shop_repair_detail_page.dart` | Visual stage timeline, update history, Update Stage dialog |
| `lib/features/repair_progress/presentation/pages/create_repair_page.dart` | Initial stage + description + estimated completion |

#### Invoices (shop side)
| File | Description |
|------|-------------|
| `lib/features/invoices/presentation/pages/shop_invoices_page.dart` | Tabbed by status, shows paid amount per card |
| `lib/features/invoices/presentation/pages/shop_invoice_detail_page.dart` | Items, pricing, payment history, Send + Record Payment buttons |

---

### 8. Mechanic Dashboard — Fixed + Expanded
**File:** `lib/features/mechanic/presentation/pages/mechanic_dashboard_page.dart`

**Stats bug fixed:**
- Was always calling `getAllMechanicsPerformance` (owner-only → returns null for mechanics)
- Now calls `getMyPerformance` for all roles (shows personal Jobs/Revenue/Rating)
- Owners additionally load team stats (Total Jobs/Revenue/Mechanic count)
- Shows `—` placeholder if no data yet instead of hiding the row

**Grid layout fixed:**
- Was: 2-column `childAspectRatio: 1.4` → cards were huge/tall
- Now: 3-column `childAspectRatio: 1.1` → compact square tiles, all 7 fit without scroll

**3 new action tiles added:**
- Quotations (indigo)
- Repair Progress (teal)
- Invoices (deep orange)

---

## Current State — What's Still Missing

| Feature | Status |
|---------|--------|
| Chat UI (rooms list + messages) | Not built |
| Customer-side search page using `GET /search` | Not built |
| Admin UI | Not built |
| Shop-side create invoice form | Not built (only list + detail) |

---

## Project Stack
- Flutter (Windows desktop + mobile)
- Provider for state management
- Backend: `https://backend-1-s2fl.onrender.com/api/v1`
- Auth: Bearer token (access 30min, refresh 7 days)
- Test accounts: `mechanic1 / mechanic123`, `owner1 / owner123`, `customer1 / customer123`
