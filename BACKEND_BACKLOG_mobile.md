# Mobile App — Session Summary & Backend API Backlog

> **Branch:** `26-intergrate-new-api-for-search`  
> **Date:** 2026-05-19  
> **Base URL:** `https://backend-1-s2fl.onrender.com/api/v1`

---

## Part 1 — What Was Fixed & Built This Session

### Fix 1 — Hot Reload Crash in BookingPage
**Error:** `NoSuchMethodError: No constructor '' declared in class 'null'` at `booking_page.dart:304`

**Cause:** `booking_page.dart` was heavily rewritten (old state class had `currentStep`, `selectedServiceNames`; new class has `_step`, `_selectedCar`, etc.). When Flutter hot-reloaded with 11 libraries, the old `_BookingPageState` instance was preserved with the old memory layout but the new `build()` code ran against it, causing a null class reference error.

**Fix:** Not a code bug — do a **full hot restart** (`Shift+R`) after major state class refactors. The code itself is correct.

---

### Fix 2 — Booking Service Selection Logic
**Files changed:**
- `lib/features/booking/presentation/pages/booking_page.dart`
- `lib/features/booking/data/models/booking_request_model.dart`

**Changes made:**
| What | Before | After |
|------|--------|-------|
| Service selection | Single `ShopServiceItem?` (radio toggle) | Kept as single — matches API's `service_id: int?` |
| Date/time (Step 3) | Always required | Required only when a service is selected; product-only orders show `"(optional for product orders)"` hint |
| Step 3 validation | `_appointmentDate != null` | `_selectedService == null \|\| _appointmentDate != null` |
| API model `appointmentDate` | `required DateTime` | `DateTime?` (nullable) so product-only orders can omit it |
| API model `serviceId` | `int?` sent as `service_id` | Unchanged — matches backend |

**Why single service:** The backend API `POST /product-orders/unified-booking` only accepts one `service_id`. Multi-select would require a backend change.

---

### Feature 1 — Edit Profile Page
**File created:** `lib/features/profile/presentation/pages/edit_profile_page.dart`

**What it does:**
- Editable fields: **Full Name**, **Phone Number**
- Read-only fields: **Email**, **Username** (shown with lock icon + tooltip)
- Saves locally via `auth.updateProfile(name, phone)` → SharedPreferences
- Shows green success snackbar on save, pops back to Profile

**Known limitation:** No `PUT /auth/me` endpoint exists on the backend yet. Changes are saved locally only and will reset on re-login. See backlog item #7.

---

### Feature 2 — Help & Support Page
**File created:** `lib/features/profile/presentation/pages/help_support_page.dart`

**What it contains:**
- Red gradient header banner
- Two contact cards: Email Us / Call Us
- 6 expandable FAQ tiles (booking, cancellation, repair tracking, invoices, vehicles, payment)
- App info section (Version, Terms of Service, Privacy Policy)

---

### Feature 3 — Profile Page Wiring
**File changed:** `lib/features/profile/presentation/pages/profile_page.dart`

- Replaced two `// TODO` stubs with actual `Navigator.push` to `EditProfilePage` and `HelpSupportPage`

---

### Feature 4 — Product & Service Rating
**Files changed:**
- `lib/features/shop/presentation/widgets/item_detail_sheet.dart`

**What was already built (pre-existing):**
- `RatingsApiService` — full API calls (rate product, rate service, get reviews, get summary)
- `RatingDialog` / `showRatingDialog` — 5-star picker + review text field widget
- `RatingModel` — request/response models

**What was missing (now fixed):**
The dialog was never called from any UI. Added to both detail sheets:

| Sheet | New button | Behavior |
|-------|-----------|---------|
| Product detail | `★ Rate this Product` (amber outlined) | Auth check → rating dialog → `POST /ratings/products` |
| Service detail | `★ Rate this Service` (amber outlined) | Auth check → rating dialog → `POST /ratings/services` |

- Unauthenticated users see a snackbar: _"Please sign in to leave a rating"_
- On success: green snackbar _"Thank you for your rating!"_
- Both the rate button and the main CTA (Order Now / Book Now) are shown together

**Known issue:** Rating POST URL may be wrong — see backlog item #1.

---

## Part 2 — Backend API Backlog

> Cross-referenced from `API_DOCUMENTATION.md`, `api_constants.dart`, and all service files.

### Priority Legend
| Label | Meaning |
|-------|---------|
| 🔴 P0 | Blocker — feature is broken right now |
| 🟠 P1 | High — UI exists but silently fails |
| 🟡 P2 | Medium — partially working or undocumented |
| 🟢 P3 | Low — future feature |

---

### 🔴 P0 Blockers

#### #1 — Rating POST URL mismatch
Frontend sends `product_id` in the **body** to `/ratings/products`.  
API doc says `product_id` goes in the **URL path**: `POST /ratings/products/{product_id}`.

| What frontend sends | What API expects |
|--------------------|-----------------|
| `POST /ratings/products` + `{ "product_id": 5, "rating": 4 }` | `POST /ratings/products/5` + `{ "rating": 4 }` |
| `POST /ratings/services` + `{ "service_id": 2, "rating": 4 }` | `POST /ratings/services/2` + `{ "rating": 4 }` |

**Fix (backend):** Accept `product_id` / `service_id` from URL path. Body fields optional for backwards compat.  
**Or (frontend):** Update `ApiConstants.rateProduct` → `$apiVersion/ratings/products/$productId` and remove ID from body.

---

#### #2 — Customer Vehicles path mismatch
Frontend uses `/my-vehicles`. API doc uses `/customer-vehicles`.

| Frontend path | API doc path | Status |
|--------------|-------------|--------|
| `GET /my-vehicles` | `GET /customer-vehicles` | ❌ |
| `POST /my-vehicles` | `POST /customer-vehicles` | ❌ |
| `PUT /my-vehicles/{id}` | `PUT /customer-vehicles/{id}` | ❌ |
| `DELETE /my-vehicles/{id}` | `DELETE /customer-vehicles/{id}` | ❌ |
| `GET /my-vehicles/primary` | not documented | ❌ |
| `PUT /my-vehicles/{id}/set-primary` | not documented | ❌ |

**Fix:** Add alias `/my-vehicles` → `/customer-vehicles` on backend. Also add `primary` and `set-primary` sub-routes.

---

#### #3 — Vehicle database path mismatch
| Frontend path | API doc path | Status |
|--------------|-------------|--------|
| `GET /vehicles/models/{modelId}/years` | `GET /vehicles/makes/{makeId}/models/{modelId}/years` | ❌ |
| `GET /vehicles/years/{yearId}/engines` | `GET /vehicles/makes/{makeId}/models/{modelId}/years/{yearId}/engines` | ❌ |
| `GET /vehicles/fuel-types` | not documented | ❌ |
| `GET /vehicles/hierarchy` | not documented | ❌ |
| `GET /vehicles/search` | not documented | ❌ |
| `GET /vehicles/validate` | not documented | ❌ |

**Fix:** Add shorter alias paths or update API docs to match what is actually implemented.

---

#### #4 — Customer repair progress list missing
Frontend "My Repairs" page calls `GET /repair-progress/my-repairs` (list all).  
API only documents `GET /repair-progress/my-repairs/{appointment_id}` (single detail).

**Fix:** Add:
```
GET /repair-progress/my-repairs
Response: [ { appointment_id, stage, updated_at, ... } ]
```

---

#### #5 — Customer quotation endpoints missing
Frontend "My Quotations" page calls endpoints that don't exist. API only has shop-side routes.

**Fix:** Add:
```
GET  /quotations/my-quotations              — list quotations sent to me
GET  /quotations/my-quotations/{id}         — detail
POST /quotations/my-quotations/{id}/action  — body: { "action": "accept" | "reject" }
```

---

#### #6 — Customer invoice endpoints missing
Frontend "My Invoices" page calls endpoints that don't exist. API only has shop-side routes.

**Fix:** Add:
```
GET /invoices/my-invoices        — list invoices issued to me
GET /invoices/my-invoices/{id}   — detail with line items
```

---

### 🟠 P1 High Priority

#### #7 — No profile update endpoint
Edit Profile page saves name/phone **locally only**. No backend persistence.

**Fix:** Add:
```
PUT /auth/me   🔒
Body:     { "full_name": "string", "phone": "string?" }
Response: UserResponse (updated)
```

---

#### #8 — Customer cancel product order missing
Frontend has `PUT /product-orders/my-orders/{id}/cancel` — not in API docs.

**Fix:** Add:
```
PUT /product-orders/my-orders/{id}/cancel   🔒
Allowed only when order status is "pending"
Response: { "message": "Order cancelled" }
```

---

#### #9 — Mechanic performance path mismatch
| Frontend path | API doc path |
|--------------|-------------|
| `GET /shops/{shopId}/mechanics/performance` | `GET /mechanic/shops/{shopId}/performance` |
| `POST /shops/{shopId}/mechanics/{id}/performance/record` | `POST /mechanic/shops/{shopId}/performance` |
| `GET /shops/{shopId}/mechanics/{id}/performance` | `GET /mechanic/shops/{shopId}/performance/{mechanic_id}` |

**Fix:** Add path aliases under `/shops/{shopId}/mechanics/...` or update frontend constants to use `/mechanic/shops/...`.

---

#### #10 — Mechanic rate endpoint not documented
Frontend calls `POST /shops/{shopId}/mechanics/{mechanicId}/rate` — not in API docs.

**Fix:** Add (or document if already exists):
```
POST /shops/{shop_id}/mechanics/{mechanic_id}/rate   🔒
Body:     { "appointment_id": int, "rating": 1–5, "review": "string?" }
Response: RatingResponse
```

---

### 🟡 P2 Medium Priority

#### #11 — Rating sub-paths not in API docs
The following are called by the frontend but missing from the API documentation (may already be implemented — need verification):

| Endpoint | Docs status |
|----------|------------|
| `GET /ratings/products/{id}/summary` | ❌ not documented |
| `GET /ratings/products/{id}/reviews` | ❌ not documented |
| `GET /ratings/services/{id}/summary` | ❌ not documented |
| `GET /ratings/services/{id}/reviews` | ❌ not documented |
| `GET /ratings/shops/{shopId}/top-products` | ❌ not documented |
| `GET /ratings/shops/{shopId}/top-services` | ❌ not documented |
| `GET /ratings/my-ratings` | ❌ not documented |

**Fix:** Add to API docs (and implement any that are missing).

---

#### #12 — Price calculation endpoints undocumented
| Endpoint | Docs status |
|----------|------------|
| `POST /product-orders/calculate-price` | ❌ not documented |
| `GET /product-orders/my-orders/{id}/price-breakdown` | ❌ not documented |

**Fix:** Document if implemented; remove from frontend constants if not.

---

#### #13 — Shop statistics missing from frontend constants
`GET /shops/{shop_id}/statistics` is in the API docs (🔧) but missing from `api_constants.dart`.

**Fix (frontend):** Add:
```dart
static String shopStatistics(int shopId) =>
    '$apiVersion/shops/$shopId/statistics';
```

---

#### #14 — Category extra endpoints undocumented
| Frontend constant | Docs status |
|------------------|------------|
| `GET /categories/{id}/products` | ❌ not documented |
| `GET /categories/by-service/{serviceId}` | ❌ not documented |
| `GET /categories/service-links` | ❌ not documented |

**Fix:** Document these endpoints or remove the constants.

---

### 🟢 P3 Future / Nice to Have

#### #15 — Chat UI not built
Backend has a complete chat API. Frontend has all `ApiConstants` defined. No UI exists.

Endpoints ready to build UI for:
```
POST /chat/rooms
GET  /chat/rooms
GET  /chat/rooms/{room_id}
POST /chat/rooms/{room_id}/messages
GET  /chat/rooms/{room_id}/messages
```

Also add to docs (not currently documented):
```
PUT /chat/rooms/{room_id}/messages/{id}/read
GET /chat/rooms/{room_id}/unread-count
PUT /chat/rooms/{room_id}/close
```

---

#### #16 — Image search placeholder
`POST /shops/{shop_id}/products/search-by-image` — ML not implemented on backend.  
Frontend service class is ready. Implement when ML is available.

---

## Summary Table

| # | Issue | Priority | Owner |
|---|-------|----------|-------|
| 1 | Rating POST — ID in body vs URL path | 🔴 P0 | Backend or Frontend |
| 2 | Customer vehicles — wrong base path | 🔴 P0 | Backend |
| 3 | Vehicle DB — path mismatch + missing routes | 🔴 P0 | Backend |
| 4 | Customer repair list endpoint missing | 🔴 P0 | Backend |
| 5 | Customer quotation endpoints missing | 🔴 P0 | Backend |
| 6 | Customer invoice endpoints missing | 🔴 P0 | Backend |
| 7 | No `PUT /auth/me` profile update | 🟠 P1 | Backend |
| 8 | Customer cancel order endpoint missing | 🟠 P1 | Backend |
| 9 | Mechanic performance path mismatch | 🟠 P1 | Backend or Frontend |
| 10 | Mechanic rate endpoint undocumented | 🟠 P1 | Backend |
| 11 | Rating sub-paths not in docs | 🟡 P2 | Backend |
| 12 | Price calculation endpoints undocumented | 🟡 P2 | Backend |
| 13 | Shop statistics missing from frontend constants | 🟡 P2 | Frontend |
| 14 | Category extra endpoints undocumented | 🟡 P2 | Backend |
| 15 | Chat — no UI built | 🟢 P3 | Frontend |
| 16 | Image search — ML not implemented | 🟢 P3 | Backend |
