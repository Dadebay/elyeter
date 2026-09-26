# Elyeter — Mobile App API

Everything the Android/iOS app needs: SMS login, catalog, brands and pre-orders.

- **Base URL:** `https://elyeter-backend.sanlyadim.com/api`
- **Interactive reference (schemas, try-it-out):** `https://elyeter-backend.sanlyadim.com/api/docs`
  — ignore the `admin/*` sections, they are for the back office only.
- **File server** (for the few fields that return a storage path instead of a URL):
  `https://elyeter-backend.sanlyadim.com/public`

All paths below are relative to the base URL.

---

## 1. Conventions

### Response envelope

Every response — success or error — has the same shape:

```json
{ "statusCode": 200, "message": "success", "data": { } }
```

The payload you care about is always in `data`. An error looks like this:

```json
{
  "statusCode": 409,
  "message": "Сейчас нельзя заказать: «Test cable»",
  "data": null,
  "code": "pre-order-items-unavailable",
  "details": { }
}
```

| Field | Notes |
|---|---|
| `message` | Human-readable text, safe to show to the user. Currently **Russian only** — see *Known limitations*. |
| `code` | Stable machine-readable code. Branch your logic on this, never on `message`. Not present on every error. |
| `details` | Structured extra data. Only present where documented below. |
| `errors` | Only on 400 validation failures: `string[]`, one entry per invalid field. |

### Language

Send `Content-Language: tk` or `Content-Language: ru` on every request.
**Default is Turkmen (`tk`)** when the header is absent. Any other value falls back to `tk`.

The header controls product names, descriptions, category names, attribute names/values and
availability status texts. It does **not** yet control error `message` strings.

### Authentication

`Authorization: Bearer <access_token>`

Endpoints marked 🔒 require it. On the others the token is optional and changes nothing today.

Any 🔒 endpoint can return:

- **401** — missing, expired or invalid token → send the user back to the login screen.
- **403** `user-blocked` — the account was blocked by an administrator. This applies to
  already-issued tokens too, so it can happen mid-session.

There is **no refresh token**. The access token lives for **30 days**; when you get a 401,
re-run the SMS login flow.

### Pagination

Paginated list endpoints require **both** `page` (starts at 1) and `size` (1–100).
Omitting either one, or exceeding 100, returns 400.

```json
{ "totalCount": 57, "page": 1, "items": [ ] }
```

### Prices

Plain numbers in Turkmen manat (TMT): `100`, `249.5`. No currency conversion on the client.

### Images

`main_image`, `images[].url` and a variant's `image` are already **absolute URLs** — use them
as-is.

Category images (`image_large`, `image_small`) and brand `logo` may be either an absolute URL
or a storage path. Rule: if the value does not start with `http`, prefix it with the file
server base URL above.

### Dates

ISO 8601 strings. **Caveat:** timestamps are currently stored without a timezone and come back
without an offset, effectively 5 hours behind Ashgabat time (UTC+5). Do not do date math on
them client-side for now; display them as relative ("2 days ago") or wait for the fix noted
under *Known limitations*.

---

## 2. SMS login

There are no passwords. The user types a phone number, receives an SMS code, and logs in.
The account is created automatically on first successful login.

### `POST /auth/send-code`

```json
{ "phone": "+99362123456" }
```

Turkmen numbers only, exact format `+993XXXXXXXX` (12 characters).

Response `data`:

```json
{ "expires_in": 180, "resend_after": 60 }
```

- `expires_in` — seconds the code stays valid.
- `resend_after` — seconds until a new code may be requested. Drive your countdown timer
  off this value and keep the "Resend" button disabled until it elapses.

| Error | When |
|---|---|
| 400 `otp-rate-limited` | A code was requested again before `resend_after` elapsed |
| 403 `user-blocked` | Account is blocked |
| 400 (validation) | Number is not Turkmen or malformed |

> **Testing:** the production SMS gateway is still running on a placeholder key, so real
> numbers receive nothing yet. Use the test number **`+99362123456`** with the fixed code
> **`1111`** until the real SMS key is installed.

### `POST /auth/verify-code`

```json
{ "phone": "+99362123456", "code": "1111" }
```

Response `data`:

```json
{
  "access_token": "eyJhbGciOi...",
  "is_new": true,
  "user": {
    "id": 1,
    "phone": "+99362123456",
    "username": null,
    "image": null,
    "fcm_token": null,
    "is_blocked": false,
    "created_at": "2026-09-26T09:12:00.000Z",
    "updated_at": "2026-09-26T09:12:00.000Z",
    "last_login_at": "2026-09-26T09:12:00.000Z"
  }
}
```

- `is_new: true` — the user just registered; a good moment to show a "what's your name?" screen.
- The code is single-use: it is destroyed on success and cannot be replayed.

| Error | When |
|---|---|
| 400 `otp-invalid` | Wrong code |
| 400 `otp-too-many-attempts` | 5 wrong attempts — the code is burned, request a new one |
| 404 `otp-expired` | Code expired, or none was ever requested for this number |
| 403 `user-blocked` | Account is blocked |

### Profile 🔒

| Method | Path | Body | Purpose |
|---|---|---|---|
| GET | `/auth/me` | — | Current user (same object as in the login response) |
| PATCH | `/auth/me` | `{ "username"?: string, "image"?: string }` | Update name / avatar. `username` max 120 chars |
| PATCH | `/auth/fcm-token` | `{ "fcm_token": string }` | Register the device for push notifications. Max 512 chars |
| DELETE | `/auth/me` | — | Delete the account |

> Push delivery is not implemented on the backend yet — storing the FCM token is safe and
> forward-compatible, but nothing will be sent to it for now.

---

## 3. Catalog

### `GET /categories/tree`

Full tree of active categories, names resolved to the requested language.

```json
[
  {
    "id": 7,
    "parent_id": null,
    "name": "Elektronika",
    "slug": "elektronika",
    "image_large": null,
    "image_small": null,
    "products_count": 12,
    "children": [
      {
        "id": 8,
        "parent_id": 7,
        "name": "Telefonlar",
        "slug": "telefonlar",
        "image_large": null,
        "image_small": null,
        "products_count": 5,
        "children": []
      }
    ]
  }
]
```

`products_count` counts published products in that exact category, not including descendants.

### `GET /categories/:slug`

One category plus `breadcrumbs: [{ id, slug, name }]`, ordered root → current.

404 `category-not-found` if the slug is unknown or the category is hidden.

### `GET /products`

Product listing. Requires `page` and `size`.

| Query param | Type | Meaning |
|---|---|---|
| `category_id` / `category_slug` | int / string | Category **including all of its subcategories** |
| `brand_id` / `brand_slug` | int / string | Brand |
| `search` | string | Matches product name (both languages) and SKU |
| `min_price`, `max_price` | number | Price range in TMT |
| `only_featured` | `true` | Featured products only — use this for the home screen |
| `sort` | `new` (default), `price_asc`, `price_desc`, `popular` | Ordering |

Pass only the params you actually use: sending an unknown query param returns 400.

List item:

```json
{
  "id": 2,
  "slug": "gozgalamy",
  "sku": "EL-000002",
  "name": "Göz galamy",
  "price": 30,
  "old_price": null,
  "stock": 100,
  "has_variants": false,
  "main_image": "https://elyeter-backend.sanlyadim.com/public/products/2026/09/EL-000002-1.jpg",
  "rating": 4.8,
  "orders_count": 5000,
  "is_featured": false,
  "category_id": 13,
  "brand": {
    "id": 1,
    "name": "ZYXUAQIR",
    "slug": "zyxuaqir",
    "logo": null,
    "products_count": 1
  }
}
```

- `old_price` — strike-through price; `null` when there is no discount.
- `brand` — `null` when the product has no brand.
- `rating` and `orders_count` come from the supplier and are useful as social proof.
- **`stock` is a snapshot** from the last sync with the supplier, not a live figure. Treat it
  as "roughly how many are left", never as a guarantee. Real availability is confirmed only at
  checkout — see section 5.

### `GET /products/:slug`

Product detail — everything from the list item, plus:

```json
{
  "description": "<p>Product description as HTML</p>",
  "category": { "id": 13, "slug": "aýal-geýimleri", "name": "Aýal geýimleri" },
  "breadcrumbs": [
    { "id": 12, "slug": "geyimler", "name": "Geýimler" },
    { "id": 13, "slug": "aýal-geýimleri", "name": "Aýal geýimleri" }
  ],
  "images": [
    { "id": 1, "url": "https://.../EL-000003-1.jpg", "is_main": true, "sort_order": 0 }
  ],
  "variants": [
    {
      "id": 2,
      "sku": "EL-000003-V1",
      "price": 300,
      "old_price": null,
      "stock": 2,
      "image": null,
      "attributes": [{ "name": "Reňk", "value": "Gara" }]
    }
  ],
  "attributes": [{ "name": "Material", "value": "Plastik" }]
}
```

- `description` is **HTML** — render it in a web view or an HTML-capable text widget.
- `variants` are the selectable options (colour, size). Each variant carries its **own price
  and stock**, which override the product-level values once one is selected.
  **If `has_variants` is `true`, a `variant_id` is mandatory at checkout.**
- `attributes` are plain spec rows for an "About this item" block.
- 404 when the product does not exist or is no longer for sale.

### `GET /products/:id/variants`

Just the variants of one product, same shape as `variants` above. Note this takes the numeric
**id**, while the detail endpoint takes the **slug**.

### `GET /search/suggest?q=<text>&limit=5`

Type-ahead suggestions for the search bar. `limit` defaults to 5.

```json
{
  "products": [
    { "id": 1, "slug": "synag-kabel", "name": "Synag kabel", "price": 100, "main_image": "https://..." }
  ],
  "categories": [{ "id": 8, "slug": "telefonlar", "name": "Telefonlar" }]
}
```

Debounce this by ~300 ms on the client.

---

## 4. Brands

### `GET /brands?search=<text>`

Brands for the filter UI. Only brands that actually have published products are returned.
Not paginated — the full list comes back alphabetically.

```json
[{ "id": 1, "name": "ZYXUAQIR", "slug": "zyxuaqir", "logo": null, "products_count": 1 }]
```

To list a brand's products: `GET /products?brand_slug=zyxuaqir&page=1&size=20`.

### `GET /brands/:slug`

A single brand, for the header of a brand page. 404 if unknown or hidden.

---

## 5. Pre-orders 🔒

There is **no payment in the app**. The customer submits a pre-order, then a manager calls
them back and places the order with the supplier.

**The cart lives entirely on the device.** It is never stored server-side — it is sent to the
backend only for the availability check and at checkout.

The supplier is AliExpress. On both endpoints below the backend calls the supplier **live**,
in the moment of the request, and refreshes its own price and stock from the answer. That is
why these two calls are noticeably slower than the catalog ones — budget a few seconds and
show a spinner.

### Recommended flow

```
Cart screen ──▶ POST /pre-orders/check
                  │
                  ├─ 200, available: true   → enable the "Place order" button
                  └─ 200, available: false  → highlight the bad lines, keep the button disabled
                                              (use items[].message as the inline text)
                  ▼
"Place order" ──▶ POST /pre-orders  (include expected_total)
                  │
                  ├─ 201 → order created, show the confirmation screen
                  ├─ 409 pre-order-items-unavailable → something ran out; NOT created
                  ├─ 409 pre-order-price-changed     → total moved; NOT created
                  └─ 503 → supplier unreachable; NOT created
```

The check at checkout is **always performed from scratch**, regardless of any earlier
`/check` call — the item may have sold out in the seconds between the two screens.
**If anything is missing or short, the order is not created at all.** It is never partially
accepted, so you do not need to reconcile a half-placed order.

### Cart line format

Identical for `/check` and checkout:

```json
{ "product_id": 3, "variant_id": 2, "quantity": 1 }
```

- `variant_id` is required when the product has `has_variants: true`, and must belong to that
  product.
- `quantity` — 1 to 99.
- Up to **30 lines** per request.
- Duplicate lines (same product + variant) are merged server-side, quantities added.

### `POST /pre-orders/check`

Validation only — nothing is created.

```json
{
  "items": [
    { "product_id": 1, "quantity": 2 },
    { "product_id": 3, "variant_id": 2, "quantity": 1 }
  ]
}
```

Returns **200 even when items are unavailable** — that is a normal result, not an error.
Response `data`:

```json
{
  "available": true,
  "price_changed": false,
  "total_price": 500,
  "checked_at": "2026-09-22T09:38:10.938Z",
  "items": [
    {
      "product_id": 1,
      "variant_id": null,
      "sku": "EL-000001",
      "name": "Synag kabel",
      "variant": null,
      "image": null,
      "quantity": 2,
      "price": 100,
      "previous_price": 100,
      "price_changed": false,
      "line_total": 200,
      "available_stock": 5,
      "status": "available",
      "message": null
    },
    {
      "product_id": 3,
      "variant_id": 2,
      "sku": "EL-000003-V1",
      "name": "Sagat",
      "variant": "Reňk: Gara",
      "image": null,
      "quantity": 1,
      "price": 300,
      "previous_price": 300,
      "price_changed": false,
      "line_total": 300,
      "available_stock": 2,
      "status": "available",
      "message": null
    }
  ]
}
```

| Field | Meaning |
|---|---|
| `available` | `true` — every line is in stock in the requested quantity; safe to enable checkout |
| `total_price` | Sum of the **available** lines only, at current prices |
| `price_changed` | At least one price differs from what was stored before this check |
| `items[].price` | Current unit price; `null` when the line is unavailable |
| `items[].previous_price` | Price before this check — use it to render "was / now" |
| `items[].line_total` | `price × quantity` |
| `items[].available_stock` | How many the supplier actually has |
| `items[].variant` | Pre-formatted variant label, e.g. `"Reňk: Gara"` — display as-is |
| `items[].status` | See the table below |
| `items[].message` | Ready-to-display text in the requested language; `null` when the line is fine |

Line statuses:

| `status` | Meaning | Suggested UI |
|---|---|---|
| `available` | In stock in the requested quantity | — |
| `insufficient_stock` | In stock, but fewer than requested | "Only N left" — offer to reduce the quantity to `available_stock` |
| `out_of_stock` | Sold out | "Out of stock" — offer to remove the line |
| `unavailable` | Withdrawn from sale (by us or by the supplier) | "No longer available" — remove the line |
| `not_found` | Not in our catalog at all | Remove the line silently |

Errors:

| Error | When |
|---|---|
| 400 `variant-required` | The product has variants but `variant_id` is missing, or belongs to another product. `details.product_id` tells you which line |
| 503 `pre-order-availability-check-failed` | The supplier did not answer. This is **not** "out of stock" — do not clear the cart; offer a retry in a couple of minutes |
| 429 `too-many-requests` | More than 20 checks/checkouts per minute per user |

### `POST /pre-orders`

Create the pre-order.

```json
{
  "items": [
    { "product_id": 1, "quantity": 2 },
    { "product_id": 3, "variant_id": 2, "quantity": 1 }
  ],
  "customer_name": "Aman",
  "address": "Aşgabat, Bitarap Türkmenistan 12",
  "comment": "Agşam jaň ediň",
  "expected_total": 500
}
```

| Field | Required | Notes |
|---|---|---|
| `items` | yes | Cart lines, 1–30 |
| `customer_name` | no | Max 120 chars. Falls back to the profile name |
| `address` | no | Max 1000 chars |
| `comment` | no | Max 2000 chars |
| `expected_total` | no, but **strongly recommended** | The total the user saw on screen. If the re-check produces a different total, the order is rejected with 409 `pre-order-price-changed` instead of silently charging more |

The phone number is taken from the authenticated account — do not send it.

**201** on success; `data` is the pre-order object (below) plus a `price_changed` flag.

Errors:

| Error | When | What to do |
|---|---|---|
| 409 `pre-order-items-unavailable` | At least one line is missing or short. **Nothing was created** | `details` is a full `/check`-shaped result — re-render the cart from it and highlight every line whose `status != "available"` |
| 409 `pre-order-price-changed` | The total did not match `expected_total`. **Nothing was created** | `details` is a `/check`-shaped result with the new prices — show them, ask the user to confirm, then resubmit with the updated `expected_total` |
| 400 `variant-required` | Same as `/check` | Fix the offending line |
| 503 `pre-order-availability-check-failed` | Supplier unreachable. **Nothing was created** | Keep the cart, offer a retry |
| 429 `too-many-requests` | Same as `/check` | Back off |

Both 409 bodies carry the same structure as a `/check` response, so a single rendering
function can handle `/check` results and checkout rejections alike.

### Pre-order object

```json
{
  "id": 1,
  "number": "PO-000001",
  "status": "NEW",
  "total_price": 500,
  "currency": "TMT",
  "items_count": 3,
  "customer_name": null,
  "phone": "+99362123456",
  "address": "Aşgabat, Bitarap Türkmenistan 12",
  "comment": "Agşam jaň ediň",
  "created_at": "2026-09-22T09:40:00.000Z",
  "status_changed_at": null,
  "can_cancel": true,
  "items": [
    {
      "id": 1,
      "product_id": 1,
      "product_slug": "synag-kabel",
      "variant_id": null,
      "sku": "EL-000001",
      "name": "Synag kabel",
      "variant": null,
      "image": null,
      "quantity": 2,
      "price": 100,
      "line_total": 200
    }
  ]
}
```

- `number` — the reference to show the user and to quote on a support call.
- `items_count` — total **units** (sum of `quantity`), not the number of lines.
- Items are a **snapshot** taken at checkout: name and price stay frozen even if the product
  is repriced or renamed later. Never re-fetch them from the catalog to display an order.
- `product_slug` lets you deep-link to the product page; `null` if the product has since been
  removed from the catalog — hide the link in that case.
- `can_cancel` — whether the cancel endpoint will currently succeed.

Statuses:

| `status` | What it means to the user |
|---|---|
| `NEW` | Submitted, waiting for a manager to call |
| `CONFIRMED` | Confirmed by the manager |
| `ORDERED` | Ordered from the supplier |
| `COMPLETED` | Fulfilled |
| `CANCELLED` | Cancelled |

Statuses only move forward along `NEW → CONFIRMED → ORDERED → COMPLETED`, and a manager
can cancel from any of the first three. `COMPLETED` and `CANCELLED` are terminal, so an
order never leaves them.

### My pre-orders

| Method | Path | Notes |
|---|---|---|
| GET | `/pre-orders?page=1&size=20&status=NEW` | Newest first. `status` is an optional filter |
| GET | `/pre-orders/:id` | One order. 404 if it does not exist **or belongs to someone else** |
| POST | `/pre-orders/:id/cancel` | Only while `can_cancel` is `true` (status `NEW`). Otherwise 409 `invalid-pre-order-transition` — tell the user to contact support |

There is no push or polling channel for status changes yet; refresh the list when the user
opens the orders screen.

---

## 6. Error code reference

Every `code` the app can encounter:

| `code` | HTTP | Where it comes from |
|---|---|---|
| `otp-rate-limited` | 400 | Code requested again too soon |
| `otp-invalid` | 400 | Wrong SMS code |
| `otp-too-many-attempts` | 400 | Code burned after 5 wrong attempts |
| `otp-expired` | 404 | Code expired or never requested |
| `user-blocked` | 403 | Account blocked by an administrator |
| `category-not-found` | 404 | Unknown category slug |
| `variant-required` | 400 | Product variant not selected |
| `pre-order-items-unavailable` | 409 | Something is out of stock — order **not** created |
| `pre-order-price-changed` | 409 | Total changed — order **not** created |
| `pre-order-availability-check-failed` | 503 | Supplier did not answer |
| `pre-order-not-found` | 404 | Unknown or foreign pre-order |
| `invalid-pre-order-transition` | 409 | Too late to cancel |
| `too-many-requests` | 429 | Rate limit (20/min per user on pre-order endpoints) |

Errors **without** a `code`:

- **401** — authentication required or token expired.
- **404** on a product or brand slug.
- **400** validation failures, with an `errors: string[]` array. This includes a missing
  `page`/`size`, a `size` above 100, and any query or body field that is not in the documented
  list — the API rejects unknown fields rather than ignoring them.

---

## 7. Known limitations (as of 2026-09-26)

Please read this before filing bugs — these are backend-side and already known.

1. **AliExpress authorization has expired.** Until the operator re-runs OAuth in the back
   office, `POST /pre-orders/check` and `POST /pre-orders` return **503
   `pre-order-availability-check-failed`**. The catalog endpoints are unaffected.
   Build and test the 503 path; the happy path becomes testable once the token is restored.
2. **SMS is on a placeholder key.** Only `+99362123456` with code `1111` can log in.
3. **Error `message` strings are Russian only**, even with `Content-Language: tk`. Item-level
   `items[].message` inside the pre-order check *is* localized. If you need fully localized
   error text now, map `code` → your own strings and ignore `message`.
4. **Timestamps have no timezone** and are ~5 hours behind local time (see *Dates*).
5. **No push notifications yet** — `fcm-token` is stored but unused.
6. **No refresh token** — a 401 means a full re-login.
7. **Turkmen wording in availability messages** was not written by a native speaker and may
   still be revised. Do not hard-code or cache those strings.

---

## 8. Quick start with curl

```bash
BASE=https://elyeter-backend.sanlyadim.com/api

# 1. Request a code (test number)
curl -X POST "$BASE/auth/send-code" \
  -H 'Content-Type: application/json' -H 'Content-Language: tk' \
  -d '{"phone":"+99362123456"}'

# 2. Exchange it for a token
TOKEN=$(curl -s -X POST "$BASE/auth/verify-code" \
  -H 'Content-Type: application/json' \
  -d '{"phone":"+99362123456","code":"1111"}' | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

# 3. Profile
curl "$BASE/auth/me" -H "Authorization: Bearer $TOKEN"

# 4. Catalog
curl "$BASE/categories/tree" -H 'Content-Language: tk'
curl "$BASE/products?page=1&size=20&sort=new" -H 'Content-Language: tk'

# 5. Availability check
curl -X POST "$BASE/pre-orders/check" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H 'Content-Language: tk' \
  -d '{"items":[{"product_id":1,"quantity":1}]}'
```

Questions about anything not covered here: check Swagger first
(`https://elyeter-backend.sanlyadim.com/api/docs`), then ask the backend team.
