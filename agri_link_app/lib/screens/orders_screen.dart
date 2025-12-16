import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.fetchOrders(
      status: _selectedStatus == 'all' ? null : _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Pesanan Saya', showBackButton: false),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Status Filter
                Padding(
                  padding: const EdgeInsets.all(AppPadding.lg),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusChip('Semua', 'all'),
                        _buildStatusChip('Pending', 'pending'),
                        _buildStatusChip('Confirmed', 'confirmed'),
                        _buildStatusChip('Dikirim', 'shipped'),
                        _buildStatusChip('Terima', 'delivered'),
                      ],
                    ),
                  ),
                ),
                // Orders List
                if (orderProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppPadding.lg),
                    child: LoadingWidget(message: 'Memuat pesanan...'),
                  )
                else if (orderProvider.orders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    child: EmptyStateWidget(
                      title: 'Tidak Ada Pesanan',
                      message: 'Mulai berbelanja sekarang',
                      icon: Icons.shopping_bag,
                      onRetry: _loadOrders,
                    ),
                  )
                else
                  ...orderProvider.orders.map((order) {
                    return _buildOrderCard(order);
                  }).toList(),
                const SizedBox(height: AppPadding.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: AppPadding.md),
      child: FilterChip(
        label: Text(label),
        selected: _selectedStatus == value,
        onSelected: (_) {
          setState(() {
            _selectedStatus = value;
          });
          _loadOrders();
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.lg,
        vertical: AppPadding.md,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppPadding.sm),
                      Text(
                        AppFormatter.formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGray,
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
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      _getStatusLabel(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppPadding.lg),
              // Supplier Info
              Row(
                children: [
                  const Icon(
                    Icons.store,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: AppPadding.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.companyName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          order.adminName,
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
              // Items Count
              Text(
                '${order.items.length} item(s)',
                style: TextStyle(fontSize: 12, color: AppTheme.textGray),
              ),
              const SizedBox(height: AppPadding.lg),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AppFormatter.formatCurrency(order.grandTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'confirmed':
      case 'processing':
      case 'shipped':
        return AppTheme.infoColor;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textGray;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Diterima';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
