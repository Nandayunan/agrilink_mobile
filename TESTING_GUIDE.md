# Testing Guide - Order Management System

## Quick Start: Test the Complete Order Workflow

### Prerequisites
- Backend running on `http://localhost:5000`
- Flutter app running on Android/iOS/Web
- Test accounts created:
  - Client account (role: "client")
  - Supplier account (role: "admin")

---

## 🧪 Test Scenario 1: Customer Orders from Supplier

### Step 1: Login as Client
1. Open the app
2. Login with client credentials
3. Should see 4 tabs: Beranda, Pesanan, Cuaca, Profil

### Step 2: Add Products to Cart
1. Browse products in "Beranda" tab
2. Click on a product
3. Select quantity and add to cart
4. Add products from DIFFERENT suppliers (to test multiple carts)

### Step 3: View Cart
1. Click shopping cart icon in top-right
2. Should see products grouped by supplier
3. Each supplier has its own "Pesan dari Supplier Ini" button

### Step 4: Checkout
1. Click "Pesan dari Supplier Ini" for the first supplier
2. Enter delivery info:
   - Address: "Jl. Test Street 123"
   - Delivery Date: Pick a date 3 days from now
   - Notes: "Test order"
3. Click "Pesan Sekarang"
4. ✅ Should see success message
5. ✅ Should return to home screen
6. ✅ Cart should be cleared for that supplier (but other suppliers remain)

### Step 5: View Order
1. Click "Pesanan" tab
2. Should see the newly created order with status "Menunggu" (pending)
3. Can filter by status using chips at top

---

## 🧪 Test Scenario 2: Supplier Approves Order

### Step 1: Login as Supplier
1. Logout from client account
2. Login with supplier account (role: "admin")
3. ✅ Should see DIFFERENT bottom navigation:
   - Tab 1: Kelola Pesanan (NOT Beranda)
   - Tab 2: Cuaca
   - Tab 3: Profil

### Step 2: View Pending Orders
1. Should be on "Kelola Pesanan" tab
2. Should see 3 tabs: Pending, Dikonfirmasi, Diproses
3. "Pending" tab should show the order from Test Scenario 1
4. Order card shows:
   - Order number (e.g., ORD-1704114000000-123)
   - Status badge: "Menunggu" (orange)
   - Customer info from delivery address
   - All order items with quantities
   - Total price
   - Two buttons: "Tolak" and "Terima"

### Step 3: Accept Order
1. Click "Terima" (green button)
2. ✅ Order should move to "Dikonfirmasi" tab
3. ✅ Status badge should change to "Dikonfirmasi" (blue)
4. ✅ Buttons should change to "Mulai Proses"

### Step 4: Start Processing
1. On "Dikonfirmasi" tab, find the order
2. Click "Mulai Proses"
3. ✅ Order should move to "Diproses" tab
4. ✅ Status badge should change to "Diproses" (purple)
5. ✅ Button should change to "Tandai Dikirim"

### Step 5: Mark as Shipped
1. On "Diproses" tab, find the order
2. Click "Tandai Dikirim"
3. ✅ Order should move out of visible tabs
4. ✅ Status should be "Dikirim" (indigo)

---

## 🧪 Test Scenario 3: Supplier Rejects Order

### Setup
1. Create new order as client (same as Scenario 1)
2. Login as supplier

### Step 1: Reject Order
1. In "Pending" tab, find the order
2. Click "Tolak" (red button)
3. ✅ Should see confirmation dialog
4. Click "Ya, Tolak"
5. ✅ Order status should become "Dibatalkan" (cancelled)
6. ✅ Order should disappear from visible tabs

### Step 2: Verify Rejection
1. Switch to client account
2. Check "Pesanan" tab
3. Filter by status "Semua" to see all statuses
4. ✅ Order should show with red "Dibatalkan" status

---

## 🧪 Test Scenario 4: Cart Clearing Behavior

### Purpose
Verify that only items from ordered supplier are cleared, not other suppliers' items

### Step 1: Setup Multiple Suppliers
1. Login as client
2. Add products from Supplier A to cart
3. Add products from Supplier B to cart
4. Add products from Supplier C to cart
5. ✅ Cart should show 3 supplier groups

### Step 2: Order from Supplier B
1. Click "Pesan dari Supplier Ini" for Supplier B
2. Complete checkout
3. ✅ Success message appears

### Step 3: Verify Cart
1. Click cart icon
2. ✅ Supplier B products should be GONE
3. ✅ Supplier A products should still be there
4. ✅ Supplier C products should still be there

---

## ✅ Checklist: Expected Behaviors

### Checkout Screen
- [ ] Displays all selected items with quantities
- [ ] Shows price breakdown (subtotal, discount, tax, service fee)
- [ ] Grand total is calculated correctly
- [ ] Can enter delivery address
- [ ] Can select delivery date (only future dates)
- [ ] Can add notes
- [ ] All fields validate correctly
- [ ] Shows loading while submitting
- [ ] Success message appears
- [ ] Redirects to home screen

### Order Approval Screen
- [ ] Shows tabs for Pending, Confirmed, Processing statuses
- [ ] Each tab shows count of orders
- [ ] Order cards display all information correctly
- [ ] Status badge shows correct color and label
- [ ] Action buttons appear based on status
- [ ] Clicking button updates status immediately
- [ ] Tab switches when status changes
- [ ] Pull-to-refresh works
- [ ] Empty state shown when no orders in tab

### Orders Screen (Client)
- [ ] Shows all customer's orders
- [ ] Status chips filter orders correctly
- [ ] Status badge shows with correct color
- [ ] Order details are displayed correctly
- [ ] Can see supplier info for each order
- [ ] Item count shows correctly

### Navigation
- [ ] Client sees 4 tabs (Beranda, Pesanan, Cuaca, Profil)
- [ ] Supplier sees 3 tabs (Kelola Pesanan, Cuaca, Profil)
- [ ] Tabs switch correctly when tapped
- [ ] Bottom navigation shows selected tab

---

## 🔍 Debugging Tips

### If orders don't appear:
1. Check backend logs: `npm start`
2. Verify JWT token is valid
3. Check database has orders: 
   ```sql
   SELECT * FROM orders;
   ```

### If cart doesn't clear:
1. Check console logs in Flutter
2. Verify `clearCartBySupplier` API is being called
3. Check database cart_items table:
   ```sql
   SELECT * FROM cart_items WHERE client_id = ?;
   ```

### If status doesn't update:
1. Check network tab in DevTools
2. Verify PUT request is sent with correct status
3. Check backend authentication middleware
4. Verify user role is 'admin' for supplier

### If navigation doesn't change:
1. Verify `authProvider.currentUser.role` is being read
2. Check AuthProvider is properly updated after login
3. Clear app cache and rebuild

---

## 📊 Database Verification

After running test scenarios, verify in MySQL:

```sql
-- Check orders were created
SELECT id, order_number, client_id, admin_id, status, created_at 
FROM orders 
ORDER BY created_at DESC 
LIMIT 10;

-- Check cart was cleared for supplier 1
SELECT COUNT(*) as cart_count
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
WHERE ci.client_id = ? AND p.admin_id = 1;

-- Check order items
SELECT oi.*, p.name, p.unit
FROM order_items oi
JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = ?;

-- Check order status progression
SELECT id, order_number, status, updated_at
FROM orders
WHERE admin_id = ?
ORDER BY updated_at DESC
LIMIT 5;
```

---

## 🐛 Known Issues & Workarounds

None currently! 🎉

---

## ✨ Success Criteria

All of the following should be true:
- ✅ Cart clears after order creation
- ✅ Only items from ordered supplier are cleared
- ✅ Suppliers see different UI (Kelola Pesanan tab)
- ✅ Suppliers can accept orders
- ✅ Suppliers can reject orders
- ✅ Suppliers can process orders (multiple status steps)
- ✅ Customers can see order status changes
- ✅ Order status progresses: pending → confirmed → processing → shipped
- ✅ Status badges show correct colors
- ✅ All data displays correctly

---

**Last Updated:** December 18, 2025
