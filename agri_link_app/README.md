# agri_link

A new Flutter project.

## ⚠️ PENTING: Konfigurasi IP Address

**Sebelum menjalankan aplikasi, WAJIB membaca dokumentasi konfigurasi IP:**

👉 **[📖 BACA: CONFIGURATION.md](./CONFIGURATION.md)** 👈

IP address laptop **BERUBAH** setiap kali pindah network WiFi. Jika tidak di-update di `lib/services/api_service.dart` (baris 19-20), aplikasi akan **timeout** atau tidak bisa connect ke backend.

**Quick Fix:**
1. Cek IP laptop: `ipconfig` (Windows) atau `ifconfig` (Linux/Mac)
2. Update IP di `lib/services/api_service.dart` baris 20
3. Rebuild: `flutter clean && flutter run`

---

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
