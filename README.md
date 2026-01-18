# agri_link

Aplikasi Mobile Agri-Link untuk menghubungkan Petani dan Restoran.

## ⚠️ PENTING: Konfigurasi IP Address

**Sebelum menjalankan aplikasi, WAJIB membaca dokumentasi konfigurasi IP:**

👉 **[📖 BACA: CONFIGURATION.md](./CONFIGURATION.md)** 👈

IP address laptop **BERUBAH** setiap kali pindah network WiFi. Jika tidak di-update di `lib/services/api_service.dart` (baris 19-20), aplikasi akan **timeout** atau tidak bisa connect ke backend.

**Quick Fix:**
1. Cek IP laptop: `ipconfig` (Windows) atau `ifconfig` (Linux/Mac)
2. Update IP di `lib/services/api_service.dart` baris 20
3. Rebuild: `flutter clean && flutter run`

---

## Struktur Frontend Mobile

Aplikasi ini dibagi menjadi dua role utama: **Petani** dan **Restoran**. Berikut adalah pembagian layar (screens) berdasarkan role:

### 👨‍🌾 Role: Petani (Admin)
Fitur-fitur untuk petani dikelola melalui role `admin` di database.
- **`FarmerProductsScreen`**: Manajemen Produk (Tambah, Edit, Hapus produk hasil panen).
- **`OrderApprovalScreen`**: Persetujuan Pesanan (Menerima atau menolak pesanan dari restoran).
- **`WeatherScreen`**: Informasi Cuaca untuk membantu perencanaan pertanian.
- **`ProfileScreen`**: Pengaturan profil petani.

### 🍽️ Role: Restoran (User)
Fitur-fitur untuk restoran/pembeli.
- **`RestaurantDashboardScreen`**: Dashboard Utama untuk memantau aktivitas terkini.
- **`HomeScreen`**: Katalog Produk untuk menjelajahi hasil panen yang tersedia.
- **`OrdersScreen`**: Riwayat Pesanan dan status pesanan.
- **`CartScreen`**: Keranjang Belanja sebelum checkout.
- **`CheckoutScreen`**: Proses pembayaran dan pemesanan.
- **`WeatherScreen`**: Informasi cuaca relevan.
- **`ProfileScreen`**: Pengaturan profil restoran.

---

## Cara Install & Setup

### Prerequisites
Pastikan Anda telah menginstal:
- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** atau **VS Code** (dengan ekstensi Flutter/Dart)
- **Android Emulator** atau **Physical Device** (Aktifkan USB Debugging)
- **Git**

### Installation Steps

1. **Clone Repository (Jika belum)**
   ```bash
   git clone <repository_url>
   cd agrilink_mobile/agri_link_app
   ```

2. **Install Dependencies**
   Jalankan perintah berikut di terminal root project:
   ```bash
   flutter pub get
   ```

3. **Konfigurasi IP Address (WAJIB)**
   - Seperti disebutkan di atas, sesuaikan IP address backend di `lib/services/api_service.dart`.
   - Pastikan backend Agri-Link sudah berjalan di laptop/server yang sama.

4. **Jalankan Aplikasi**
   Pastikan emulator atau device terhubung, lalu jalankan:
   ```bash
   flutter run
   ```

### 🔙 Terkait Backend
Aplikasi mobile ini membutuhkan **backend API** agar dapat berfungsi sepenuhnya (Login, Register, Data Produk, dll).
- Pastikan server backend (`agri_link_backend`) sudah berjalan (biasanya di `localhost:3000` atau IP statis).
- Database MySQL harus sudah di-import (`agri_link.sql`).

---

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
