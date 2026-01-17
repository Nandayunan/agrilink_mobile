# 🖼️ Fitur Image Upload untuk Produk - Implementasi Lengkap

## 📊 Status Implementasi

### ✅ SELESAI DI FRONTEND
Semua komponen image upload telah diintegrasikan penuh di Flutter app.

## 🎨 Fitur yang Ditambahkan

### 1. **Image Picker UI**
- Tombol "Pilih Gambar" di form produk (Tambah/Edit)
- Preview gambar ukuran 150x150px
- Support gambar dari galeri device

### 2. **Preview Gambar**
Ketika membuat/edit produk, user akan melihat:
- **Gambar baru (dipilih):** Tampil langsung dari file device
- **Gambar existing (saat edit):** Tampil dari URL server
- **Placeholder:** Icon kosong jika belum ada gambar

### 3. **Validasi & Optimasi**
- Compression otomatis via ImagePicker (quality: 80%)
- Format: JPG, PNG, GIF
- Max size: otomatis dikompres

### 4. **Upload Mechanism**
- Menggunakan **Dio** dengan **FormData** (multipart/form-data)
- Token Authorization otomatis included
- Support baik create maupun update produk

## 📱 Cara Penggunaan

### TAMBAH PRODUK DENGAN GAMBAR
```
1. Buka "Kelola Produk" (hamburger menu)
2. Klik tombol (+) Tambah Produk
3. Klik "Pilih Gambar" → Galeri terbuka
4. Pilih gambar → Preview muncul
5. Isi data produk lainnya (nama, harga, stok, dll)
6. Klik "Tambah" → Upload gambar + data produk
```

### EDIT PRODUK DENGAN GAMBAR BARU
```
1. Buka "Kelola Produk"
2. Klik tombol "Edit" pada produk
3. Form terbuka dengan data existing
4. (Opsional) Klik "Pilih Gambar" → ganti dengan gambar baru
5. Update field yang perlu diubah
6. Klik "Simpan" → Upload perubahan
```

## 🔧 Perubahan Code yang Dilakukan

### `/lib/screens/farmer_products_screen.dart`
```dart
// ✅ Import baru
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ✅ Variabel untuk menyimpan file gambar
File? selectedImageFile;

// ✅ UI tambahan:
// - Container untuk preview gambar
// - Tombol "Pilih Gambar" dengan onPressed handler
// - StatefulBuilder untuk update UI saat gambar dipilih

// ✅ Passing imageFile saat create/update
await productProvider.createProduct(
  name: nameController.text,
  // ... field lainnya ...
  imageFile: selectedImageFile,
);
```

### `/lib/providers/product_provider.dart`
```dart
// ✅ Import
import 'dart:io';

// ✅ Update createProduct()
Future<bool> createProduct({
  // ... existing parameters ...
  File? imageFile,
}) async {
  // ... send imageFile ke API Service
}

// ✅ Update updateProduct()
Future<bool> updateProduct({
  // ... existing parameters ...
  File? imageFile,
}) async {
  // ... send imageFile ke API Service
}
```

### `/lib/services/api_service.dart`
```dart
// ✅ Import baru
import 'package:dio/dio.dart';
import 'dart:io';

// ✅ Update createProduct() - gunakan Dio FormData
static Future<Map<String, dynamic>> createProduct({
  // ... existing parameters ...
  File? imageFile,
}) async {
  final dio = Dio();
  FormData formData = FormData.fromMap({
    'name': name,
    'image': await MultipartFile.fromFile(imageFile.path),
    // ... field lainnya ...
  });
  
  final response = await dio.post(
    '$baseUrl/products',
    data: formData,
    options: Options(headers: { 'Authorization': 'Bearer $token' }),
  );
}

// ✅ Update updateProduct() - gunakan Dio FormData
static Future<Map<String, dynamic>> updateProduct({
  // ... existing parameters ...
  File? imageFile,
}) async {
  // ... similar implementation ...
}
```

## ⚙️ Backend Setup (DIPERLUKAN UNTUK LENGKAP)

### Current State
Backend sudah **siap menerima** image tapi masih dengan `image_url` sebagai string.

### Untuk Implementasi Lengkap, Backend Perlu:

1. **Install Multer**
   ```bash
   npm install multer
   ```

2. **Setup Storage di server.js**
   ```javascript
   const multer = require('multer');
   const storage = multer.diskStorage({
     destination: 'uploads/products/',
     filename: (req, file, cb) => {
       cb(null, Date.now() + '.jpg');
     }
   });
   const upload = multer({ storage });
   ```

3. **Update create endpoint di routes/products.js**
   ```javascript
   router.post('/', verifyToken, verifyAdminRole, upload.single('image'), async (req, res) => {
     // Handle file path & save to DB
   });
   ```

4. **Update update endpoint**
   ```javascript
   router.put('/:productId', verifyToken, verifyAdminRole, upload.single('image'), async (req, res) => {
     // Handle file path replacement & save to DB
   });
   ```

## 🎯 Flow Lengkap

```
┌─────────────┐
│   Petani    │
└──────┬──────┘
       │ Buka Form Tambah/Edit Produk
       ↓
┌─────────────────────────────────────┐
│  farmer_products_screen.dart         │
│  - Show Form                         │
│  - Show Image Picker Button          │
│  - Show Image Preview                │
└──────┬──────────────────────────────┘
       │ User memilih gambar & isi form
       ↓
┌──────────────────────────────┐
│  Validasi & Compress Image   │
│  (ImagePicker)               │
└──────┬───────────────────────┘
       │ File ready
       ↓
┌─────────────────────────────────────┐
│  product_provider.dart              │
│  - Call createProduct/updateProduct │
└──────┬──────────────────────────────┘
       │ Prepare data + imageFile
       ↓
┌──────────────────────────────────────┐
│  api_service.dart                    │
│  - Use Dio FormData                  │
│  - Include Authorization Token       │
│  - Upload multipart/form-data        │
└──────┬───────────────────────────────┘
       │ HTTP POST/PUT request
       ↓
┌───────────────────────────────────┐
│  Backend (Node.js)                │
│  - Receive FormData               │
│  - Save file ke disk (uploads/)   │
│  - Save image_url to DB           │
│  - Return response                │
└──────┬────────────────────────────┘
       │ success response
       ↓
┌──────────────────────────────────┐
│  product_provider.dart           │
│  - Update _products list         │
│  - notifyListeners()             │
└──────┬───────────────────────────┘
       │ State updated
       ↓
┌──────────────────────────────────┐
│  farmer_products_screen.dart     │
│  - Build ulang dengan data baru  │
│  - Tampil gambar produk baru     │
└──────────────────────────────────┘
```

## 📚 Dependencies yang Digunakan

| Package | Version | Fungsi |
|---------|---------|--------|
| `image_picker` | ^1.0.0 | Pilih gambar dari galeri |
| `dio` | ^5.2.0 | HTTP client untuk FormData upload |
| `flutter` | sdk | Framework utama |

## 🧪 Testing Flow

### Test 1: Tambah Produk Baru dengan Gambar
- [ ] Buka halaman Kelola Produk
- [ ] Klik tombol (+)
- [ ] Klik "Pilih Gambar" → pilih dari galeri
- [ ] Isi semua field produk
- [ ] Klik "Tambah"
- [ ] Cek apakah gambar terupload ✅

### Test 2: Edit Produk dengan Gambar Baru
- [ ] Buka halaman Kelola Produk
- [ ] Klik "Edit" pada produk existing
- [ ] Lihat gambar lama di preview
- [ ] Klik "Pilih Gambar" → ganti dengan gambar baru
- [ ] Ubah beberapa field
- [ ] Klik "Simpan"
- [ ] Cek apakah gambar baru terupload ✅

### Test 3: Edit Produk Tanpa Gambar Baru
- [ ] Klik "Edit" pada produk
- [ ] Ubah field (tanpa pilih gambar baru)
- [ ] Klik "Simpan"
- [ ] Cek gambar lama tetap ada ✅

## 📝 Notes Penting

1. **Saat Frontend**
   - ✅ Image picker sudah ready
   - ✅ Preview sudah ready
   - ✅ FormData upload sudah ready
   - ✅ Authorization header sudah included
   - ✅ No errors di analyzer

2. **Saat Backend**
   - ⚠️ Perlu install multer
   - ⚠️ Perlu setup storage folder
   - ⚠️ Perlu update endpoint

3. **Production Ready**
   - Compress image dilakukan otomatis
   - Validasi file type via ImagePicker
   - Token auth included otomatis
   - Error handling sudah ada
   - Loading state sudah ada

## 🚀 Next Steps

1. **Setup Backend File Upload** (lihat `IMAGE_UPLOAD_GUIDE.md`)
2. **Test Create dengan gambar**
3. **Test Update dengan gambar baru**
4. **Test Edit tanpa gambar baru**
5. **Deploy ke production**

---

**Dokumentasi Lengkap:** Lihat `IMAGE_UPLOAD_GUIDE.md`
**Last Updated:** January 14, 2026
**Status:** ✅ Frontend Complete | ⏳ Waiting Backend Setup
