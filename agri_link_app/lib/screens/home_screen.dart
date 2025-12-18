import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'order_approval_screen.dart';
import 'weather_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // ✅ hindari setState / notifyListeners saat build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final productProvider = context.read<ProductProvider>();
    final cartProvider = context.read<CartProvider>();

    await productProvider.fetchCategories();
    await productProvider.fetchProducts();
    await cartProvider.fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isAdmin = authProvider.currentUser?.role == 'admin';
        final tabs = isAdmin
            ? const [
                _OrderApprovalTab(),
                _WeatherTab(),
                _ProfileTab(),
              ]
            : const [
                _HomeTab(),
                _OrdersTab(),
                _WeatherTab(),
                _ProfileTab(),
              ];
        
        return Scaffold(
          body: IndexedStack(
            index: _selectedTab,
            children: tabs,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: isAdmin
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment),
                      label: 'Pesanan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.cloud),
                      label: 'Cuaca',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ]
                : const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Beranda',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag),
                      label: 'Pesanan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.cloud),
                      label: 'Cuaca',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ],
          ),
        );
      },
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => __HomeTabState();
}

class __HomeTabState extends State<_HomeTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _retryLoadProducts() async {
    await context.read<ProductProvider>().fetchProducts();
  }

  // ✅ responsif: 1 card max lebar segini, sisanya auto nambah kolom
  double _maxCrossAxisExtentForWidth(double width) {
    if (width >= 1200) return 260;
    if (width >= 900) return 240;
    if (width >= 600) return 220;
    return 200;
  }

  // ✅ rasio card: sedikit lebih “tinggi” agar teks muat dan tidak overflow
  double _childAspectRatioForWidth(double width) {
    if (width >= 1200) return 0.78;
    if (width >= 900) return 0.75;
    if (width >= 600) return 0.72;
    return 0.68;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxExtent = _maxCrossAxisExtentForWidth(screenWidth);
    final ratio = _childAspectRatioForWidth(screenWidth);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.white,
        title: const Text('Agri-Link'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartProvider.totalItems > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartProvider.totalItems}',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppPadding.lg),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) async {
                      setState(() {}); // ✅ refresh suffix icon
                      if (value.isEmpty) {
                        await productProvider.fetchProducts();
                      } else {
                        await productProvider.fetchProducts(search: value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () async {
                                _searchController.clear();
                                setState(() {});
                                await productProvider.fetchProducts();
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Categories
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppPadding.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppPadding.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip(
                              label: 'Semua',
                              isSelected:
                                  productProvider.selectedCategory == null,
                              onTap: () async {
                                productProvider.setSelectedCategory(null);
                                await productProvider.fetchProducts();
                              },
                            ),
                            ...productProvider.categories.map((category) {
                              return _buildCategoryChip(
                                label: category,
                                isSelected: productProvider.selectedCategory ==
                                    category,
                                onTap: () async {
                                  productProvider.setSelectedCategory(category);
                                  await productProvider.fetchProducts(
                                      category: category);
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppPadding.lg),

                // Products Grid
                if (productProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppPadding.lg),
                    child: LoadingWidget(message: 'Memuat produk...'),
                  )
                else if (productProvider.products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    child: EmptyStateWidget(
                      title: 'Tidak Ada Produk',
                      message:
                          'Coba ubah filter atau cari dengan kata kunci lain',
                      icon: Icons.shopping_bag,
                      onRetry: _retryLoadProducts,
                    ),
                  )
                else
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppPadding.lg),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: maxExtent,
                        childAspectRatio: ratio,
                        crossAxisSpacing: AppPadding.lg,
                        mainAxisSpacing: AppPadding.lg,
                      ),
                      itemCount: productProvider.products.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.products[index];
                        return ProductCard(
                          productId: product.id,
                          imageUrl: product.imageUrl,
                          productName: product.name,
                          supplierName: product.adminName,
                          price: product.price,
                          stock: product.stock,
                          unit: product.unit,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(productId: product.id),
                              ),
                            );
                          },
                          onAddToCart: () {
                            _showAddToCartDialog(product);
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: AppPadding.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppPadding.md),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppTheme.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.white : AppTheme.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showAddToCartDialog(dynamic product) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Harga: Rp${product.price.toStringAsFixed(0)}'),
              const SizedBox(height: AppPadding.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed:
                        quantity > 1 ? () => setState(() => quantity--) : null,
                  ),
                  Text(quantity.toString(),
                      style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: quantity < product.stock
                        ? () => setState(() => quantity++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final cartProvider = context.read<CartProvider>();
                final success = await cartProvider.addToCart(
                  productId: product.id,
                  quantity: quantity,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Ditambahkan ke keranjang'
                            : 'Gagal menambahkan ke keranjang',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return const OrdersScreen();
  }
}

class _OrderApprovalTab extends StatelessWidget {
  const _OrderApprovalTab();

  @override
  Widget build(BuildContext context) {
    return const OrderApprovalScreen();
  }
}

class _WeatherTab extends StatelessWidget {
  const _WeatherTab();

  @override
  Widget build(BuildContext context) {
    return const WeatherScreen();
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
