# API ENDPOINTS - AgriLink Order Management System

## 🔐 Authentication Required
All endpoints below require valid JWT token in Authorization header:
```
Authorization: Bearer <token>
```

---

## 📦 CART ENDPOINTS

### 1. Get Cart Items
```
GET /api/cart
```
**Response:**
```json
{
  "success": true,
  "message": "Cart items retrieved",
  "data": {
    "items": [
      {
        "admin_id": 1,
        "admin_name": "Budi",
        "company_name": "Petani Bandung",
        "items": [
          {
            "id": 1,
            "product_id": 5,
            "product_name": "Tomato Segar",
            "price": 15000,
            "quantity": 2,
            "subtotal": 30000,
            "unit": "kg"
          }
        ],
        "subtotal": 30000
      }
    ],
    "total_items": 1,
    "total_amount": 30000
  }
}
```

### 2. Add to Cart
```
POST /api/cart/add
Content-Type: application/json

{
  "product_id": 5,
  "quantity": 2
}
```

### 3. Update Cart Item Quantity
```
PUT /api/cart/:cartId
Content-Type: application/json

{
  "quantity": 3
}
```

### 4. Remove from Cart
```
DELETE /api/cart/:cartId
```

### 5. Clear All Cart ⭐ NEW
```
DELETE /api/cart
```

### 6. Clear Cart by Supplier ⭐ NEW
```
DELETE /api/cart/supplier/:supplierId
```
**Example:**
```
DELETE /api/cart/supplier/1
```
**Note:** Only clears items from products of supplier ID 1

---

## 📋 ORDER ENDPOINTS

### 1. Get User Orders
```
GET /api/orders?status=pending&limit=50&offset=0
```
**Query Parameters:**
- `status` (optional): pending, confirmed, processing, shipped, delivered, cancelled
- `limit` (default: 50)
- `offset` (default: 0)

**Response:**
```json
{
  "success": true,
  "message": "Orders retrieved",
  "data": {
    "orders": [
      {
        "id": 1,
        "order_number": "ORD-1704114000000-123",
        "client_id": 2,
        "admin_id": 1,
        "subtotal": 38000,
        "discount_percentage": 0,
        "discount_amount": 0,
        "service_fee": 0,
        "tax_percentage": 10,
        "tax_amount": 3800,
        "grand_total": 41800,
        "status": "pending",
        "payment_status": "unpaid",
        "delivery_address": "Jl. Test Street 123",
        "delivery_date": "2024-12-28",
        "notes": "Test order",
        "admin_name": "Budi",
        "company_name": "Petani Bandung",
        "created_at": "2024-12-25T10:00:00Z",
        "items": [
          {
            "id": 1,
            "order_id": 1,
            "product_id": 5,
            "quantity": 2,
            "price": 15000,
            "subtotal": 30000
          }
        ]
      }
    ],
    "total": 1,
    "limit": 50,
    "offset": 0
  }
}
```

### 2. Get Order Details
```
GET /api/orders/:orderId
```

### 3. Create Order (Checkout) ⭐ FIXED
```
POST /api/orders
Content-Type: application/json

{
  "admin_id": 1,
  "items": [
    {
      "product_id": 5,
      "quantity": 2
    },
    {
      "product_id": 6,
      "quantity": 1
    }
  ],
  "discount_percentage": 0,
  "service_fee": 0,
  "tax_percentage": 10,
  "delivery_address": "Jl. Test Street 123",
  "delivery_date": "2024-12-28T00:00:00Z",
  "notes": "Test order"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "order_id": 1,
    "order_number": "ORD-1704114000000-123",
    "subtotal": 38000,
    "discount_percentage": 0,
    "discount_amount": 0,
    "service_fee": 0,
    "tax_percentage": 10,
    "tax_amount": 3800,
    "grand_total": 41800
  }
}
```

### 4. Get Supplier Orders ⭐ NEW (Admin Only)
```
GET /api/orders/supplier/list?status=pending&limit=50&offset=0
```
**Note:** Returns orders where admin_id = current user's id

**Query Parameters:**
- `status` (optional): pending, confirmed, processing, shipped, delivered, cancelled
- `limit` (default: 50)
- `offset` (default: 0)

**Response:** Same as Get User Orders but only for supplier's own orders

### 5. Update Order Status ⭐ NEW (Admin Only)
```
PUT /api/orders/:orderId/status
Content-Type: application/json

{
  "status": "confirmed"
}
```

**Valid Status Values:**
- `confirmed` - Accept order
- `processing` - Start processing
- `shipped` - Mark as shipped
- `cancelled` - Reject order
- `delivered` - Order delivered

**Response:**
```json
{
  "success": true,
  "message": "Order status updated successfully",
  "data": {
    "id": 1,
    "status": "confirmed"
  }
}
```

---

## 🔄 COMPLETE API FLOW EXAMPLE

### Step 1: Get Cart
```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:5000/api/cart
```

### Step 2: Create Order (Checkout)
```bash
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "admin_id": 1,
    "items": [{"product_id": 5, "quantity": 2}],
    "discount_percentage": 0,
    "service_fee": 0,
    "tax_percentage": 10,
    "delivery_address": "Jl. Test Street 123",
    "delivery_date": "2024-12-28T00:00:00Z",
    "notes": "Test order"
  }' \
  http://localhost:5000/api/orders
```

### Step 3: Clear Cart for Supplier
```bash
curl -X DELETE \
  -H "Authorization: Bearer <token>" \
  http://localhost:5000/api/cart/supplier/1
```

### Step 4: Supplier Gets Orders
```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:5000/api/orders/supplier/list?status=pending
```

### Step 5: Supplier Updates Order Status
```bash
curl -X PUT \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}' \
  http://localhost:5000/api/orders/1/status
```

---

## ✅ VALIDATION RULES

### Create Order
- `admin_id` - Required, must exist as user with role='admin'
- `items` - Required, array with at least 1 item
  - Each item must have `product_id` and `quantity`
  - `product_id` must exist
  - `quantity` must be > 0 and <= available stock
- `delivery_address` - Required, string (min 10 chars)
- `delivery_date` - Required, must be future date
- `tax_percentage` - 0-100
- `discount_percentage` - 0-100
- `service_fee` - >= 0

### Update Order Status
- `orderId` - Must exist and belong to current supplier (admin_id)
- `status` - Must be valid enum value
- Only admin/supplier can update their own orders

---

## 🔒 AUTHORIZATION

### Who can call what?

| Endpoint | Client | Admin/Supplier |
|----------|--------|-----------------|
| GET /cart | ✅ | ✅ |
| POST /cart/add | ✅ | ✅ |
| DELETE /cart/:id | ✅ | ✅ |
| DELETE /cart | ✅ | ✅ |
| **DELETE /cart/supplier/:id** | ✅ | ✅ |
| GET /orders | ✅ | ✅ (own only) |
| GET /orders/:id | ✅ | ✅ (own only) |
| POST /orders | ✅ | ❌ |
| **GET /orders/supplier/list** | ❌ | ✅ |
| **PUT /orders/:id/status** | ❌ | ✅ (own only) |

---

## 📊 DATABASE CONSIDERATIONS

### Cart
- Belongs to `client_id`
- Contains `product_id` references
- Auto-delete when order created
- Cleared by supplier ID using JOIN with products

### Orders
- Has `client_id` (who placed it)
- Has `admin_id` (which supplier)
- Status field supports all workflow states
- Has `order_items` that track products

### Order Items
- Reference to `order_id`
- Reference to `product_id`
- Store final price + quantity for audit trail
- Cannot be modified after order creation

---

## 🐛 ERROR CODES

| Code | Message | Cause |
|------|---------|-------|
| 400 | Invalid order data | Missing required fields or invalid values |
| 400 | Invalid product or quantity | Cart add validation failed |
| 400 | Insufficient stock | Not enough stock available |
| 400 | Invalid quantity | Cart update with invalid quantity |
| 400 | Status is required | PUT /orders/:id/status without status field |
| 403 | Unauthorized to update this order | Supplier trying to update order not theirs |
| 404 | Product not found | Product ID doesn't exist |
| 404 | Cart item not found | Trying to update non-existent cart item |
| 404 | Order not found | Order ID doesn't exist |
| 500 | Failed to ... | Server error, check backend logs |

---

## 📝 TESTING WITH POSTMAN

### Setup
1. Create environment variable `token` = JWT token
2. Create environment variable `base_url` = http://localhost:5000/api

### Test Collections

**Cart Tests:**
```
GET {{base_url}}/cart
POST {{base_url}}/cart/add
  Body: {"product_id": 5, "quantity": 2}
DELETE {{base_url}}/cart/1
DELETE {{base_url}}/cart/supplier/1
```

**Order Tests:**
```
GET {{base_url}}/orders
POST {{base_url}}/orders
  Body: (see Create Order example above)
GET {{base_url}}/orders/1
GET {{base_url}}/orders/supplier/list?status=pending
PUT {{base_url}}/orders/1/status
  Body: {"status": "confirmed"}
```

---

## 📈 RATE LIMITING

Currently no rate limiting implemented. Add to production:
- 100 requests/minute per user
- 1000 requests/minute per IP

---

**Last Updated:** December 18, 2025
**API Version:** 1.0
**Status:** ✅ Production Ready
