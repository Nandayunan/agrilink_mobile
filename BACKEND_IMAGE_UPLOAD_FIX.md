# ✅ Backend Image Upload - SUDAH DIPERBAIKI

## 🔴 Masalah yang Terjadi
Ketika user upload gambar via Flutter app, data masuk ke database tapi `image_url` selalu NULL. 

**Penyebab:** Backend tidak di-setup untuk handle file upload (multipart/form-data).

## 🟢 Solusi yang Diterapkan

### 1. **server.js - Setup Multer**
```javascript
// ✅ Ditambahkan:
- const multer = require('multer');
- const path = require('path');
- const fs = require('fs');

// Setup folder uploads/products
// Setup multer storage dengan filename unik
// Setup file filter (hanya image: jpeg, jpg, png, gif)
// Maksimal ukuran 5MB
// app.use('/uploads', express.static('uploads'));
// app.locals.upload = upload;
```

### 2. **products.js - Update Create Endpoint**
```javascript
// SEBELUM (hanya accept JSON):
router.post('/', verifyToken, verifyAdminRole, async (req, res) => {
    const { image_url } = req.body; // ❌ Tidak bisa receive file
}

// SESUDAH (handle multipart form-data):
router.post('/', verifyToken, verifyAdminRole, (req, res, next) => {
    const upload = req.app.locals.upload;
    upload.single('image')(req, res, async (err) => {
        // ✅ File disimpan di uploads/products/
        // ✅ image_url di-generate automatic
        let imageUrl = req.file 
            ? `http://localhost:5000/uploads/products/${req.file.filename}`
            : null;
    });
}
```

### 3. **products.js - Update PUT Endpoint**
```javascript
// ✅ Sama seperti POST
// ✅ Jika user upload image baru, replace lama
// ✅ Jika tidak upload, keep image lama
```

## 📁 Struktur File

```
agri_link_backend/
├── server.js                    (✅ Updated)
├── routes/
│   └── products.js              (✅ Updated)
├── uploads/
│   └── products/                (📁 Auto created)
│       ├── product-1705...jpg
│       ├── product-1705...png
│       └── ...
├── package.json
└── .env
```

## ✨ Fitur Lengkap Sekarang

### Frontend (Flutter) ✅
- ✅ Image picker dari galeri
- ✅ Preview gambar sebelum submit
- ✅ Support Web dan Mobile
- ✅ Auto compress (quality 80)

### Backend (Node.js) ✅
- ✅ Multer setup untuk file upload
- ✅ Validasi file type (image only)
- ✅ Validasi file size (max 5MB)
- ✅ Auto filename generation
- ✅ Static file serving di /uploads

### Database ✅
- ✅ Simpan image_url di products table
- ✅ URL format: `http://localhost:5000/uploads/products/product-xxxxx.jpg`

## 🧪 Testing

### 1. Bersihkan Data Lama (Optional)
```sql
DELETE FROM products WHERE image_url IS NULL OR image_url = '';
```

### 2. Jalankan Backend
```bash
cd agri_link_backend
npm start
```

### 3. Jalankan Flutter App
```bash
cd agri_link_app
flutter run -d chrome
```

### 4. Test Flow
1. Buka "Kelola Produk"
2. Klik "Tambah Produk"
3. Klik "Pilih Gambar" → Pilih gambar JPG/PNG
4. Preview akan muncul
5. Isi form produk (nama, harga, stok, dll)
6. Klik "Tambah"
7. Cek database → image_url seharusnya terisi URL
8. Gambar seharusnya bisa diakses di `http://localhost:5000/uploads/products/product-xxxxx.jpg`

## 🐛 Troubleshooting

### Gambar tidak terupload
1. ✅ Cek backend server running
2. ✅ Cek console backend untuk error
3. ✅ Cek ukuran file (max 5MB)
4. ✅ Cek format (hanya jpg, png, gif)

### 404 saat akses image
1. ✅ Cek folder `uploads/products/` ada
2. ✅ Cek file ada di folder tersebut
3. ✅ Cek base URL di frontend (localhost:5000)

### Database masih NULL
1. ✅ Pastikan backend sudah restart
2. ✅ Cek multer middleware terload
3. ✅ Cek network tab di DevTools

## 📝 Files yang Diubah
- ✅ `agri_link_backend/server.js`
- ✅ `agri_link_backend/routes/products.js`
- ✅ `agri_link_app/lib/screens/farmer_products_screen.dart` (sebelumnya)
- ✅ `agri_link_app/lib/services/api_service.dart` (sebelumnya)
- ✅ `agri_link_app/lib/providers/product_provider.dart` (sebelumnya)

## ✅ Next Steps
1. Restart backend server
2. Test create product dengan gambar
3. Cek database image_url sudah terisi
4. Verify gambar bisa di-preview di product list
5. Test edit product (ganti gambar lama dengan baru)

---
**Status:** Backend Image Upload = ✅ COMPLETE
**Last Updated:** January 14, 2026
