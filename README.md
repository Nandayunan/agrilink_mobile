# DOKUMENTASI AGRI-LINK

## Gambaran Umum
Agri-Link adalah aplikasi mobile Flutter yang menghubungkan Restoran/Rumah Makan dengan Petani/Supplier untuk pemesanan bahan berkualitas. Aplikasi ini dilengkapi dengan API backend Node.js/Express dan database MySQL.

## Fitur Utama

### Untuk Client (Restoran)
- ✅ Registrasi dan Login
- ✅ Browsing produk dari berbagai petani
- ✅ Filter dan pencarian produk
- ✅ Tambah produk ke keranjang
- ✅ Checkout dengan perhitungan otomatis
- ✅ Lihat riwayat pesanan
- ✅ Informasi cuaca (BMKG API)
- ✅ Profil dan manajemen akun

### Untuk Admin (Petani/Supplier)
- ✅ Registrasi sebagai petani (pending approval)
- ✅ Kelola produk (CRUD)
- ✅ Lihat pesanan masuk
- ✅ Approve/Reject pesanan
- ✅ Dashboard statistik
- ✅ Informasi cuaca

### Fitur Teknis
- ✅ Perhitungan Otomatis:
  - Total = Σ(qty × price)
  - Diskon (%) opsional
  - Pajak/Biaya (%) opsional
  - Grand Total = Subtotal − Diskon + Pajak + Biaya
- ✅ JWT Authentication
- ✅ BMKG Weather API Integration
- ✅ MySQL Database
- ✅ RESTful API
- ✅ Provider State Management
- ✅ Professional UI/UX

## Struktur Project

```
TA_MOBILE/
├── agri_link_backend/          # Backend API
│   ├── server.js               # Entry point
│   ├── package.json            # Dependencies
│   ├── .env.example            # Environment variables
│   ├── database.sql            # Schema
│   ├── middleware/
│   │   └── auth.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── products.js
│   │   ├── orders.js
│   │   ├── cart.js
│   │   ├── admin.js
│   │   └── weather.js
│   └── controllers/
│
└── agri_link_app/              # Flutter App
    ├── pubspec.yaml            # Dependencies
    ├── lib/
    │   ├── main.dart           # Entry point
    │   ├── models/             # Data models
    │   ├── providers/          # State management
    │   ├── screens/            # UI screens
    │   ├── widgets/            # Reusable widgets
    │   ├── services/           # API service
    │   └── utils/              # Helpers & themes
    └── assets/                 # Images & icons
```

## Instalasi & Setup

### Backend Setup

1. **Install Node.js** (v14+)

2. **Setup Database**
   ```bash
   # Buka XAMPP Control Panel
   # Start Apache dan MySQL
   # Buka phpMyAdmin (http://localhost/phpmyadmin)
   # Import database.sql dari agri_link_backend folder
   ```

3. **Install Dependencies**
   ```bash
   cd agri_link_backend
   npm install
   ```

4. **Setup Environment**
   ```bash
   # Copy .env.example ke .env
   cp .env.example .env
   
   # Edit .env dengan konfigurasi database:
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=agri_link
   JWT_SECRET=your_secret_key
   ```

5. **Jalankan Server**
   ```bash
   npm run dev
   # atau: npm start
   
   # Server akan berjalan di http://localhost:5000
   ```

### Flutter App Setup

1. **Install Flutter** (Channel stable)
   ```bash
   flutter --version
   ```

2. **Install Dependencies**
   ```bash
   cd agri_link_app
   flutter pub get
   ```

3. **Update API URL** (jika berbeda)
   - Edit `lib/services/api_service.dart`
   - Ubah `baseUrl` sesuai IP backend Anda

4. **Run App**
   ```bash
   flutter run
   
   # Atau untuk device spesifik:
   flutter run -d chrome  # Web
   flutter run -d emulator-5554  # Android
   ```

## API Documentation

### Base URL
`http://localhost:5000/api`

### Auth Endpoints
- `POST /auth/register` - Register user
- `POST /auth/login` - Login user
- `GET /auth/me` - Get current user

### Product Endpoints
- `GET /products` - Get all products
- `GET /products/:id` - Get product detail
- `POST /products` - Create product (admin)
- `PUT /products/:id` - Update product (admin)
- `DELETE /products/:id` - Delete product (admin)
- `GET /products/categories/list` - Get categories

### Cart Endpoints
- `GET /cart` - Get cart items
- `POST /cart/add` - Add to cart
- `PUT /cart/:id` - Update cart item
- `DELETE /cart/:id` - Remove from cart

### Order Endpoints
- `GET /orders` - Get user orders
- `GET /orders/:id` - Get order detail
- `POST /orders` - Create order

### Weather Endpoints
- `GET /weather/province/:name` - Get weather by province
- `GET /weather/location/:lat/:lon` - Get weather by coordinates
- `GET /weather/provinces/list` - Get all provinces

### Admin Endpoints
- `GET /admin/pending-accounts` - Get pending accounts
- `POST /admin/approve-account/:id` - Approve account
- `GET /admin/dashboard/stats` - Get dashboard stats
- `GET /admin/orders` - Get supplier orders

## Perhitungan Total Pesanan

Formula Perhitungan:
```
Diskon Amount = (Subtotal × Diskon %) / 100
Pajak Amount = ((Subtotal - Diskon Amount) × Pajak %) / 100
Grand Total = Subtotal - Diskon Amount + Pajak Amount + Biaya Layanan
```

Contoh:
```
Subtotal = 500,000
Diskon = 10% → Diskon Amount = 50,000
Pajak = 10% → Pajak Amount = (450,000 × 10%) = 45,000
Biaya Layanan = 10,000
Grand Total = 500,000 - 50,000 + 45,000 + 10,000 = 505,000
```

## Database Schema

### Users Table
- id (PK)
- name, email, password
- phone, address, city, province
- role (client/admin)
- status (pending/approved/rejected)
- company_name, business_license
- latitude, longitude
- created_at, updated_at

### Products Table
- id (PK)
- admin_id (FK)
- category, name, description
- price, stock, unit
- image_url
- is_available
- created_at, updated_at

### Orders Table
- id (PK)
- order_number (unique)
- client_id (FK), admin_id (FK)
- subtotal, discount_percentage, discount_amount
- service_fee, tax_percentage, tax_amount
- grand_total
- status, payment_status
- delivery_address, delivery_date
- notes
- created_at, updated_at

### Order Items Table
- id (PK)
- order_id (FK), product_id (FK)
- quantity, price, subtotal
- notes
- created_at

### Cart Items Table
- id (PK)
- client_id (FK), product_id (FK)
- quantity
- added_at

### Weather Cache Table
- id (PK)
- province, city
- latitude, longitude
- temperature, humidity
- weather_description, wind_speed
- forecast_date
- cached_at

## Testing Credentials

**Client Account:**
```
Email: restoran@agrilink.com
Password: password123
Role: Restoran
```

**Admin Account:**
```
Email: petani@agrilink.com
Password: password123
Role: Petani
Status: approved
```

## BMKG Weather API

API publik dari Badan Meteorologi Klimatologi dan Geofisika Indonesia:
- Base URL: `https://api.bmkg.go.id/publik`
- Endpoints:
  - `/prakiraan-cuaca?adm4=:id` - Prakiraan cuaca berdasarkan ADM4
  - `/prakiraan-cuaca?lon=:lon&lat=:lat` - Cuaca berdasarkan koordinat
- Tidak memerlukan API Key

### ⚠️ IMPORTANT: Keterbatasan Akses API BMKG

**Keterbatasan yang Ditemukan:**
- Endpoint `/publik/provinsi` untuk mendapatkan list provinsi **tidak tersedia** (mengembalikan 404)
- Saat ini aplikasi hanya dapat mengakses data cuaca untuk **ADM4: `31.71.01.1001`** (Gambir, Jakarta Pusat, DKI Jakarta)
- Semua request cuaca akan menggunakan ADM4 default ini terlepas dari provinsi yang dipilih di frontend

**Solusi Sementara:**
- Menggunakan hardcoded list provinsi untuk dropdown
- Semua request cuaca mengarah ke lokasi default: **DKI Jakarta (Gambir)**
- Data cuaca yang ditampilkan adalah untuk lokasi tersebut

**Untuk Menggunakan Lokasi Lain:**
Jika ingin menggunakan ADM4 untuk lokasi lain, perlu:
1. Mengetahui ADM4 code untuk lokasi yang diinginkan
2. Update `DEFAULT_ADM4` constant di `agri_link_backend/routes/weather.js`
3. Atau implementasikan mapping provinsi → ADM4 yang lebih lengkap

**Contoh ADM4 Format:**
- Format: `{adm1}.{adm2}.{adm3}.{adm4}`
- Contoh: `31.71.01.1001` = DKI Jakarta → Jakarta Pusat → Gambir → Gambir
- ADM4 adalah kode desa/kelurahan di Indonesia

**Catatan:**
- API BMKG adalah API publik dan gratis
- Tidak ada dokumentasi resmi yang lengkap tentang endpoint provinsi
- Untuk production, pertimbangkan menggunakan API cuaca alternatif atau implementasi mapping ADM4 yang lebih lengkap

## Features Implementasi

### ✅ Sudah Implement
1. Authentication & Authorization
2. Product Management (CRUD)
3. Shopping Cart
4. Order Management
5. Price Calculation dengan Diskon & Pajak
6. BMKG Weather API Integration
7. Professional UI dengan Material Design
8. State Management dengan Provider
9. Database dengan MySQL
10. RESTful API dengan Express.js

### 📝 Notes
- Password di sample data sudah di-hash dengan bcryptjs
- JWT Token berlaku 7 hari
- Order status flow: pending → confirmed → processing → shipped → delivered
- Petani harus di-approve oleh super admin untuk bisa login
- Setiap API request memerlukan JWT token (kecuali public endpoints)

## Troubleshooting

**Error: Cannot connect to backend**
- Pastikan backend server running (`npm run dev`)
- Pastikan port 5000 tidak digunakan service lain
- Update API URL di `api_service.dart` dengan IP backend yang benar

**Error: Database connection failed**
- Pastikan MySQL XAMPP running
- Check DB credentials di `.env` file
- Import `database.sql` ke phpMyAdmin

**Error: Weather API tidak response**
- Periksa koneksi internet
- BMKG API sometimes down, coba lagi nanti
- Gunakan cached data jika tersedia
- **PENTING:** Saat ini hanya bisa mengakses ADM4 `31.71.01.1001` (DKI Jakarta)
- Jika perlu lokasi lain, update `DEFAULT_ADM4` di `routes/weather.js`

## Deployment

### Untuk Production
1. Set `NODE_ENV=production` di backend
2. Use environment variables untuk sensitive data
3. Setup HTTPS/SSL
4. Use proper database backups
5. Enable CORS dengan whitelist
6. Rate limiting untuk API
7. Deploy ke cloud (Heroku, DigitalOcean, AWS, dll)

## Developer Notes

- Gunakan `flutter pub upgrade` untuk update dependencies
- Gunakan `npm update` untuk update backend dependencies
- Selalu test API endpoints di Postman sebelum integrate
- Backup database regularly
- Monitor API logs untuk debugging

## Support & Contact

Jika ada pertanyaan atau issue:
1. Check API endpoint response
2. Verify database schema
3. Check JWT token validity
4. Review error logs

---

**Version:** 1.0.0  
**Last Updated:** December 2025  
**Status:** Production Ready
