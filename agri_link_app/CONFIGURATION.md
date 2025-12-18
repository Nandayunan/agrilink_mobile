# ⚠️ PENTING: Konfigurasi IP Address untuk Koneksi API

## 📍 Lokasi File
File konfigurasi IP berada di: `lib/services/api_service.dart` (baris 19-20)

## 🎯 Mengapa Penting?

IP address laptop/komputer **BERUBAH** setiap kali:
- Pindah jaringan WiFi yang berbeda
- Restart router/modem
- Menggunakan hotspot yang berbeda
- DHCP memberikan IP baru

Jika IP tidak di-update, aplikasi akan **timeout** atau **tidak bisa connect** ke backend server.

---

## 🔧 Cara Mengubah IP Address

### 1. Cek IP Address Laptop Saat Ini

**Windows:**
```bash
ipconfig
```
Cari **IPv4 Address** di bagian **Wireless LAN adapter Wi-Fi** atau **Ethernet adapter**

**Linux/Mac:**
```bash
ifconfig
# atau
ip addr show
```

### 2. Update IP di `api_service.dart`

Buka file: `agri_link_app/lib/services/api_service.dart`

**Baris 19-20:**
```dart
} else {
  // HP fisik: pakai IP Wi‑Fi laptop
  return 'http://192.168.1.5:5000/api'; // ⚠️ GANTI IP INI!
}
```

**Ganti `192.168.1.5` dengan IP laptop Anda yang baru.**

### 3. Rebuild Aplikasi

⚠️ **PENTING:** Setelah mengubah IP, **WAJIB** melakukan **full rebuild** (bukan hot reload):

```bash
cd agri_link_app
flutter clean
flutter run
```

Atau jika build APK:
```bash
flutter clean
flutter build apk
```

**Mengapa harus rebuild?** Karena konstanta `useAndroidEmulator` dan IP address di-compile saat build, bukan saat runtime.

---

## 📱 Konfigurasi untuk Emulator vs Device Fisik

### Emulator Android
- **IP:** `10.0.2.2` (fixed, tidak perlu diubah)
- **Setting:** `useAndroidEmulator = true` (baris 7)

### Device Fisik (HP)
- **IP:** IP WiFi laptop Anda (contoh: `192.168.1.5`)
- **Setting:** `useAndroidEmulator = false` (baris 7)

---

## ✅ Checklist Sebelum Run

- [ ] Backend server sudah running di port 5000
- [ ] Server listen di `0.0.0.0:5000` (bukan hanya `localhost`)
- [ ] IP laptop sudah di-update di `api_service.dart`
- [ ] Device dan laptop dalam **network WiFi yang sama**
- [ ] Firewall tidak memblokir port 5000
- [ ] Sudah melakukan **full rebuild** setelah mengubah IP

---

## 🐛 Troubleshooting

### Error: TimeoutException
**Kemungkinan penyebab:**
1. IP laptop sudah berubah → **Cek dan update IP**
2. Server backend tidak running → **Start backend server**
3. Server hanya listen di localhost → **Pastikan server listen di `0.0.0.0:5000`**
4. Device dan laptop beda network → **Pastikan dalam WiFi yang sama**
5. Firewall memblokir → **Allow port 5000 di firewall**

### Error: Connection refused
- Pastikan backend server sudah running
- Pastikan port 5000 tidak digunakan aplikasi lain
- Cek apakah server listen di IP yang benar

### Error: Network unreachable
- Pastikan device dan laptop dalam network yang sama
- Cek koneksi WiFi device
- Coba ping IP laptop dari device (jika memungkinkan)

---

## 📝 Contoh IP Address

IP address biasanya dalam format:
- `192.168.x.x` (paling umum)
- `10.0.x.x`
- `172.16.x.x` - `172.31.x.x`

**Jangan gunakan:**
- `127.0.0.1` atau `localhost` (hanya untuk emulator/simulator)
- `10.0.2.2` (khusus untuk Android emulator)

---

## 🔄 Workflow Saat Pindah Network

1. **Cek IP baru:**
   ```bash
   ipconfig  # Windows
   ```

2. **Update IP di `api_service.dart`** (baris 20)

3. **Rebuild aplikasi:**
   ```bash
   flutter clean && flutter run
   ```

4. **Test koneksi** dengan login atau request API

---

## 💡 Tips

- **Simpan IP di notes** untuk referensi cepat
- **Gunakan IP static** di router (jika memungkinkan) agar IP tidak berubah
- **Cek IP sebelum setiap development session**
- **Gunakan debug logging** di `api_service.dart` untuk melihat URL yang digunakan

---

**⚠️ INGAT:** Setiap kali IP laptop berubah, **WAJIB** update di `api_service.dart` dan **rebuild aplikasi**!

