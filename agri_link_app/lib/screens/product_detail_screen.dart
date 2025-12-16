import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.fetchProductById(widget.productId);
  }

  Future<void> _addToCart() async {
    final cartProvider = context.read<CartProvider>();
    final product = context.read<ProductProvider>().selectedProduct;

    if (product == null) return;

    final success = await cartProvider.addToCart(
      productId: product.id,
      quantity: _quantity,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Produk ditambahkan ke keranjang'
                : 'Gagal menambahkan ke keranjang',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Detail Produk'),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const LoadingWidget(message: 'Memuat detail produk...');
          }

          final product = productProvider.selectedProduct;
          if (product == null) {
            return EmptyStateWidget(
              title: 'Produk Tidak Ditemukan',
              message: 'Silakan coba kembali',
              onRetry: _loadProductDetail,
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: double.infinity,
                  height: 300,
                  color: AppTheme.white,
                  child: product.imageUrl.isEmpty
                      ? Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: AppTheme.textLight,
                        )
                      : Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: AppTheme.textLight,
                            );
                          },
                        ),
                ),
                const SizedBox(height: AppPadding.lg),
                // Product Info
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppPadding.sm),
                      // Supplier Info
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: AppPadding.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.companyName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  product.adminName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Price Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppPadding.lg),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Harga per ${product.unit}',
                                    style: TextStyle(
                                      color: AppTheme.textGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: AppPadding.sm),
                                  Text(
                                    AppFormatter.formatCurrency(product.price),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.md,
                                  vertical: AppPadding.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: product.stock > 0
                                      ? AppTheme.successColor.withOpacity(0.1)
                                      : AppTheme.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: Text(
                                  'Stok: ${product.stock} ${product.unit}',
                                  style: TextStyle(
                                    color: product.stock > 0
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Description
                      Text(
                        'Deskripsi Produk',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppPadding.md),
                      Text(
                        product.description.isEmpty
                            ? 'Tidak ada deskripsi'
                            : product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGray,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppPadding.xxl),
                      // Quantity Selector
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppPadding.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jumlah Pesanan',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: AppPadding.lg),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: _quantity > 1
                                        ? () {
                                            setState(() => _quantity--);
                                          }
                                        : null,
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppPadding.md,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.borderColor,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                      ),
                                      child: Text(
                                        _quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: _quantity < product.stock
                                        ? () {
                                            setState(() => _quantity++);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Subtotal
                      Container(
                        padding: const EdgeInsets.all(AppPadding.lg),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              AppFormatter.formatCurrency(
                                product.price * _quantity,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Add to Cart Button
                      CustomButton(
                        label: 'Tambah ke Keranjang',
                        onPressed: product.stock > 0 ? () { _addToCart(); } : () {},
                        icon: Icons.shopping_cart,
                      ),
                      const SizedBox(height: AppPadding.lg),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
