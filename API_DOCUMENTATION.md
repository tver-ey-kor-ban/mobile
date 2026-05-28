# API Documentation — Garage Management Backend

**Live base URL:** `https://backend-1-s2fl.onrender.com/api/v1`  
**Local base URL:** `http://localhost:8000/api/v1`  
**Interactive docs:** `http://localhost:8000/docs`

---

## Conventions

### Auth icons
| Icon | Meaning |
|------|---------|
| 🌐 | Public — no token required |
| 🔒 | Any authenticated user |
| 🔧 | Shop member (owner **or** mechanic) |
| 👑 | Shop owner only |
| 🛡️ | Platform admin (`is_superuser=true`) |

### Paginated envelope
All list endpoints return:
```json
{ "items": [...], "total": 100, "page": 1, "limit": 20 }
```
Standard query params: `?page=1&limit=20` (limit max varies per endpoint).

### Appointment statuses
`pending` · `confirmed` · `in_progress` · `completed` · `cancelled` · `rejected`

### Order statuses
`pending` · `confirmed` · `processing` · `ready` · `completed` · `cancelled`

### Error shape
```json
{ "detail": "Human-readable error message" }
```

---

## Authentication (`/auth`)

### `POST /auth/register`  🌐
Register a new user.

**Body:**
```json
{ "email": "user@example.com", "username": "user1", "password": "secret", "full_name": "Full Name" }
```
**Response `200`:** `UserRead`

---

### `POST /auth/login`  🌐
Login with username/password (form-encoded).

**Body (form):** `username`, `password`

**Response `200`:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer"
}
```
Access token expires in **30 minutes**. Refresh token expires in **7 days**.

---

### `GET /auth/me`  🔒
Get the current authenticated user's profile.

**Response `200`:** `UserResponse`

---

### `GET /auth/me/roles`  🔒
Get current user's roles including all active shop memberships.

**Response `200`:**
```json
{
  "username": "owner1",
  "roles": ["user", "owner"],
  "is_superuser": false,
  "shop_roles": [
    { "shop_id": 1, "role": "owner" },
    { "shop_id": 3, "role": "mechanic" }
  ]
}
```
> `shop_roles` is derived live from `UserShop` records — use this instead of a separate `GET /shops/my-shops` call to determine role on login.

---

### `POST /auth/refresh`  🌐
Exchange a refresh token for a new access token.

**Body:**
```json
{ "refresh_token": "eyJ..." }
```
**Response `200`:** `Token` (new access token; refresh token is unchanged)

---

### `POST /auth/logout`  🔒
Revoke a refresh token.

**Body:**
```json
{ "refresh_token": "eyJ..." }
```
**Response `200`:** `{ "message": "Successfully logged out" }`

---

### `POST /auth/logout-all`  🔒
Revoke all refresh tokens for the current user (log out all devices).

**Response `200`:** `{ "message": "...", "revoked_tokens": 3 }`

---

## Shops (`/shops`)

### `GET /shops`  🌐
List all active shops (paginated).

**Query params:** `page`, `limit` (max 100)

**Response `200`:**
```json
{ "items": [ShopRead], "total": 10, "page": 1, "limit": 20 }
```

---

### `POST /shops`  🔒
Create a new shop. The authenticated user automatically becomes owner.

**Body:** `ShopCreate` (`name`, `description?`, `address?`, `phone?`, `email?`)

**Response `201`:** `ShopRead`

---

### `GET /shops/my-shops`  🔒
List all shops where the current user is an active member (owner or mechanic).

**Response `200`:**
```json
[{ "shop_id": 1, "shop_name": "Garage A", "role": "owner", "is_active": true }]
```

---

### `GET /shops/{shop_id}`  🌐
Get public details for a specific shop.

**Response `200`:** `ShopRead` · `404` if not found or inactive

---

### `PUT /shops/{shop_id}`  👑
Update shop details. Owner only.

**Body:** `ShopCreate`  
**Response `200`:** `ShopRead`

---

### `DELETE /shops/{shop_id}`  👑
Soft-delete a shop (`is_active = false`). Owner only.

**Response `200`:** `{ "message": "Shop deleted successfully" }`

---

### `GET /shops/{shop_id}/statistics`  🔧
Get operational statistics for a shop.

**Response `200`:**
```json
{
  "shop_id": 1,
  "appointments": {
    "total": 45, "pending": 3, "confirmed": 5,
    "completed": 35, "cancelled": 2, "rejected": 0
  },
  "orders": {
    "total": 30, "pending": 2, "confirmed": 4,
    "processing": 1, "ready": 0, "completed": 22, "cancelled": 1
  },
  "revenue": { "appointments": 1800.00, "orders": 450.50, "total": 2250.50 },
  "products": 24,
  "services": 8
}
```

---

### `POST /shops/{shop_id}/members`  👑
Add a user as owner or mechanic.

**Body:** `{ "user_id": 5, "shop_id": 1, "role": "mechanic" }`  
**Response `200`:** `{ "message": "User added as mechanic", "user_shop": {...} }`

---

### `GET /shops/{shop_id}/members`  🔧
List all active members of the shop.

**Response `200`:**
```json
[{ "user_id": 2, "username": "mech1", "full_name": "Mechanic One", "role": "mechanic", "is_active": true }]
```

---

### `PUT /shops/{shop_id}/members/{user_id}/role`  👑
Change a member's role. Query param: `?new_role=owner|mechanic`

**Response `200`:** `{ "message": "Role updated to owner" }`

---

### `DELETE /shops/{shop_id}/members/{user_id}`  👑
Soft-remove a member (`is_active = false`).

**Response `200`:** `{ "message": "Member removed successfully" }`

---

## Products (`/shops/{shop_id}/products`)

### `POST /shops/{shop_id}/products`  👑
Create a product.

**Body:** `ProductCreate` (`name`, `description?`, `price`, `stock_quantity?`, `category_id?`, `image_url?`)  
**Response `201`:** `ProductRead`

---

### `GET /shops/{shop_id}/products`  🔧
List all active products in the shop.

**Response `200`:** `[ProductRead]`

---

### `GET /shops/{shop_id}/products/search`  🔧
Search/filter products.

**Query params:** `q`, `category_id`, `min_price`, `max_price`  
**Response `200`:** `[ProductRead]`

---

### `GET /shops/{shop_id}/products/{product_id}`  🔧
Get one product.

**Response `200`:** `ProductRead` · `404` if not found

---

### `PUT /shops/{shop_id}/products/{product_id}`  👑
Update a product.

**Body:** `ProductCreate`  
**Response `200`:** `ProductRead`

---

### `DELETE /shops/{shop_id}/products/{product_id}`  👑
Soft-delete a product.

**Response `200`:** `{ "message": "Product deleted successfully" }`

---

### `POST /shops/{shop_id}/products/search-by-image`  🔧
Visual search placeholder — returns products with images. ML not implemented.

---

### `GET /shops/{shop_id}/products/by-service/{service_id}`  🔧
Get product recommendations linked to a service via shared categories.

---

## Services (`/shops/{shop_id}/services`)

Mirrors the Products endpoints. All write operations require 👑; reads require 🔧.

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/shops/{shop_id}/services` | Create |
| `GET` | `/shops/{shop_id}/services` | List |
| `GET` | `/shops/{shop_id}/services/{service_id}` | Detail |
| `PUT` | `/shops/{shop_id}/services/{service_id}` | Update |
| `DELETE` | `/shops/{shop_id}/services/{service_id}` | Soft-delete |

**Service fields:** `name`, `description?`, `price`, `duration_minutes?`, `service_type` (`shop_based` | `mobile` | `pickup_drop`), `image_url?`  
Response field: `estimated_duration_minutes` (alias of `duration_minutes`)

---

## Categories (`/categories`)

### `GET /categories`  🌐
List all root-level active product categories.

### `GET /categories/tree`  🌐
Full nested category tree.

### `POST /categories`  🛡️
Create a category (admin only).

### `PUT /categories/{id}`  🛡️
Update a category.

### `DELETE /categories/{id}`  🛡️
Delete a category.

---

## Vehicles (`/vehicles`)

All public — no token required.

| Method | Path | Notes |
|--------|------|-------|
| `GET` | `/vehicles/makes` | List all makes |
| `GET` | `/vehicles/makes/{make_id}/models` | Models for a make |
| `GET` | `/vehicles/makes/{make_id}/models/{model_id}/years` | Years |
| `GET` | `/vehicles/makes/{make_id}/models/{model_id}/years/{year_id}/engines` | Engines |

---

## Customer Vehicles (`/customer-vehicles`)  🔒

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/customer-vehicles` | Add a vehicle to profile |
| `GET` | `/customer-vehicles` | List my vehicles |
| `GET` | `/customer-vehicles/{id}` | Detail |
| `PUT` | `/customer-vehicles/{id}` | Update |
| `DELETE` | `/customer-vehicles/{id}` | Remove |

---

## Public Browse (`/customers/shops/{shop_id}/browse`)  🌐

No authentication required for any browse endpoint.

### `GET /customers/shops/{shop_id}/browse/shop-info`
Public shop profile.

### `GET /customers/shops/{shop_id}/browse/products`
Browse products with ratings.

**Query params:** `search`, `category_id`, `page`, `limit`  
**Response `200`:** paginated `{ items, total, page, limit }` — each item includes `rating`, `rating_count`, `is_available`

### `GET /customers/shops/{shop_id}/browse/products/{product_id}`
Single product detail with ratings.

### `GET /customers/shops/{shop_id}/browse/services`
Browse services with ratings.

**Query params:** `search`, `page`, `limit`

### `GET /customers/shops/{shop_id}/browse/services/{service_id}`
Single service detail with ratings.

---

## Customer Bookings (`/customers`)  🔒

### `GET /customers/my-appointments`
List the current customer's appointments.

**Query params:** `status` (`pending` | `confirmed` | `in_progress` | `completed` | `cancelled` | `rejected`)  
**Response `200`:** `[AppointmentRead]`

### `GET /customers/my-appointments/{appointment_id}`
Get one appointment's detail.

### `PUT /customers/my-appointments/{appointment_id}/cancel`
Cancel an appointment (not allowed if already completed).

**Response `200`:** `{ "message": "Appointment cancelled successfully" }`

### `GET /customers/my-service-history`
Service completion history.

**Query params:** `shop_id` (optional filter)

---

## Shop Appointments (Owner/Mechanic View) (`/customers`)  🔧

### `GET /customers/shops/{shop_id}/appointments`
Full appointment list for the shop, with optional filtering.

**Query params:** `status`, `date_from`, `date_to`  
**Response `200`:** `[AppointmentRead]`

### `PUT /customers/shops/{shop_id}/appointments/{appointment_id}/status`
Update appointment status directly.

**Query param:** `?new_status=completed`

---

## Unified Booking (`/product-orders`)  🔒

### `POST /product-orders/unified-booking`
Book a service, order products, or both in one request. Preferred over the legacy `/customers/appointments` endpoint.

**Body:**
```json
{
  "shop_id": 1,
  "service_id": 2,
  "appointment_date": "2025-06-01T10:00:00",
  "vehicle_info": "Toyota Camry 2020",
  "product_items": [{ "product_id": 5, "quantity": 2 }],
  "pickup_date": "2025-06-02T14:00:00",
  "notes": "Optional note",
  "is_mobile_service": false,
  "coupon_code": null
}
```

**Response `201`:**
```json
{
  "appointment": {
    "id": 10, "status": "pending",
    "pricing": { "service_price": 50, "mobile_service_fee": 0, "discount": 0, "tax": 0, "total": 50 }
  },
  "product_order": {
    "id": 7, "status": "pending", "total_amount": 75.00
  }
}
```

---

### `GET /product-orders/my-orders`  🔒
List the current customer's product orders.

**Query params:** `status`  
**Response `200`:** `[ProductOrderRead]`

### `GET /product-orders/my-orders/{order_id}`  🔒
Order detail including line items.

---

## Mechanic Bookings (`/mechanic`)  🔧

### `GET /mechanic/shops/{shop_id}/pending-bookings`
Paginated list of pending service appointments.

**Query params:** `page`, `limit` (max 200, default 50)

**Response `200`:**
```json
{
  "total": 12, "page": 1, "limit": 50,
  "items": [{
    "appointment_id": 5,
    "customer": { "id": 3, "name": "John Doe", "phone": "john" },
    "vehicle_info": "Toyota Camry 2020",
    "appointment_date": "...",
    "service_price": 50.0,
    "mobile_service_fee": 0.0,
    "total_amount": 50.0,
    "notes": null
  }]
}
```

---

### `GET /mechanic/shops/{shop_id}/bookings/{appointment_id}`  🔧
Detailed view of a single booking.

---

### `POST /mechanic/shops/{shop_id}/bookings/{appointment_id}/action`  🔧
Accept or reject a pending booking.

**Body:**
```json
{ "action": "accept", "notes": "See you then!" }
{ "action": "reject", "reason": "Fully booked" }
```

**Response `200`:**
```json
{ "success": true, "message": "...", "appointment_id": 5, "new_status": "confirmed", "customer_notified": true }
```
> `reject` → status becomes **`rejected`** (not `cancelled`). Admin can filter `?status=rejected`.

---

### `GET /mechanic/shops/{shop_id}/today-bookings`  🔧
Today's confirmed bookings.

**Response `200`:**
```json
{ "date": "2025-05-16", "count": 3, "bookings": [...] }
```

---

### `GET /mechanic/shops/{shop_id}/pending-orders`  🔧
Paginated list of pending product orders.

**Query params:** `page`, `limit` (max 200, default 50)

**Response `200`:**
```json
{
  "total": 4, "page": 1, "limit": 50,
  "items": [{
    "order_id": 7,
    "customer": { "id": 3, "name": "Jane", "phone": "jane" },
    "total_amount": 75.00, "items_count": 2,
    "pickup_date": "...", "notes": null
  }]
}
```

---

### `POST /mechanic/shops/{shop_id}/orders/{order_id}/action`  🔧
Accept or reject a pending product order.

**Body:** `{ "action": "accept" }` or `{ "action": "reject", "reason": "Out of stock" }`

> `reject` → status becomes **`cancelled`** and stock is restored.

---

### `PUT /mechanic/shops/{shop_id}/orders/{order_id}/ready`  🔧
Mark a confirmed order as ready for pickup.

---

### `GET /mechanic/my-notifications`  🔒
Notifications for the current user.

**Query params:** `status` (`unread` | `read`), `limit` (max 100)

**Response `200`:**
```json
{
  "unread_count": 2,
  "notifications": [{ "id": 1, "type": "...", "title": "...", "message": "...", "status": "unread", ... }]
}
```

---

### `PUT /mechanic/notifications/{notification_id}/read`  🔒
Mark a notification as read.

---

## Mechanic Performance (`/mechanic`)  🔧

| Method | Path |
|--------|------|
| `POST` | `/mechanic/shops/{shop_id}/performance` |
| `GET` | `/mechanic/shops/{shop_id}/performance` |
| `GET` | `/mechanic/shops/{shop_id}/performance/{mechanic_id}` |

---

## Ratings (`/ratings`)

### `POST /ratings/products/{product_id}`  🔒
Rate a product (1–5 stars).

### `GET /ratings/products/{product_id}`  🌐
List ratings for a product.

### `POST /ratings/services/{service_id}`  🔒
Rate a service.

### `GET /ratings/services/{service_id}`  🌐
List ratings for a service.

---

## Quotations (`/quotations`)  🔧

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/quotations/shops/{shop_id}` | Create draft |
| `GET` | `/quotations/shops/{shop_id}` | List (`?status=draft\|sent\|accepted\|rejected`) |
| `GET` | `/quotations/shops/{shop_id}/{quotation_id}` | Detail |
| `PUT` | `/quotations/shops/{shop_id}/{quotation_id}` | Update draft |
| `POST` | `/quotations/shops/{shop_id}/{quotation_id}/send` | Send to customer |
| `DELETE` | `/quotations/shops/{shop_id}/{quotation_id}` | Delete |

---

## Repair Progress (`/repair-progress`)  🔧

7-stage repair tracking: `received` → `diagnosed` → `parts_ordered` → `in_repair` → `quality_check` → `ready` → `delivered`

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/repair-progress/shops/{shop_id}/appointments/{id}` | Start tracking |
| `GET` | `/repair-progress/shops/{shop_id}/appointments/{id}` | Current stage |
| `POST` | `/repair-progress/shops/{shop_id}/appointments/{id}/update` | Advance stage |
| `GET` | `/repair-progress/my-repairs/{appointment_id}` | 🔒 Customer view |

---

## Invoices (`/invoices`)  🔧

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/invoices/shops/{shop_id}` | Create invoice |
| `GET` | `/invoices/shops/{shop_id}` | List |
| `GET` | `/invoices/shops/{shop_id}/{invoice_id}` | Detail |
| `POST` | `/invoices/shops/{shop_id}/{invoice_id}/send` | Send to customer |
| `POST` | `/invoices/shops/{shop_id}/{invoice_id}/record-payment` | Record payment |

---

## Chat (`/chat`)  🔒

| Method | Path | Notes |
|--------|------|-------|
| `POST` | `/chat/rooms` | Create a room |
| `GET` | `/chat/rooms` | List my rooms |
| `GET` | `/chat/rooms/{room_id}` | Room detail |
| `POST` | `/chat/rooms/{room_id}/messages` | Send a message |
| `GET` | `/chat/rooms/{room_id}/messages` | Message history |

---

## Global Search (`/search`)  🌐

### `GET /search`
Search products and services across all active shops.

**Query params:**
- `q` — search term (required, min 1 char)
- `type` — `products` | `services` | `all` (default `all`)
- `page`, `limit` (max 100)

**Response `200`:**
```json
{
  "items": [{
    "type": "product",
    "id": 3, "name": "Oil Filter", "price": 25.00,
    "rating": 4.5, "rating_count": 12, "is_available": true,
    "shop": { "id": 1, "name": "Garage A", "address": "..." }
  }],
  "total": 42, "page": 1, "limit": 20
}
```

---

## Admin (`/admin`)  🛡️

All endpoints require `is_superuser=true`.

---

### Users

#### `GET /admin/users`
**Query params:** `page`, `limit` (max 1000), `search`, `is_active`, `is_superuser`

**Response `200`:** `{ "items": [...], "total": N, "page": 1, "limit": 100 }`

#### `GET /admin/users/{user_id}`
User detail including `shop_memberships`.

#### `PUT /admin/users/{user_id}/status`
**Query param:** `?is_active=false`

#### `PUT /admin/users/{user_id}/role`
**Query param:** `?is_superuser=true`

#### `DELETE /admin/users/{user_id}`
Hard-delete a user.

---

### Shops

#### `GET /admin/shops`
**Query params:** `page`, `limit` (max 1000), `search` (name, case-insensitive), `is_active`

**Response `200`:** `{ "items": [...], "total": N, "page": 1, "limit": 100 }`

#### `GET /admin/shops/{shop_id}`
Shop detail with member list and counts.

#### `PUT /admin/shops/{shop_id}/status`
Toggle shop active/inactive **without deleting it**.

**Query param:** `?is_active=false`

**Response `200`:**
```json
{ "message": "Shop deactivated successfully", "shop_id": 1, "is_active": false }
```

#### `DELETE /admin/shops/{shop_id}`
Hard-delete a shop.

---

### Bookings & Orders

#### `GET /admin/appointments`
**Query params:** `page`, `limit` (max 1000), `status` (including `rejected`), `shop_id`

**Response `200`:** `{ "items": [...], "total": N, "page": 1, "limit": 100 }`

#### `GET /admin/orders`
**Query params:** `page`, `limit` (max 1000), `status`, `shop_id`

**Response `200`:** `{ "items": [...], "total": N, "page": 1, "limit": 100 }`

---

### Ratings

#### `GET /admin/ratings`
Lists product and service ratings in separate arrays.

#### `DELETE /admin/ratings/product/{rating_id}`
#### `DELETE /admin/ratings/service/{rating_id}`

---

### Statistics

#### `GET /admin/statistics`
Platform-wide totals.

**Response `200`:**
```json
{
  "users":   { "total": 120, "active": 115, "inactive": 5, "admins": 2 },
  "shops":   { "total": 18, "active": 15, "inactive": 3 },
  "catalog": { "products": 340, "services": 90 },
  "appointments": { "total": 500, "pending": 20, "completed": 400, "cancelled": 80 },
  "orders":       { "total": 300, "pending": 10, "completed": 260, "cancelled": 30 },
  "revenue": { "appointments": 45000.00, "orders": 12000.00, "total": 57000.00 }
}
```

---

#### `GET /admin/statistics/daily`
Rolling period summary.

**Query params:** `days` (1–365, default 30)

**Response `200`:**
```json
{
  "period_days": 30,
  "start_date": "2025-04-16T...",
  "end_date": "2025-05-16T...",
  "new_users": 18,
  "new_shops": 2,
  "new_appointments": 42,
  "new_orders": 15,
  "revenue": { "appointments": 1200.00, "orders": 320.50, "total": 1520.50 }
}
```

---

## Default Test Accounts

Seeded automatically on startup:

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Shop Owner | `owner1` | `owner123` |
| Mechanic | `mechanic1` | `mechanic123` |
| Customer | `customer1` | `customer123` |

---

## Changelog

| Version | Change |
|---------|--------|
| 2025-05-16 | **P0-1** `GET /auth/me/roles` now returns `shop_roles` array from DB |
| 2025-05-16 | **P0-2** `reject` booking action now sets status `rejected` (was `cancelled`); `GET /admin/appointments?status=rejected` works |
| 2025-05-16 | **P1-3** Added `GET /shops/{shop_id}/statistics` for owners |
| 2025-05-16 | **P1-5** `pending-bookings` and `pending-orders` support `page`/`limit` params |
| 2025-05-16 | **P1-6** Added `PUT /admin/shops/{shop_id}/status` for admin shop toggle |
| 2025-05-16 | **Shape** All admin list endpoints standardised to `{items, total, page, limit}` |
| 2025-05-16 | **P2-3** `GET /admin/statistics/daily` includes `revenue` breakdown |
| 2025-05-16 | **P2-5** `GET /admin/shops` now accepts `search` query param |
| 2025-05-16 | **Merge** `GET /shops` conflict resolved — paginated response |
