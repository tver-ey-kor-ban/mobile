# API Backlog — Mobile Frontend Requirements

**App:** Garage Management Mobile App  
**Backend base URL:** `https://backend-1-s2fl.onrender.com/api/v1`  
**Audience:** Backend team  
**Purpose:** Issues discovered during mobile development that need backend fixes or new endpoints.

Each item has a priority:  
- 🔴 **Critical** — causes broken/missing UI that users see today  
- 🟠 **High** — forces expensive workarounds in the mobile client  
- 🟡 **Medium** — missing data or ambiguous contract  
- 🟢 **Low** — nice-to-have / cleanup

---

## 1. 🔴 `GET /shops` — Inconsistent response shape

### Problem
The endpoint sometimes returns a **flat JSON array** and sometimes returns a **paginated object**. The mobile client had to add special-case detection to handle both:

```dart
// We had to write this because the shape is unpredictable
if (response.data is List) {
  // handle flat array
} else {
  // handle object with 'shops' / 'items' / 'data' key
}
```

### Expected contract
Always return a paginated object:

```json
{
  "items": [
    { "id": 1, "name": "Shop A", "address": "...", "is_active": true, ... }
  ],
  "total": 42,
  "page": 1,
  "limit": 10
}
```

### Why it matters
Every shop-browsing screen (Home, Search) is affected. The flat-array path silently drops pagination metadata (total count, current page), making infinite scroll impossible to implement correctly.

---

## 2. 🔴 `GET /customers/shops/{shopId}/browse/products` and `browse/services` — No search parameter

### Problem
Neither browse endpoint accepts a `search` (or `q`) query parameter. Because of this, the global product search feature must:

1. Fetch all active shops (`GET /shops`)
2. For each shop, fetch **all** its products and services
3. Filter results in memory on the device

For 10 shops that is **20 parallel API calls** triggered by every single search keystroke. This will not scale and puts unnecessary load on the server.

### Required change
Add a `search` query parameter to both endpoints:

```
GET /customers/shops/{shopId}/browse/products?search=oil+filter&page=1&limit=20
GET /customers/shops/{shopId}/browse/services?search=oil+change&page=1&limit=20
```

`search` should do a **case-insensitive partial match** on `name`, `description`, `brand`, and `category` (for products) or `name` and `description` (for services).

---

## 3. 🟠 Need a global product/service search endpoint

### Problem
There is no endpoint to search across all shops at once. The current workaround (described in item 2 above) is the only option.

### Required new endpoint

```
GET /api/v1/search?q=oil+filter&type=products&page=1&limit=20
```

| Query param | Type | Description |
|---|---|---|
| `q` | string, required | Search term |
| `type` | `products` / `services` / `all` | Default `all` |
| `page` | int | Default `1` |
| `limit` | int | Default `20` |

### Expected response

```json
{
  "items": [
    {
      "type": "product",
      "id": 5,
      "name": "Oil Filter",
      "description": "OEM quality",
      "price": 15.99,
      "currency": "USD",
      "category": "Filters",
      "brand": "Toyota",
      "is_available": true,
      "stock_quantity": 40,
      "rating": 4.3,
      "rating_count": 12,
      "shop": {
        "id": 2,
        "name": "Toyota Service Center",
        "address": "123 Main St"
      }
    },
    {
      "type": "service",
      "id": 3,
      "name": "Oil Change",
      "price": 49.99,
      "currency": "USD",
      "estimated_duration_minutes": 30,
      "is_available": true,
      "rating": 4.7,
      "rating_count": 30,
      "shop": {
        "id": 2,
        "name": "Toyota Service Center",
        "address": "123 Main St"
      }
    }
  ],
  "total": 54,
  "page": 1,
  "limit": 20
}
```

---

## 4. 🟠 `GET /shops` — Authentication requirement unclear

### Problem
The PROJECT.md documents `GET /shops` as **requires auth**. But the UI design requires unauthenticated users to browse shops (before logging in). The mobile client currently:
- Always sends the token if one is available
- But if the user is not logged in, the request fails with 401 and the home page shows an error

### Required change
Make `GET /shops` and `GET /shops/{id}` publicly accessible without a Bearer token. Authenticated users may optionally receive personalised data (e.g. favourite flags) but the base list should work for everyone.

---

## 5. 🟠 Standardise paginated response envelope

### Problem
Different endpoints use different key names for the same concepts. The mobile client currently guesses across multiple fallback keys:

| Field | Keys seen in responses |
|---|---|
| Items array | `shops`, `items`, `data`, `products`, `services` |
| Total count | `total`, `total_count` |
| Current page | `page`, `current_page` |
| Page size | `limit`, `per_page`, `size` |
| Service duration | `estimated_duration_minutes`, `estimated_minutes`, `duration_minutes` |

### Required standard
Adopt one envelope for **all** paginated list responses:

```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "limit": 20
}
```

And one field name for service duration: **`estimated_duration_minutes`** (integer, minutes).

---

## 6. 🟡 Browse endpoints — Products and services missing rating data

### Problem
The mobile product/service detail sheet displays `rating` and `rating_count` per item. These fields are defined in the mobile model but appear to return `null` from the browse endpoints. Ratings are only fetchable via separate endpoints (`GET /ratings/products/{id}/reviews`), which would require one extra call per item displayed.

### Required change
Include `rating` (float, 1 decimal) and `rating_count` (int) in the browse response for each product and service:

```json
{
  "id": 5,
  "name": "Oil Filter",
  "price": 15.99,
  "is_available": true,
  "rating": 4.3,
  "rating_count": 12,
  ...
}
```

---

## 7. 🟡 `POST /auth/refresh` — Undocumented request/response contract

### Problem
The mobile client saves the refresh token but the auto-refresh flow is **not wired up** because the request and response format are unknown.

### Required documentation
Please confirm:

| Item | Detail needed |
|---|---|
| Request body | Is it `{ "refresh_token": "..." }` or form-encoded? |
| Response body | Same as login response? Does it return a new refresh token too? |
| Error code | What status is returned when the refresh token is expired? |
| Expiry | How long does the access token last? How long does the refresh token last? |

Once confirmed, the mobile client will implement silent token refresh automatically.

---

## 8. 🟡 `GET /customers/shops/{shopId}/browse/shop-info` — Unknown response shape

### Problem
This endpoint is defined in the mobile constants but is never called because the response shape is unknown and the mobile client cannot infer it.

### Required documentation
Provide a sample response. If it duplicates `GET /shops/{id}`, it can be removed. If it contains richer data (opening hours, photos, mechanic list, etc.), the mobile client will add a dedicated shop info section to `ShopDetailPage`.

---

## 9. 🟡 Products and services need single-item detail endpoints

### Problem
There are no endpoints to fetch a single product or service by ID in the customer-facing browse context. If a user opens a product detail sheet and the item needs to be refreshed (e.g. stock changed), the app must re-fetch the entire shop product list.

### Required new endpoints

```
GET /customers/shops/{shopId}/browse/products/{productId}
GET /customers/shops/{shopId}/browse/services/{serviceId}
```

Response: single product/service object (same shape as items in the list response).

---

## 10. 🟢 `GET /shops/{shopId}/products/search` — Auth and usage

### Problem
The endpoint `/shops/{shopId}/products/search` exists in constants but it is unclear whether it:
- Requires owner/mechanic auth (shop management context), or
- Can be used as a customer-facing search

If it is owner-only, a separate customer-facing search endpoint is needed (see item 3).  
If it is public, document the query parameters so the mobile client can use it instead of the workaround.

---

## 11. 🟢 Image search endpoint not implemented

### Problem
`POST /shops/{shopId}/products/search-by-image` returns a 404 or is not yet active. The mobile image search screen currently returns hardcoded mock data and shows a placeholder UI.

### Required action
Either:
- Implement the endpoint and document the request format (multipart image upload + optional text query)
- Or confirm it is out of scope so the mobile client can hide the feature entirely

---

## 12. 🟢 `GET /categories` — Undocumented / unused

### Problem
A `categories` endpoint is defined in mobile constants but the response shape is unknown and no UI uses it.

### Required action
If categories exist on products/services, document the response so the mobile client can add **category filter chips** to the browse and search pages (e.g. filter by "Filters", "Oils", "Tyres").

Expected shape:

```json
[
  { "id": 1, "name": "Filters", "slug": "filters" },
  { "id": 2, "name": "Engine Oils", "slug": "engine-oils" }
]
```

---

## Summary table

| # | Endpoint | Priority | Type |
|---|---|---|---|
| 1 | `GET /shops` — response shape | 🔴 Critical | Fix existing |
| 2 | `GET /customers/shops/{id}/browse/products` — add `search` param | 🔴 Critical | Enhancement |
| 3 | `GET /api/v1/search` — global search | 🟠 High | New endpoint |
| 4 | `GET /shops` — make public | 🟠 High | Fix existing |
| 5 | All paginated endpoints — standardise envelope | 🟠 High | Fix existing |
| 6 | Browse endpoints — include `rating` + `rating_count` | 🟡 Medium | Enhancement |
| 7 | `POST /auth/refresh` — document contract | 🟡 Medium | Documentation |
| 8 | `GET /browse/shop-info` — document or remove | 🟡 Medium | Documentation |
| 9 | Single product/service detail endpoints | 🟡 Medium | New endpoint |
| 10 | `GET /shops/{id}/products/search` — clarify auth | 🟢 Low | Documentation |
| 11 | Image search endpoint | 🟢 Low | New endpoint |
| 12 | `GET /categories` — document response | 🟢 Low | Documentation |
