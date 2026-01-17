# Panduan Image Upload untuk Produk Agri-Link

## 📋 Ringkasan
Fitur image upload telah diimplementasikan di flutter app dengan integrasi backend. Petani dapat memilih gambar dari galeri device saat membuat atau mengedit produk.

## ✅ Yang Sudah Diimplementasikan

### Frontend (Flutter)
1. **Import yang dibutuhkan**
   - `image_picker: ^1.0.0` - untuk memilih gambar dari galeri
   - `dio: ^5.2.0` - untuk upload file dengan FormData

2. **Fitur Tambahan di farmer_products_screen.dart**
   - Image picker dengan UI preview
   - Tombol "Pilih Gambar" di form
   - Preview gambar sebelum upload (dari file atau URL)
   - Support edit produk dengan image baru

3. **Update Provider (product_provider.dart)**
   - Menambah parameter `File? imageFile` di `createProduct()`
   - Menambah parameter `File? imageFile` di `updateProduct()`

4. **Update API Service (api_service.dart)**
   - Menggunakan Dio dengan FormData untuk multipart upload
   - Support parameter imageFile optional
   - Automatic token inclusion dalam header

### Backend (Node.js)
Saat ini backend sudah menerima field `image_url` sebagai string. Untuk implementasi lengkap file upload, perlu setup:

1. **Package yang dibutuhkan**
   ```bash
   npm install multer
   ```

2. **Setup folder uploads**
   ```bash
   mkdir -p uploads/products
   ```

## 🔧 Setup Backend untuk File Upload (BELUM DILAKUKAN)

### Step 1: Update server.js
```javascript
const multer = require('multer');
const path = require('path');

// Setup multer storage
const storage = multer.diskStorage({
    destination: 'uploads/products/',
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|gif/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);
        
        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb('Only image files are allowed');
        }
    }
});

app.use('/uploads', express.static('uploads'));

// Store upload middleware for use in routes
app.locals.upload = upload;
```

### Step 2: Update products.js Create Endpoint
```javascript
// Create Product (Admin only)
router.post('/', verifyToken, verifyAdminRole, req.app.locals.upload.single('image'), async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { category, name, description, price, stock, unit } = req.body;

        if (!category || !name || !price || !unit) {
            return res.status(400).json({
                success: false,
                message: 'Missing required fields',
                data: null
            });
        }

        // Generate image URL or use null if no image
        const imageUrl = req.file 
            ? `http://localhost:5000/uploads/products/${req.file.filename}`
            : null;

        const [result] = await pool.query(
            'INSERT INTO products (admin_id, category, name, description, price, stock, unit, image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [req.user.id, category, name, description, price, stock || 0, unit, imageUrl]
        );

        res.status(201).json({
            success: true,
            message: 'Product created successfully',
            data: {
                id: result.insertId,
                admin_id: req.user.id,
                category,
                name,
                description,
                price,
                stock,
                unit,
                image_url: imageUrl
            }
        });
    } catch (error) {
        console.error('Create product error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create product',
            data: null
        });
    }
});
```

### Step 3: Update products.js Update Endpoint
```javascript
// Update Product (Admin only)
router.put('/:productId', verifyToken, verifyAdminRole, req.app.locals.upload.single('image'), async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { productId } = req.params;
        const { category, name, description, price, stock, unit } = req.body;

        // Get existing product to preserve image if not updated
        const [existingProduct] = await pool.query(
            'SELECT image_url FROM products WHERE id = ?',
            [productId]
        );

        if (existingProduct.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Product not found',
                data: null
            });
        }

        // Use new image if provided, otherwise keep existing
        const imageUrl = req.file 
            ? `http://localhost:5000/uploads/products/${req.file.filename}`
            : existingProduct[0].image_url;

        await pool.query(
            'UPDATE products SET category = ?, name = ?, description = ?, price = ?, stock = ?, unit = ?, image_url = ? WHERE id = ?',
            [category, name, description, price, stock || 0, unit, imageUrl, productId]
        );

        const [updatedProduct] = await pool.query(
            'SELECT * FROM products WHERE id = ?',
            [productId]
        );

        res.status(200).json({
            success: true,
            message: 'Product updated successfully',
            data: updatedProduct[0]
        });
    } catch (error) {
        console.error('Update product error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update product',
            data: null
        });
    }
});
```

## 🎯 Cara Penggunaan dari Frontend

### Tambah Produk dengan Gambar
1. Buka halaman "Kelola Produk"
2. Klik tombol "+" (Tambah)
3. Klik tombol "Pilih Gambar"
4. Pilih gambar dari galeri (max 5MB)
5. Preview gambar akan muncul
6. Isi semua field produk
7. Klik "Tambah" untuk submit

### Edit Produk dengan Gambar Baru
1. Klik tombol "Edit" pada produk
2. Gambar lama akan tampil di preview
3. Klik "Pilih Gambar" untuk ganti gambar
4. Update field lainnya jika perlu
5. Klik "Simpan"

## 📝 Notes Penting

### Saat ini (Current State)
- ✅ Flutter UI sudah siap menerima file image
- ✅ API Service siap mengirim file dengan Dio FormData
- ✅ Product Provider sudah update untuk handle imageFile
- ❌ Backend file handling belum implementasi (masih accept image_url string)

### Untuk Lengkap Backend
1. Install `multer` di backend
2. Setup storage configuration
3. Update create dan update endpoints
4. Test dengan Postman atau ThunderClient

### Best Practices
- Maksimal ukuran file: 5MB
- Format yang diizinkan: JPG, PNG, GIF
- Validasi dilakukan di frontend (ImagePicker quality) dan backend (multer)
- Gambar lama akan diganti jika user upload baru saat edit

## 🧪 Testing

### Test Create dengan Image
```bash
curl -X POST http://localhost:5000/api/products \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "name=Tomat Segar" \
  -F "description=Tomat berkualitas bagus" \
  -F "price=15000" \
  -F "stock=100" \
  -F "unit=kg" \
  -F "category=Sayuran" \
  -F "image=@/path/to/image.jpg"
```

### Test Update dengan Image
```bash
curl -X PUT http://localhost:5000/api/products/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "name=Tomat Premium" \
  -F "description=Tomat premium berkualitas" \
  -F "price=18000" \
  -F "stock=80" \
  -F "unit=kg" \
  -F "category=Sayuran" \
  -F "image=@/path/to/new_image.jpg"
```

## 🐛 Troubleshooting

### Gambar tidak terupload
- Cek ukuran file (max 5MB)
- Pastikan format image valid (JPG, PNG, GIF)
- Check backend logs untuk error message

### Image picker tidak muncul
- Pastikan permission sudah set di AndroidManifest.xml (untuk Android)
- Pastikan permission sudah set di Info.plist (untuk iOS)

### 404 Image URL
- Pastikan folder `uploads/products/` exist di backend
- Pastikan base URL di ApiService benar
- Check file permissions di server

## 📚 File yang Diubah
1. `/lib/screens/farmer_products_screen.dart` - UI dengan image picker
2. `/lib/providers/product_provider.dart` - Tambah parameter imageFile
3. `/lib/services/api_service.dart` - Dio FormData untuk upload
4. `/pubspec.yaml` - Dependencies (image_picker, dio)

---
**Last Updated:** January 14, 2026
**Status:** Frontend Ready ✅ | Backend Partial ⚠️
