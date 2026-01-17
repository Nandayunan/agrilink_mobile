import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({Key? key}) : super(key: key);

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final authProvider = context.read<AuthProvider>();
    final productProvider = context.read<ProductProvider>();
    await productProvider.fetchProductsByAdmin(authProvider.currentUser!.id);
  }

  void _showProductForm({Map<String, dynamic>? product}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final descriptionController = TextEditingController(
      text: product?['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: product?['price'].toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?['stock'].toString() ?? '',
    );
    final unitController = TextEditingController(
      text: product?['unit'] ?? 'kg',
    );
    String selectedCategory = product?['category'] ?? 'Sayuran';
    XFile? selectedImageXFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview & Picker
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: selectedImageXFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: kIsWeb
                              ? Image.network(
                                  selectedImageXFile!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(selectedImageXFile!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : product?['imageUrl'] != null &&
                              product!['imageUrl'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Image.network(
                                product['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image_not_supported,
                                        color: AppTheme.textGray,
                                      ),
                                      const SizedBox(height: AppPadding.sm),
                                      const Text(
                                        'Pilih gambar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textGray,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_not_supported,
                                  color: AppTheme.textGray,
                                ),
                                const SizedBox(height: AppPadding.sm),
                                const Text(
                                  'Pilih gambar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                ),
                const SizedBox(height: AppPadding.md),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        selectedImageXFile = image;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Gambar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    hintText: 'Contoh: Tomat Segar',
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Deskripsi produk',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppPadding.lg),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: [
                    'Sayuran',
                    'Buah',
                    'Beras',
                    'Daging',
                    'Telur',
                    'Susu',
                    'Lainnya'
                  ]
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => selectedCategory = value ?? 'Sayuran',
                ),
                const SizedBox(height: AppPadding.lg),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Unit',
                    hintText: 'Contoh: 15000',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    hintText: 'Contoh: 100',
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    hintText: 'Contoh: kg, pcs, liter',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final productProvider = context.read<ProductProvider>();

                // Convert XFile to File untuk keduanya (Web dan Mobile)
                File? imageFile;
                if (selectedImageXFile != null) {
                  imageFile = File(selectedImageXFile!.path);
                }

                if (product == null) {
                  // Create
                  await productProvider.createProduct(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    unit: unitController.text,
                    category: selectedCategory,
                    imageFile: imageFile,
                  );
                } else {
                  // Update
                  await productProvider.updateProduct(
                    productId: product['id'],
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    unit: unitController.text,
                    category: selectedCategory,
                    imageFile: imageFile,
                  );
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        product == null
                            ? 'Produk berhasil ditambahkan!'
                            : 'Produk berhasil diperbarui!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(product == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final productProvider = context.read<ProductProvider>();
      await productProvider.deleteProduct(productId);
      if (mounted) {
        _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Kelola Produk',
        showBackButton: false,
      ),
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const LoadingWidget(message: 'Memuat produk...');
          }

          if (productProvider.products.isEmpty) {
            return EmptyStateWidget(
              title: 'Belum Ada Produk',
              message: 'Mulai tambahkan produk untuk dijual',
              icon: Icons.inventory_2,
              onRetry: _loadProducts,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppPadding.lg),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppPadding.lg),
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          product.imageUrl.isEmpty
                              ? Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: AppTheme.textLight,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: AppTheme.textLight,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          const SizedBox(width: AppPadding.lg),
                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppPadding.sm),
                                Text(
                                  product.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                                const SizedBox(height: AppPadding.md),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppFormatter.formatCurrency(
                                        product.price,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppPadding.md,
                                        vertical: AppPadding.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: product.stock > 0
                                            ? AppTheme.successColor
                                                .withOpacity(0.1)
                                            : AppTheme.errorColor
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                      ),
                                      child: Text(
                                        'Stok: ${product.stock} ${product.unit}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: product.stock > 0
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Description
                      if (product.description.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deskripsi:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGray,
                              ),
                            ),
                            const SizedBox(height: AppPadding.sm),
                            Text(
                              product.description,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: AppPadding.lg),
                          ],
                        ),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _showProductForm(product: {
                                  'id': product.id,
                                  'name': product.name,
                                  'description': product.description,
                                  'price': product.price,
                                  'stock': product.stock,
                                  'unit': product.unit,
                                  'category': product.category,
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                              ),
                              child: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: AppPadding.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _deleteProduct(product.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                              ),
                              child: const Text('Hapus'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
