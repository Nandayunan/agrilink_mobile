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

## Struktur Aplikasi (Frontend & Backend)

### Struktur Pohon

```text
agrilink_mobile
 ┣ agri_link_app (Frontend Mobile)
 ┃ ┗ lib
 ┃   ┣ models
 ┃   ┃ ┣ cart_item.dart
 ┃   ┃ ┣ message.dart
 ┃   ┃ ┣ order.dart
 ┃   ┃ ┣ product.dart
 ┃   ┃ ┗ user.dart
 ┃   ┣ providers
 ┃   ┃ ┣ auth_provider.dart      <-- (State Management: Auth)
 ┃   ┃ ┣ cart_provider.dart      <-- (State Management: Cart)
 ┃   ┃ ┣ message_provider.dart   <-- (State Management: Chat)
 ┃   ┃ ┣ order_provider.dart     <-- (State Management: Orders)
 ┃   ┃ ┣ product_provider.dart   <-- (State Management: Products)
 ┃   ┃ ┗ weather_provider.dart   <-- (State Management: Weather)
 ┃   ┣ screens
 ┃   ┃ ┣ about_screen.dart       <-- (Info App)
 ┃   ┃ ┣ cart_screen.dart        <-- (Restoran: Keranjang)
 ┃   ┃ ┣ checkout_screen.dart    <-- (Restoran: Pembayaran)
 ┃   ┃ ┣ farmer_products_screen.dart  <-- (Petani: Kelola Produk)
 ┃   ┃ ┣ home_screen.dart        <-- (Restoran: Homepage)
 ┃   ┃ ┣ login_screen.dart       <-- (Auth: Login)
 ┃   ┃ ┣ order_approval_screen.dart   <-- (Petani: Konfirmasi Order)
 ┃   ┃ ┣ orders_screen.dart      <-- (Restoran: Riwayat Order)
 ┃   ┃ ┣ product_detail_screen.dart   <-- (Restoran: Detail Produk)
 ┃   ┃ ┣ profile_screen.dart     <-- (Shared: Profil User)
 ┃   ┃ ┣ register_screen.dart    <-- (Auth: Register)
 ┃   ┃ ┣ restaurant_dashboard_screen.dart <-- (Restoran: Dashboard)
 ┃   ┃ ┣ splash_screen.dart      <-- (Intro)
 ┃   ┃ ┗ weather_screen.dart     <-- (Shared: Cuaca)
 ┃   ┣ services
 ┃   ┃ ┗ api_service.dart        <-- (HTTP Requests ke Backend)
 ┃   ┣ utils
 ┃   ┃ ┣ app_theme.dart          <-- (Tema & Styling)
 ┃   ┃ ┗ helpers.dart            <-- (Helper Functions)
 ┃   ┣ widgets
 ┃   ┃ ┗ custom_widgets.dart     <-- (Reusable Components)
 ┃   ┗ main.dart                 <-- (Entry Point)
 ┗ agri_link_backend (Backend API)
   ┣ middleware
   ┣ routes
   ┃ ┣ admin.js           <-- (Petani/Admin)
   ┃ ┣ auth.js            <-- (Auth System)
   ┃ ┣ cart.js            <-- (Restoran)
   ┃ ┣ messages.js        <-- (Shared)
   ┃ ┣ orders.js          <-- (Shared: Restoran Order, Petani Approve)
   ┃ ┣ products.js        <-- (Shared: Petani Manage, Restoran View)
   ┃ ┣ users.js           <-- (Profile Management)
   ┃ ┗ weather.js         <-- (Weather Info)
   ┗ server.js
```

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
