# Dashboard Messaging Restoran - IMPLEMENTASI SELESAI

## 🎯 Ringkasan Perubahan

Telah berhasil menambahkan fitur **Dashboard Pesan** untuk role restoran (client) yang memungkinkan restoran untuk:
1. ✅ Melihat pesan masuk dari supplier/petani
2. ✅ Menghubungi supplier atau petani pilihan
3. ✅ Mengelola konversasi dengan supplier/petani favorit
4. ✅ Melihat statistik pesan (pesan belum dibaca)

---

## 📊 Perubahan Database

### Tabel Baru: `restaurant_farmers`
Menyimpan hubungan antara restoran dan petani favorit mereka
```sql
CREATE TABLE `restaurant_farmers` (
  id INT PRIMARY KEY AUTO_INCREMENT
  restaurant_id INT (FK to users)
  farmer_id INT (FK to users)
  created_at TIMESTAMP
)
```

### Tabel Baru: `messages`
Menyimpan semua pesan antara restoran, supplier, dan petani
```sql
CREATE TABLE `messages` (
  id INT PRIMARY KEY AUTO_INCREMENT
  sender_id INT (FK to users)
  recipient_id INT (FK to users)
  sender_type ENUM('restaurant','farmer','supplier')
  recipient_type ENUM('restaurant','farmer','supplier')
  title VARCHAR(255)
  content LONGTEXT
  message_type ENUM('inquiry','offer','update','order_related')
  is_read TINYINT (boolean)
  created_at TIMESTAMP
  updated_at TIMESTAMP
)
```

---

## 🔌 Backend API Routes

### File: `routes/messages.js`

1. **GET /suppliers-farmers/:restaurantId**
   - Dapatkan daftar semua supplier (petani role='admin') dan petani favorit restoran
   - Response: Array of `Contact` objects

2. **GET /conversation/:restaurantId/:contactId**
   - Dapatkan percakapan lengkap antara restoran dan supplier/petani tertentu
   - Response: Array of `Message` objects (sorted by date)

3. **GET /inbox/:restaurantId**
   - Dapatkan semua pesan masuk untuk restoran
   - Response: Array of `Message` objects (sorted by read status & date)

4. **POST /send**
   - Kirim pesan baru
   - Body: `{ senderId, recipientId, title, content, messageType }`
   - Response: New `Message` object

5. **PUT /mark-as-read/:messageId**
   - Tandai pesan sebagai sudah dibaca
   - Response: `{ success: true }`

6. **GET /stats/:restaurantId**
   - Dapatkan statistik pesan (total & belum dibaca)
   - Response: `{ total_messages, unread_messages }`

7. **POST /add-favorite-farmer**
   - Tambahkan petani ke daftar favorit
   - Body: `{ restaurantId, farmerId }`
   - Response: `{ success: true, id }`

8. **DELETE /remove-favorite-farmer/:restaurantId/:farmerId**
   - Hapus petani dari daftar favorit
   - Response: `{ success: true }`

---

## 🎨 Frontend Flutter Implementation

### Model: `models/message.dart`
- `Message` class: Mewakili satu pesan
- `Contact` class: Mewakili supplier/petani

### Provider: `providers/message_provider.dart`
- `MessageProvider` extends `ChangeNotifier`
- Methods:
  - `fetchSuppliersAndFarmers()` - Load supplier & petani
  - `fetchConversation()` - Load chat history
  - `fetchInbox()` - Load pesan masuk
  - `sendMessage()` - Kirim pesan baru
  - `markAsRead()` - Tandai pesan dibaca
  - `fetchMessageStats()` - Statistik pesan
  - `addFavoriteFarmer()` - Tambah petani favorit
  - `removeFavoriteFarmer()` - Hapus petani favorit
  - `selectContact()` - Pilih contact untuk chat

### Screen: `screens/restaurant_dashboard_screen.dart`
- **Tab 1: Pesan Masuk**
  - Menampilkan list pesan dari supplier/petani
  - Indicator untuk pesan belum dibaca
  - Klik pesan untuk melihat detail & balas
  - Badge menampilkan jumlah pesan belum dibaca

- **Tab 2: Hubungi Supplier/Petani**
  - Section terpisah: "Supplier (Petani)" & "Petani Pilihan"
  - Kartu kontak dengan info lengkap (nama, perusahaan, lokasi, telepon)
  - Tombol "Hubungi" untuk mengirim pesan
  - Dialog untuk compose pesan dengan:
    - Pilihan jenis pesan: Pertanyaan, Penawaran, Update
    - Field title dan content
    - Auto-kirim ke backend

### Integration: `screens/home_screen.dart`
- Tambah tab baru "Pesan" (icon: `Icons.mail`) untuk restoran
- Tab urutan: Beranda → **Pesan** → Pesanan → Cuaca → Profil
- Provider `MessageProvider` diintegrasikan di main.dart

---

## 💾 Update File

### Modified Files:
1. ✅ `agri_link_backend/agri_link.sql` - Tambah 2 tabel baru
2. ✅ `agri_link_backend/server.js` - Register route messages
3. ✅ `agri_link_app/lib/main.dart` - Add MessageProvider
4. ✅ `agri_link_app/lib/screens/home_screen.dart` - Add dashboard tab

### New Files:
1. ✅ `agri_link_backend/routes/messages.js` - Backend API
2. ✅ `agri_link_app/lib/models/message.dart` - Data models
3. ✅ `agri_link_app/lib/providers/message_provider.dart` - State management
4. ✅ `agri_link_app/lib/screens/restaurant_dashboard_screen.dart` - UI

---

## 🚀 Cara Menggunakan

### 1. Update Database
```bash
# Login ke phpMyAdmin atau MySQL
mysql -u root -p agri_link < agri_link.sql
```

### 2. Jalankan Backend
```bash
cd agri_link_backend
npm start
# Server berjalan di http://localhost:3000
```

### 3. Jalankan Frontend
```bash
cd agri_link_app
flutter run
```

### 4. Test Feature
- Login sebagai **Restoran** (role: client)
- Di Tab "Pesan", lihat dua tab:
  - **Tab 1 "Pesan Masuk"**: Lihat pesan dari supplier/petani
  - **Tab 2 "Hubungi Supplier/Petani"**: Hubungi supplier/petani

---

## ✨ Fitur Unggulan

✅ **Otomatis Load Supplier & Petani**
- Semua petani (role='admin') ditampilkan sebagai Supplier
- Petani favorit restoran ditampilkan terpisah

✅ **Real-time Notification**
- Badge counter untuk pesan belum dibaca
- Indicator dot pada pesan belum dibaca

✅ **Tipe Pesan Berlainan**
- Pertanyaan (inquiry)
- Penawaran (offer)
- Update (update)
- Terkait Pesanan (order_related)

✅ **Pesan dengan Warna**
- Setiap tipe pesan punya warna berbeda untuk visual clarity

✅ **Markdown-like UI**
- Clean, modern interface mengikuti tema Agri-Link
- Responsive design
- Easy to read message previews

---

## 📝 Contoh Data

### Supplier/Petani di Database
```
ID: 1 - "Admin Petani Bandung" (role='admin') → Ditampilkan sebagai Supplier
ID: 3 - "Nand" (role='admin', pending) → Tidak ditampilkan (pending)
ID: 4 - "Nanda" (role='client') → Tidak ditampilkan (client)
ID: 5 - "Yunan" (role='client') → Tidak ditampilkan (client)
```

### Restoran di Database
```
ID: 2 - "Restoran Taman Kota" (role='client')
ID: 4 - "Nanda" (role='client')
ID: 5 - "Yunan" (role='client')
```

---

## 🎯 Next Steps (Opsional)

Jika ingin memperluas fitur lebih lanjut:

1. **Attachment Support** - Tambah file/gambar ke pesan
2. **Read Receipts** - Tampilkan kapan pesan dibaca
3. **Typing Indicator** - Tampilkan saat orang sedang mengetik
4. **Message Search** - Fitur pencarian dalam pesan
5. **Message Archive** - Arsipkan percakapan lama
6. **Notification Push** - Alert real-time untuk pesan baru

---

## ❓ Pertanyaan & Support

Jika ada pertanyaan atau butuh penyesuaian lebih lanjut, silakan beri tahu!

**Implementasi Selesai ✅**
