import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Keranjang Belanja'),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isLoading) {
            return const LoadingWidget(message: 'Memuat keranjang...');
          }

          if (cartProvider.cartItems.isEmpty) {
            return EmptyStateWidget(
              title: 'Keranjang Kosong',
              message: 'Silakan tambahkan produk untuk mulai berbelanja',
              icon: Icons.shopping_cart,
              onRetry: _loadCart,
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Grouped by Supplier
                ...cartProvider.groupedBySupplier.entries.map((entry) {
                  final supplierId = entry.key;
                  final items = entry.value;
                  final supplier = items.first;
                  final subtotal = items.fold(
                    0.0,
                    (sum, item) => sum + item.subtotal,
                  );

                  return Card(
                    margin: const EdgeInsets.all(AppPadding.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Supplier Header
                        Container(
                          padding: const EdgeInsets.all(AppPadding.lg),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppRadius.lg),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.store,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: AppPadding.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      supplier.companyName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      supplier.adminName,
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
                        ),
                        // Cart Items
                        ...items.map((item) {
                          return _buildCartItem(context, item);
                        }).toList(),
                        // Subtotal
                        Container(
                          padding: const EdgeInsets.all(AppPadding.lg),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppTheme.borderColor),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal Supplier',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                AppFormatter.formatCurrency(subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Checkout Button for this Supplier
                        Padding(
                          padding: const EdgeInsets.all(AppPadding.lg),
                          child: CustomButton(
                            label: 'Pesan dari Supplier Ini',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(
                                    supplierId: supplierId,
                                    items: items,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: AppPadding.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.lg),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: item.imageUrl.isEmpty
                ? Icon(Icons.image_not_supported, color: AppTheme.textLight)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: AppTheme.textLight,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(width: AppPadding.lg),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppPadding.sm),
                Text(
                  'Rp${item.price.toStringAsFixed(0)} per ${item.unit}',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                ),
                const SizedBox(height: AppPadding.md),
                // Quantity Controls
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: item.quantity > 1
                            ? () async {
                                await context
                                    .read<CartProvider>()
                                    .updateCartItem(
                                      cartId: item.id,
                                      quantity: item.quantity - 1,
                                    );
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppPadding.sm),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: AppPadding.sm),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () async {
                          await context.read<CartProvider>().updateCartItem(
                            cartId: item.id,
                            quantity: item.quantity + 1,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete Button
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () async {
                  await context.read<CartProvider>().removeFromCart(item.id);
                },
              ),
              Text(
                AppFormatter.formatCurrency(item.subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
