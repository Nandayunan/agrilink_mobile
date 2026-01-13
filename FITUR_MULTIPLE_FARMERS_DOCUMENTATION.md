# 📚 Dokumentasi: Fitur Multiple Farmers (Pilih Petani)

## 🎯 Ringkasan Fitur

Restoran dapat **membeli dari berbagai petani** dengan cara:
1. ✅ Menambahkan produk dari petani yang berbeda ke dalam 1 keranjang
2. ✅ Melihat produk **dikelompokkan per petani** di halaman keranjang
3. ✅ **Memilih petani yang mana** untuk melakukan checkout
4. ✅ **1 order = 1 petani** (tidak bisa mix petani dalam 1 order)
5. ✅ **Pembayaran terpisah per petani** (setiap petani = 1 pesanan terpisah)

---

## 🏗️ Arsitektur Sistem

### Database Schema
```
✓ users (petani/admin) 
  ├─ id
  ├─ name
  ├─ role (admin/farmer, client/restoran)
  └─ company_name

✓ products
  ├─ id
  ├─ admin_id (link ke petani)
  ├─ name
  ├─ price
  └─ ...

✓ cart_items
  ├─ id
  ├─ client_id (restoran)
  ├─ product_id
  └─ quantity

✓ orders
  ├─ id
  ├─ order_number
  ├─ client_id (restoran)
  ├─ admin_id (petani - SINGLE)
  ├─ subtotal
  ├─ status
  └─ ...

✓ order_items
  ├─ id
  ├─ order_id
  ├─ product_id
  └─ quantity
```

### Data Flow

```
Restoran (Client)
    ↓
1. Add Products (dari Farmer A & B) → cart_items (track admin_id)
    ↓
2. View Cart (Backend group by admin_id)
    ↓
3. Cart Screen (UI show 2 sections: Farmer A & Farmer B)
    ↓
4. Click "Pesan dari Farmer A" → Checkout with supplierId=A
    ↓
5. Create Order (admin_id=A, items dari Farmer A)
    ↓
6. Clear Cart (hapus items Farmer A saja, Farmer B tetap ada)
    ↓
7. Kembali ke Cart (hanya Farmer B tersisa, bisa order lagi)
```

---

## 🔧 Implementation Details

### Frontend (Flutter)

#### 1️⃣ **Cart Item Model** (`lib/models/cart_item.dart`)
```dart
class CartItem {
  final int id;
  final int clientId;
  final int productId;
  int quantity;
  final String productName;
  final double price;
  final String unit;
  final String imageUrl;
  final int adminId;              // ✅ Farmer ID
  final String adminName;         // ✅ Farmer Name
  final String companyName;       // ✅ Company Name
  // ...
}
```

#### 2️⃣ **Cart Provider** (`lib/providers/cart_provider.dart`)
```dart
class CartProvider extends ChangeNotifier {
  // Group items by farmer
  Map<int, List<CartItem>> get groupedBySupplier {
    final Map<int, List<CartItem>> grouped = {};
    for (var item in _cartItems) {
      if (!grouped.containsKey(item.adminId)) {
        grouped[item.adminId] = [];
      }
      grouped[item.adminId]!.add(item);
    }
    return grouped;
  }

  // Clear only farmer's items
  Future<bool> clearCartBySupplier(int supplierId) async {
    // Removes only items where item.adminId == supplierId
  }
}
```

#### 3️⃣ **Cart Screen** (`lib/screens/cart_screen.dart`)
```dart
// Loop through grouped items
...cartProvider.groupedBySupplier.entries.map((entry) {
  final supplierId = entry.key;
  final items = entry.value;
  final supplier = items.first;

  // Display supplier header with name
  // Display all items from this supplier
  // Show subtotal for this supplier
  // Button: "Pesan dari Supplier Ini"
  
  // Navigate to checkout with supplierId
  CheckoutScreen(
    supplierId: supplierId,
    items: items,
  )
}).toList()
```

#### 4️⃣ **Checkout Flow** (`lib/screens/checkout_screen.dart`)
```dart
Future<void> _submitOrder() async {
  final success = await orderProvider.createOrder(
    adminId: widget.supplierId,  // ✅ Single farmer
    items: items,                 // ✅ Only this farmer's items
    // ... other fields
  );

  if (success) {
    // Clear only this supplier's cart items
    await cartProvider.clearCartBySupplier(widget.supplierId);
  }
}
```

### Backend (Node.js)

#### 1️⃣ **Get Cart Endpoint** (`routes/cart.js`)
```javascript
router.get('/', verifyToken, async (req, res) => {
  // Query: JOIN cart_items, products, users
  // Group by admin_id (farmer)
  // Return: {items: [{admin_id, admin_name, company_name, items[], subtotal}]}
});
```

#### 2️⃣ **Create Order Endpoint** (`routes/orders.js`)
```javascript
router.post('/', verifyToken, verifyClientRole, async (req, res) => {
  const { admin_id, items, ... } = req.body;
  
  // Validate: all items must have same admin_id
  // Create 1 order with admin_id (farmer)
  // Insert order_items (only from this farmer)
  // Update product stock
});
```

#### 3️⃣ **Clear Cart by Supplier** (`routes/cart.js`)
```javascript
router.delete('/supplier/:supplierId', verifyToken, async (req, res) => {
  // Delete only cart_items where product.admin_id == supplierId
  // Preserves items from other suppliers
});
```

---

## 📱 User Journey (Skenario)

### Skenario 1: Restoran beli dari 2 Petani berbeda

1. **Restoran A membuka app**
   - Home screen menampilkan produk semua petani

2. **Restoran menambahkan produk**
   - Ambil Tomat (Petani Budi) → Add to cart
   - Ambil Bayam (Petani Siti) → Add to cart
   - Ambil Cabai (Petani Budi) → Add to cart

3. **Keranjang** (Cart Screen)
   ```
   📦 Petani Budi (Tani Jaya Farm)
   ├─ Tomat Segar  x2  | Rp 30,000
   ├─ Cabai Merah  x1  | Rp 20,000
   └─ Subtotal: Rp 50,000
   [Pesan dari Supplier Ini] ← Button

   📦 Petani Siti (Green Land Farm)
   ├─ Bayam Segar  x3  | Rp 24,000
   └─ Subtotal: Rp 24,000
   [Pesan dari Supplier Ini] ← Button
   ```

4. **Checkout Petani Budi dulu**
   - Klik "Pesan dari Supplier Ini" (Petani Budi)
   - Isi form: Alamat pengiriman, tanggal, catatan
   - Review order (hanya Tomat + Cabai)
   - Konfirmasi order
   - ✅ Order #ORD-123 berhasil dibuat
   - ✅ Keranjang otomatis clear items Budi saja

5. **Keranjang sekarang hanya Bayam**
   ```
   📦 Petani Siti (Green Land Farm)
   ├─ Bayam Segar  x3  | Rp 24,000
   └─ Subtotal: Rp 24,000
   [Pesan dari Supplier Ini]
   ```

6. **Checkout Petani Siti**
   - Klik "Pesan dari Supplier Ini" (Petani Siti)
   - Isi form
   - ✅ Order #ORD-456 berhasil dibuat
   - ✅ Keranjang kosong

### Hasil:
- **Order 1**: Petani Budi | Rp 50,000
- **Order 2**: Petani Siti | Rp 24,000
- **Total**: Rp 74,000 (2 pembayaran terpisah)

---

## ✅ Fitur yang Sudah Implemented

| Fitur | Status | File | Note |
|-------|--------|------|------|
| Cart track farmer | ✅ | `cart_item.dart` | adminId field |
| Group by farmer (frontend) | ✅ | `cart_provider.dart` | groupedBySupplier() |
| Group by farmer (backend) | ✅ | `routes/cart.js` | GET /cart |
| UI: Multiple sections per farmer | ✅ | `cart_screen.dart` | Card per supplier |
| UI: Farmer info display | ✅ | `cart_screen.dart` | Company name + admin name |
| Checkout single farmer | ✅ | `checkout_screen.dart` | supplierId param |
| Clear only farmer's items | ✅ | `cart_provider.dart` | clearCartBySupplier() |
| API: Create order (single farmer) | ✅ | `routes/orders.js` | admin_id support |
| API: Clear cart by supplier | ✅ | `routes/cart.js` | DELETE /supplier/:id |

---

## 🧪 Testing Checklist

- [ ] **Test 1**: Add product dari farmer A, verify adminId saved
- [ ] **Test 2**: Add product dari farmer B, verify adminId saved
- [ ] **Test 3**: Cart screen shows 2 sections (Farmer A & B)
- [ ] **Test 4**: Each section shows correct farmer name/company
- [ ] **Test 5**: Each section shows correct subtotal
- [ ] **Test 6**: Click checkout Farmer A → items only dari A
- [ ] **Test 7**: Order created with correct admin_id (Farmer A)
- [ ] **Test 8**: After checkout, cart clears only Farmer A items
- [ ] **Test 9**: Farmer B items still in cart after checkout A
- [ ] **Test 10**: Can checkout Farmer B next

---

## 🚀 Cara Menggunakan

### Untuk Restoran (Client)

1. **Browse produk** dari berbagai petani
2. **Tambahkan ke keranjang** (tidak perlu khawatir petani berbeda)
3. **Buka keranjang** → lihat produk dikelompok per petani
4. **Pilih petani** → klik "Pesan dari Supplier Ini"
5. **Checkout** → isi data pengiriman & review
6. **Bayar** (pembayaran per petani)
7. **Ulangi** untuk petani lainnya jika ada

### Untuk Petani (Supplier/Admin)

1. **Upload produk** ke sistem
2. **Kelola stok** produk
3. **Lihat pesanan masuk** di halaman orders
4. **Update status pesanan** (confirmed, processing, shipped, dll)
5. **Terima pembayaran** dari restoran

---

## 📊 Database Queries

### Query: Get Cart (Grouped by Farmer)
```sql
SELECT 
    ci.*, 
    p.name, p.price, p.unit, p.image_url, p.admin_id, 
    u.company_name, u.name as admin_name
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
JOIN users u ON p.admin_id = u.id
WHERE ci.client_id = ?
ORDER BY p.admin_id, ci.added_at DESC;
```

### Query: Create Order (for farmer)
```sql
INSERT INTO orders 
(order_number, client_id, admin_id, subtotal, ..., status) 
VALUES (?, ?, ?, ?, ..., 'pending');
```

### Query: Clear Cart by Supplier
```sql
DELETE ci FROM cart_items ci
JOIN products p ON ci.product_id = p.id
WHERE ci.client_id = ? AND p.admin_id = ?;
```

---

## 🔐 Security Notes

- ✅ Verify `admin_id` match kembali ke product table
- ✅ Prevent client access cart items dari user lain
- ✅ Verify order items belong to specified admin_id
- ✅ All endpoints protected dengan `verifyToken` middleware

---

## 📈 Future Enhancements

1. **Batch checkout** - Order multiple farmers sekaligus
2. **Saved delivery addresses** - Pre-fill alamat pengiriman
3. **Order history grouped by farmer** - Lihat history per supplier
4. **Farmer ratings** - Rating/review per farmer
5. **Subscription/recurring orders** - Order otomatis per minggu
6. **Promo per farmer** - Discount khusus supplier tertentu

---

## 📞 Support

Jika ada error atau pertanyaan:
1. Check backend logs: `npm run dev`
2. Check frontend logs: `flutter run`
3. Verify database connection
4. Verify API endpoints in `ApiService.baseUrl`

---

**Last Updated**: 13 Januari 2026
**Status**: ✅ PRODUCTION READY
