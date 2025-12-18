import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class OrderApprovalScreen extends StatefulWidget {
  const OrderApprovalScreen({Key? key}) : super(key: key);

  @override
  State<OrderApprovalScreen> createState() => _OrderApprovalScreenState();
}

class _OrderApprovalScreenState extends State<OrderApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['pending', 'confirmed', 'processing'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.fetchSupplierOrders();
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.updateOrderStatus(
      orderId: order.id,
      status: newStatus,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${orderProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Kelola Pesanan'),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textGray,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: 'Pending (${_getPendingCount(context)})'),
              Tab(text: 'Dikonfirmasi (${_getConfirmedCount(context)})'),
              Tab(text: 'Diproses (${_getProcessingCount(context)})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(context, 'pending'),
                _buildOrderList(context, 'confirmed'),
                _buildOrderList(context, 'processing'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getPendingCount(BuildContext context) {
    final orders = context
        .watch<OrderProvider>()
        .orders
        .where((o) => o.status == 'pending')
        .length;
    return orders;
  }

  int _getConfirmedCount(BuildContext context) {
    final orders = context
        .watch<OrderProvider>()
        .orders
        .where((o) => o.status == 'confirmed')
        .length;
    return orders;
  }

  int _getProcessingCount(BuildContext context) {
    final orders = context
        .watch<OrderProvider>()
        .orders
        .where((o) => o.status == 'processing')
        .length;
    return orders;
  }

  Widget _buildOrderList(BuildContext context, String status) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        if (orderProvider.isLoading) {
          return const LoadingWidget(message: 'Memuat pesanan...');
        }

        final filteredOrders =
            orderProvider.orders.where((o) => o.status == status).toList();

        if (filteredOrders.isEmpty) {
          return EmptyStateWidget(
            title: 'Tidak ada pesanan',
            message: 'Tidak ada pesanan dengan status $status',
            icon: Icons.shopping_bag,
            onRetry: _loadOrders,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppPadding.lg),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _buildOrderCard(context, order);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppPadding.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppPadding.lg),
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
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
                    const Text(
                      'Dari: Pelanggan',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          // Customer Info
          Padding(
            padding: const EdgeInsets.all(AppPadding.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Pelanggan', order.adminName),
                _buildInfoRow('Alamat Pengiriman', order.deliveryAddress),
                _buildInfoRow(
                  'Tanggal Pengiriman',
                  AppFormatter.formatDate(order.deliveryDate),
                ),
                const SizedBox(height: AppPadding.md),
                const Divider(),
                const SizedBox(height: AppPadding.md),
                // Items
                _buildOrderItemsList(order),
                const SizedBox(height: AppPadding.md),
                const Divider(),
                const SizedBox(height: AppPadding.md),
                // Price Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    Text(
                      AppFormatter.formatCurrency(order.grandTotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          if (order.status == 'pending')
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Tolak',
                      onPressed: () {
                        _showRejectDialog(context, order);
                      },
                      backgroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: AppPadding.md),
                  Expanded(
                    child: CustomButton(
                      label: 'Terima',
                      onPressed: () {
                        _updateOrderStatus(order, 'confirmed');
                      },
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            )
          else if (order.status == 'confirmed')
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: CustomButton(
                label: 'Mulai Proses',
                onPressed: () {
                  _updateOrderStatus(order, 'processing');
                },
              ),
            )
          else if (order.status == 'processing')
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: CustomButton(
                label: 'Tandai Dikirim',
                onPressed: () {
                  _updateOrderStatus(order, 'shipped');
                },
                backgroundColor: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    String label;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange;
        label = 'Menunggu';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue;
        label = 'Dikonfirmasi';
        break;
      case 'processing':
        backgroundColor = Colors.purple;
        label = 'Diproses';
        break;
      case 'shipped':
        backgroundColor = Colors.indigo;
        label = 'Dikirim';
        break;
      case 'delivered':
        backgroundColor = Colors.green;
        label = 'Terserah';
        break;
      default:
        backgroundColor = Colors.grey;
        label = 'Tidak Diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppPadding.sm),
        ...order.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity}x ${item.productName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Text(
                  AppFormatter.formatCurrency(item.subtotal),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showRejectDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pesanan'),
        content: const Text('Apakah Anda yakin ingin menolak pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order, 'cancelled');
            },
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );
  }
}
