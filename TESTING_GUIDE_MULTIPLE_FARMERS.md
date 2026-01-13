# 🧪 Testing Guide: Multiple Farmers Feature

## ✅ Pre-requisites

1. **Backend running**: `npm run dev` di folder `agri_link_backend`
2. **Database connected**: Check `.env` file memiliki DB credentials yang benar
3. **Sample data**: Pastikan ada 2-3 petani (users dengan role='admin') dan produk mereka di database
4. **Flutter app**: `flutter run` di folder `agri_link_app`
5. **Test account**: Login dengan akun restoran (role='client')

---

## 📝 Sample Test Data

Jika belum ada, insert data berikut ke database:

```sql
-- Petani 1 (admin)
INSERT INTO users VALUES 
(1, 'Budi Santoso', 'budi@farm.com', 'admin', 'bcrypt_password', 
 '08123456789', 'Tani Jaya Farm', 'Jakarta', 'DKI Jakarta', 
 'Jl. Raya Bogor 123', '12345', 'approved', NULL, NULL, NOW(), NOW());

-- Petani 2 (admin)
INSERT INTO users VALUES 
(2, 'Siti Nurhaliza', 'siti@farm.com', 'admin', 'bcrypt_password',
 '08129876543', 'Green Land Farm', 'Bandung', 'Jawa Barat',
 'Jl. Tangkuban Perahu 456', '40123', 'approved', NULL, NULL, NOW(), NOW());

-- Petani 3 (admin)
INSERT INTO users VALUES 
(3, 'Ahmad Wijaya', 'ahmad@farm.com', 'admin', 'bcrypt_password',
 '08111223344', 'Buah Segar Farm', 'Bogor', 'Jawa Barat',
 'Jl. Baru 789', '16610', 'approved', NULL, NULL, NOW(), NOW());

-- Restoran (client)
INSERT INTO users VALUES 
(5, 'Restoran ABC', 'restoran@email.com', 'client', 'bcrypt_password',
 '08155667788', 'Restoran Nusantara', 'Jakarta', 'DKI Jakarta',
 'Jl. Sudirman 999', '12210', 'approved', NULL, NULL, NOW(), NOW());

-- Products from Petani 1
INSERT INTO products (admin_id, category, name, description, price, stock, unit, is_available)
VALUES (1, 'Sayuran', 'Tomat Segar', 'Tomat organik', 15000, 100, 'kg', 1),
       (1, 'Sayuran', 'Bayam Segar', 'Bayam hijau', 8000, 50, 'ikat', 1),
       (1, 'Rempah', 'Bawang Merah', 'Bawang pilihan', 25000, 60, 'kg', 1);

-- Products from Petani 2
INSERT INTO products (admin_id, category, name, description, price, stock, unit, is_available)
VALUES (2, 'Sayuran', 'Kentang', 'Kentang berkualitas', 8000, 150, 'kg', 1),
       (2, 'Rempah', 'Bawang Putih', 'Bawang putih pilihan', 30000, 40, 'kg', 1),
       (2, 'Sayuran', 'Wortel', 'Wortel segar', 5000, 80, 'kg', 1);

-- Products from Petani 3
INSERT INTO products (admin_id, category, name, description, price, stock, unit, is_available)
VALUES (3, 'Buah', 'Pisang Ambon', 'Pisang berkualitas', 12000, 75, 'sisir', 1),
       (3, 'Buah', 'Mango', 'Mangga manis', 20000, 50, 'pcs', 1),
       (3, 'Buah', 'Papaya', 'Pepaya segar', 10000, 60, 'pcs', 1);
```

---

## 🧪 Test Cases

### Test 1: Add Products from Multiple Farmers

**Purpose**: Verify cart can hold items from different farmers

**Steps**:
1. Login sebagai Restoran (client)
2. Browse Home tab
3. **Add Tomat (Petani 1)** - qty 2
   - ✅ Verify snackbar: "Produk ditambahkan ke keranjang"
4. **Add Kentang (Petani 2)** - qty 3
   - ✅ Verify snackbar: "Produk ditambahkan ke keranjang"
5. **Add Pisang (Petani 3)** - qty 1
   - ✅ Verify snackbar: "Produk ditambahkan ke keranjang"

**Expected Result**:
- ✅ No error
- ✅ All 3 items added successfully
- ✅ Cart should have items from 3 different farmers

---

### Test 2: Verify Cart Groups Items by Farmer

**Purpose**: Verify cart screen shows items grouped per farmer

**Steps**:
1. From Test 1 above, click **Orders tab** (keranjang belanja)
2. Wait for cart to load

**Expected UI**:
```
🏪 Petani 1: Tani Jaya Farm (Budi Santoso)
├─ Tomat Segar      x2   Rp 30,000
└─ Subtotal: Rp 30,000
[Pesan dari Supplier Ini]

🏪 Petani 2: Green Land Farm (Siti Nurhaliza)
├─ Kentang          x3   Rp 24,000
└─ Subtotal: Rp 24,000
[Pesan dari Supplier Ini]

🏪 Petani 3: Buah Segar Farm (Ahmad Wijaya)
├─ Pisang Ambon     x1   Rp 12,000
└─ Subtotal: Rp 12,000
[Pesan dari Supplier Ini]

💰 Total: Rp 66,000
```

**Verify**:
- ✅ 3 separate sections (cards) per farmer
- ✅ Farmer name & company name displayed
- ✅ Items grouped correctly under each farmer
- ✅ Subtotal calculated per farmer
- ✅ Each section has "Pesan dari Supplier Ini" button

---

### Test 3: Modify Quantity in Cart

**Purpose**: Verify quantity changes work correctly

**Steps**:
1. From Test 2, in Petani 1 section
2. **Increase Tomat qty**: Click + button → should go from 2 to 3
   - ✅ Subtotal should update: Rp 45,000 (3 x 15,000)
3. **Decrease Tomat qty**: Click - button → should go from 3 to 2
   - ✅ Subtotal should go back to Rp 30,000

**Expected Result**:
- ✅ Quantity updates immediately
- ✅ Subtotal recalculates
- ✅ Only affected farmer's subtotal changes
- ✅ Other farmers' items untouched

---

### Test 4: Remove Item from Cart

**Purpose**: Verify item removal works correctly

**Steps**:
1. From cart, in Petani 2 section
2. **Click X button** on Kentang item
   - ✅ Verify snackbar: "Item removed"
3. **Verify Petani 2 section updates**
   - Should now be empty or disappear
   - OR if there were other items, show remaining items

**Expected Result**:
- ✅ Item removed from cart
- ✅ Petani 2 section gone or updated
- ✅ Total amount reduced

---

### Test 5: Checkout Single Farmer

**Purpose**: Verify checkout flow for one farmer

**Steps**:
1. From Test 2 cart state (3 farmers present)
2. **Click "Pesan dari Supplier Ini"** button di Petani 1 (Tani Jaya)
3. **Verify Checkout Screen opens**
   - ✅ Shows "Checkout" title
   - ✅ Shows order summary with items (only Tomat)
   - ✅ NO items dari Petani 2 or 3

**Expected Checkout Screen**:
```
Checkout

📋 Ringkasan Pesanan
🥬 Tomat Segar    2 x Rp 15,000 = Rp 30,000
Subtotal: Rp 30,000

📦 Informasi Pengiriman
Alamat: [empty form]
Tanggal: [date picker]
Catatan: [optional]

💳 Ringkasan Pembayaran
Subtotal:    Rp 30,000
Diskon:      Rp 0
Pajak (10%): Rp 3,000
Biaya Admin: Rp 0
────────────────────
TOTAL:       Rp 33,000

[BUAT PESANAN] [BATAL]
```

**Verify**:
- ✅ Only Petani 1 items shown
- ✅ Total matches Petani 1 only
- ✅ Form fields present

---

### Test 6: Create Order (Complete Checkout)

**Purpose**: Verify order creation

**Steps**:
1. From Test 5 (checkout screen open)
2. **Fill form**:
   - Alamat: "Jl. Example 123, Jakarta"
   - Tanggal: Pick date 3 days from now
   - Catatan: "Paket rapih ya"
3. **Click "BUAT PESANAN"**

**Expected Result**:
- ✅ Loading spinner appears
- ✅ Backend validates data
- ✅ Snackbar: "Pesanan berhasil dibuat!"
- ✅ Auto-navigate back to home/cart

**Database Check**:
```sql
-- Verify order created
SELECT * FROM orders WHERE client_id = 5 AND admin_id = 1;

-- Should return:
-- id: 1, order_number: ORD-[timestamp]-[random], 
-- client_id: 5, admin_id: 1,
-- subtotal: 30000, tax_amount: 3000, grand_total: 33000,
-- status: 'pending', delivery_address: 'Jl. Example 123, Jakarta'

-- Verify order items created
SELECT * FROM order_items WHERE order_id = 1;

-- Should return:
-- id: 1, order_id: 1, product_id: 1 (Tomat), quantity: 2, price: 15000
```

---

### Test 7: Cart Cleared (Only Petani 1 Items)

**Purpose**: Verify only purchased farmer's items cleared

**Steps**:
1. From Test 6 (after successful order creation)
2. **Auto-navigate back to Cart screen**

**Expected Cart State**:
```
🏪 Petani 2: Green Land Farm (Siti Nurhaliza)
├─ Kentang          x3   Rp 24,000
└─ Subtotal: Rp 24,000
[Pesan dari Supplier Ini]

🏪 Petani 3: Buah Segar Farm (Ahmad Wijaya)
├─ Pisang Ambon     x1   Rp 12,000
└─ Subtotal: Rp 12,000
[Pesan dari Supplier Ini]

💰 Total: Rp 36,000  ← Reduced (Petani 1 gone)
```

**Verify**:
- ✅ Petani 1 section completely gone
- ✅ Petani 2 items still there (unchanged)
- ✅ Petani 3 items still there (unchanged)
- ✅ Total amount reduced by Petani 1's subtotal
- ✅ Can checkout Petani 2 next

---

### Test 8: Checkout Remaining Farmer

**Purpose**: Verify can checkout remaining farmers

**Steps**:
1. From Test 7 (Petani 2 & 3 still in cart)
2. **Click "Pesan dari Supplier Ini"** di Petani 2
3. **Repeat Test 6** (checkout process)

**Expected Result**:
- ✅ Order created for Petani 2
- ✅ Snackbar: "Pesanan berhasil dibuat!"
- ✅ Cart returns to show only Petani 3

**Database Check**:
```sql
-- Verify second order created
SELECT * FROM orders WHERE client_id = 5 AND admin_id = 2;
-- Should exist

-- Now have 2 orders
SELECT COUNT(*) FROM orders WHERE client_id = 5;
-- Result: 2
```

---

### Test 9: Checkout Final Farmer

**Purpose**: Verify can complete all checkouts

**Steps**:
1. From Test 8 (only Petani 3 left)
2. **Click "Pesan dari Supplier Ini"** di Petani 3
3. **Complete checkout**

**Expected Result**:
- ✅ Order created for Petani 3
- ✅ Cart is now empty
- ✅ Can add new products again

**Database Check**:
```sql
-- Verify all 3 orders exist
SELECT order_number, admin_id, grand_total FROM orders WHERE client_id = 5;

-- Result:
-- order_number        | admin_id | grand_total
-- ORD-xxx-1           | 1        | 33000
-- ORD-xxx-2           | 2        | 26400 (or similar)
-- ORD-xxx-3           | 3        | 13200 (or similar)

-- Verify correct items in each order
SELECT * FROM order_items oi 
JOIN orders o ON oi.order_id = o.id
WHERE o.client_id = 5
ORDER BY o.id;
```

---

### Test 10: Orders History (Verify Orders Created)

**Purpose**: Verify all orders appear in order history

**Steps**:
1. From Test 9
2. **Click "Pesanan" tab** (Orders history)
3. **Wait for orders to load**

**Expected UI**:
```
📋 Pesanan Saya

📦 Order #ORD-xxx-1
   Petani: Tani Jaya Farm (Budi Santoso)
   Total: Rp 33,000
   Status: Pending
   Tanggal: [order date]

📦 Order #ORD-xxx-2
   Petani: Green Land Farm (Siti Nurhaliza)
   Total: Rp 26,400
   Status: Pending
   Tanggal: [order date]

📦 Order #ORD-xxx-3
   Petani: Buah Segar Farm (Ahmad Wijaya)
   Total: Rp 13,200
   Status: Pending
   Tanggal: [order date]
```

**Verify**:
- ✅ All 3 orders shown
- ✅ Correct farmer info per order
- ✅ Correct total per order
- ✅ Status shows as 'pending'

---

## 🐛 Debugging Tips

### Issue: Cart shows items but groups not correct

**Debug**:
```bash
# 1. Check network response
# Open DevTools (Chrome) → Network tab
# GET /api/cart → Response body
# Verify: "items" array has grouped structure

# 2. Check Flutter logs
# Watch console for errors
# CardProvider.groupedBySupplier() output
```

### Issue: Items not clearing after checkout

**Debug**:
```bash
# 1. Check order creation
SELECT * FROM orders WHERE id = [last_order_id];

# 2. Check if clearCartBySupplier was called
# Flutter logs should show API call
# DELETE /api/cart/supplier/[supplier_id]

# 3. Check database directly
SELECT * FROM cart_items WHERE client_id = 5;
# Should NOT have items from checked out supplier
```

### Issue: Wrong total calculated

**Debug**:
```bash
# 1. Verify product prices in database
SELECT id, name, price, admin_id FROM products;

# 2. Check order totals calculation
SELECT subtotal, discount_amount, tax_amount, grand_total FROM orders WHERE id = [order_id];

# 3. Manual calculation
# Subtotal = sum(price * quantity)
# Tax = subtotal * 10% (if tax_percentage = 10)
# Total = subtotal + tax
```

---

## ✅ Full Test Checklist

- [ ] Test 1: Add multiple products
- [ ] Test 2: Cart groups by farmer  
- [ ] Test 3: Modify quantity
- [ ] Test 4: Remove item
- [ ] Test 5: Open checkout screen
- [ ] Test 6: Create first order
- [ ] Test 7: Cart shows only remaining farmers
- [ ] Test 8: Checkout second farmer
- [ ] Test 9: Checkout final farmer
- [ ] Test 10: View order history
- [ ] Database: Verify 3 orders created
- [ ] Database: Verify correct admin_id per order
- [ ] Database: Verify cart items cleared correctly

---

## 📝 Test Report Template

```
Test Report: Multiple Farmers Feature
Date: [date]
Tester: [name]

Environment:
- Backend: http://[ip]:5000
- Device: [Emulator/Physical Phone/Web]
- OS: [Android/iOS/Web]
- Network: [Connected/Issues?]

Test Results:
- Test 1: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
- Test 2: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
- Test 3: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL
...
- Test 10: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL

Issues Found:
1. [Issue description]
   Steps to reproduce: [steps]
   Expected: [what should happen]
   Actual: [what actually happened]
   
2. [Another issue]
   ...

Recommendations:
- [Improvement 1]
- [Improvement 2]

Signature: _____________
```

---

**Last Updated**: 13 Januari 2026  
**Status**: ✅ Ready for Testing  
**Next Steps**: Execute all test cases and report results
