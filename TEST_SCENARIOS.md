# Test Scenarios — Garage Management Mobile App

## Quick Reference

| Symbol | Meaning |
|--------|---------|
| ✅ | Pass |
| ❌ | Fail |
| ⏳ | In Progress |
| — | Not Tested |

**Base URL:** `https://backend-1-qgqd.onrender.com/api/v1`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Home Page — Shop Profile Display](#2-home-page--shop-profile-display)
3. [Search](#3-search)
4. [Shop Profile / Detail](#4-shop-profile--detail)
5. [Booking (Customer)](#5-booking-customer)
6. [Bottom Navigation — Role Routing](#6-bottom-navigation--role-routing)
7. [Mechanic / Shop Owner Features](#7-mechanic--shop-owner-features)
8. [Customer Profile Features](#8-customer-profile-features)
9. [Edge Cases & Error Handling](#9-edge-cases--error-handling)

---

## Test Accounts

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Shop Owner | `owner1` | `owner123` |
| Mechanic | `mechanic1` | `mechanic123` |
| Customer | `customer1` | `customer123` |

---

## 1. Authentication

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| A1 | Register new user | Open app → Profile tab → **Create Account** → fill email, username, full name, password → Submit | Account created, auto-logged in, redirected to home | — |
| A2 | Login with valid credentials | Profile tab → **Sign In** → enter `customer1 / customer123` → Submit | Logged in, home header shows **"Hello, [name]!"** | — |
| A3 | Login with wrong password | Sign In → enter incorrect password → Submit | Error message shown, stays on login modal | — |
| A4 | Login as mechanic | Sign In → `mechanic1 / mechanic123` | Bottom nav tab 2 label changes to **"Dashboard"**, tab 3 to **"Alerts"** | — |
| A5 | Login as shop owner | Sign In → `owner1 / owner123` | Role subtitle shows **"Shop owner · Find and manage bookings"** | — |
| A6 | Logout | Profile → **Log Out** button | Auth state cleared, header reverts to **"Find a Garage"**, avatar shows guest icon | — |
| A7 | Tap avatar when logged out | Home header → tap avatar icon | Login modal opens | — |
| A8 | Token refresh | Login → wait for token expiry → perform any API action | Token refreshes silently in background, user stays logged in | — |
| A9 | Register with existing email | Create Account → use already-registered email | Error message: email already in use | — |
| A10 | Login with empty fields | Sign In → leave username or password blank → Submit | Validation error shown before API call | — |

---

## 2. Home Page — Shop Profile Display

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| H1 | Shops load on startup | Open app | Skeleton cards shown briefly, then real shop profile cards appear | — |
| H2 | Shop card content | View any shop card | Shows gradient header (store icon + shop name + **Open** badge), address, phone, email, description preview, **Book Service** and **View Profile** buttons | — |
| H3 | Shop card with rating | View a shop that has ratings | Star icon + rating value + review count displayed in card header | — |
| H4 | Shop card without optional fields | View shop with only name filled | Card renders cleanly without address / phone / email rows | — |
| H5 | Pull to refresh | Pull down on shop list | Loading spinner appears, list reloads from API | — |
| H6 | Network error on load | Disable network → open app | Error state shows **"Could not load shops"** with a **Retry** button | — |
| H7 | Retry after network restored | Error state → re-enable network → tap **Retry** | Shops load successfully | — |
| H8 | Empty shop list | API returns zero active shops | **"No shops available"** empty state shown | — |

---

## 3. Search

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| S1 | Search by shop name | Type partial shop name in search bar | List filters to matching shops in real time | — |
| S2 | Search by address | Type city or street name | Shops with matching address shown | — |
| S3 | Search by phone number | Type phone number fragment | Shops with matching phone shown | — |
| S4 | Search with no results | Type a gibberish string | **"No shops match '...'"** message shown | — |
| S5 | Clear search | Type query then tap **✕** button | Search input clears, full shop list restored | — |
| S6 | Case-insensitive search | Type uppercase letters | Same results as typing lowercase | — |

---

## 4. Shop Profile / Detail

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| SP1 | Open shop profile | Tap **View Profile** on any card | `ShopDetailPage` opens with SliverAppBar gradient, contact info card, about section | — |
| SP2 | Book from detail page | ShopDetailPage → tap **Book a Service** | `BookingPage` opens pre-filled with correct `shopId` and `shopName` | — |
| SP3 | Back navigation | ShopDetailPage → tap back | Returns to home shop list, scroll position preserved | — |
| SP4 | Shop without description | Open detail for shop with no description | **"About"** section hidden entirely, no empty container | — |
| SP5 | Shop without contact info | Open detail for shop with no address/phone/email | Info card shows **"No contact info available"** | — |

---

## 5. Booking (Customer)

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| B1 | Book while logged out | Tap **Book Service** when not authenticated | Login modal appears; after successful login, booking flow continues | — |
| B2 | Book cancels if login skipped | Booking → login modal → close without logging in | Returns to home, no partial booking created | — |
| B3 | Complete service booking | Login → **Book Service** → select car → select service → confirm | `POST /product-orders/unified-booking` called, response `201`, success shown | — |
| B4 | Book with pre-selected shop | Tap **Book Service** from a home card | `BookingPage` receives correct `shopId` and `shopName` | — |
| B5 | View my appointments | Profile → **My Appointments** | Lists all appointments with status badges (`pending`, `confirmed`, etc.) | — |
| B6 | Cancel pending appointment | My Appointments → pending appointment → **Cancel** | `PUT /customers/my-appointments/{id}/cancel` called, status changes to `cancelled` | — |
| B7 | View appointment detail | My Appointments → tap an appointment | Full detail view with pricing breakdown shown | — |

---

## 6. Bottom Navigation — Role Routing

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| N1 | Customer — tab 2 | Login as customer → tap tab 2 | Opens `ActivityPage`, icon is history clock, label **"Activity"** | — |
| N2 | Mechanic — tab 2 | Login as mechanic → tap tab 2 | Opens `MechanicDashboardPage`, icon is dashboard, label **"Dashboard"** | — |
| N3 | Shop owner — tab 2 | Login as shop owner → tap tab 2 | Opens `MechanicDashboardPage`, icon is dashboard, label **"Dashboard"** | — |
| N4 | Customer — tab 3 | Login as customer → tap tab 3 | Opens `ProfilePage`, icon is person, label **"Profile"** | — |
| N5 | Mechanic — tab 3 | Login as mechanic → tap tab 3 | Opens `NotificationsPage`, icon is bell, label **"Alerts"** | — |
| N6 | Tap current active tab | Already on Home → tap Home tab again | No navigation triggered, page stays the same | — |
| N7 | Home tab clears back stack | Navigate deep → tap Home tab | All pages popped, returns to fresh `HomePage` | — |
| N8 | Shops tab | Tap tab 1 (Shops) from any role | Opens `ShopListPage` with search bar and shop cards | — |

---

## 7. Mechanic / Shop Owner Features

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| M1 | Open dashboard | Login as mechanic → Dashboard tab | `MechanicDashboardPage` loads, displays shop info and stat cards | — |
| M2 | View pending bookings | Dashboard → **Pending Bookings** | List fetched from `GET /mechanic/shops/{id}/pending-bookings`, shows customer name, vehicle, date, amount | — |
| M3 | Accept a booking | Pending Bookings → tap booking → **Accept** | `POST .../action {"action":"accept"}` sent, booking status updates to `confirmed` | — |
| M4 | Reject a booking | Pending Bookings → tap booking → **Reject** → enter reason | `POST .../action {"action":"reject","reason":"..."}` sent, booking removed from pending list | — |
| M5 | View today's bookings | Dashboard → **Today's Bookings** | Filtered list of appointments scheduled for today | — |
| M6 | View pending orders | Dashboard → **Pending Orders** | List from `GET /mechanic/shops/{id}/pending-orders` | — |
| M7 | Mark order ready | Pending Orders → order → **Mark Ready** | `PUT .../ready` called, status updates to `ready` | — |
| M8 | View notifications | Alerts tab | Unread count badge shown, notifications listed with type and message | — |
| M9 | Mark notification read | Tap an unread notification | `PUT /mechanic/notifications/{id}/read` called, item moves to read, unread count decreases | — |
| M10 | Create shop (owner only) | Profile → **Create / Manage Shop** → fill form → Submit | `POST /shops` called with `201` response, shop appears in list | — |
| M11 | Non-owner tries to create shop | Login as customer → manually navigate to Create Shop | Error: **"Forbidden – Shop Owner access only"** shown | — |

---

## 8. Customer Profile Features

| ID | Scenario | Steps | Expected Result | Status |
|----|----------|-------|-----------------|--------|
| C1 | View repair progress | Profile → **Repair Progress** | Lists all repairs with current stage badge (`in_progress`, `quality_check`, etc.) | — |
| C2 | View repair detail | My Repairs → tap a repair | Full detail with stage update history shown | — |
| C3 | View my quotations | Profile → **My Quotations** | Lists all quotations with status (`draft`, `sent`, `approved`, `rejected`) | — |
| C4 | Approve a quotation | My Quotations → sent quotation → **Approve** | `POST .../action {"action":"approve"}` sent, status changes to `approved` | — |
| C5 | Reject a quotation | My Quotations → sent quotation → **Reject** → enter reason | `POST .../action {"action":"reject","rejection_reason":"..."}` sent | — |
| C6 | View my invoices | Profile → **My Invoices** | Lists invoices with total amount and payment status | — |
| C7 | View invoice detail | My Invoices → tap invoice | Full breakdown with line items and payment history | — |
| C8 | Add a vehicle | Profile → **My Vehicles** → **Add Vehicle** → fill form | `POST /my-vehicles` called, vehicle appears in list | — |
| C9 | Set primary vehicle | My Vehicles → tap vehicle → **Set as Primary** | `POST /my-vehicles/{id}/set-primary` called, vehicle marked with primary badge | — |
| C10 | Delete a vehicle | My Vehicles → tap vehicle → **Delete** | `DELETE /my-vehicles/{id}` called, vehicle removed from list | — |

---

## 9. Edge Cases & Error Handling

| ID | Scenario | Expected Result | Status |
|----|----------|-----------------|--------|
| E1 | API returns `401 Unauthorized` | `UnauthorizedException` caught, user prompted to re-login, no crash | — |
| E2 | API returns `403 Forbidden` | User-friendly error message shown: **"Insufficient permissions"** | — |
| E3 | API returns `422 Unprocessable Entity` | Validation error message displayed on the relevant form field | — |
| E4 | API returns `500 Internal Server Error` | Generic error snackbar shown: **"Server error, please try again"** | — |
| E5 | No internet on app launch | Home shows error state with Retry button, app does not crash | — |
| E6 | Rapid typing in search bar | Each keystroke filters correctly, no UI freeze or crash | — |
| E7 | Very long shop name | Card header truncates with `...`, no text overflow or layout break | — |
| E8 | Shop with all fields null except name | Card and detail page render without null pointer exceptions | — |
| E9 | Multiple taps on "Book Service" | Only one `BookingPage` pushed, no duplicate pages stacked | — |
| E10 | Back button during booking | Booking flow allows stepping back without data loss | — |
| E11 | Session expired mid-session | API returns `401` on a subsequent call → silent token refresh attempted, then logout if refresh fails | — |
| E12 | Large shop list (50+ items) | ListView scrolls smoothly, no performance degradation | — |

---

## Test Execution Log

| Date | Tester | Build Version | Total | Passed | Failed | Notes |
|------|--------|---------------|-------|--------|--------|-------|
| | | | | | | |
| | | | | | | |

---

## Bug Report Template

```
ID       : BUG-XXX
Scenario : [scenario ID, e.g. A3]
Title    : Short description
Severity : Critical / High / Medium / Low
Steps to Reproduce:
  1.
  2.
  3.
Expected : 
Actual   : 
Device   : 
OS       : 
```
