import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final int supplierId;
  final List<dynamic> items;

  const CheckoutScreen({super.key, required this.supplierId, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  double _discountPercentage = 0;
  double _serviceFee = 0;
  double _taxPercentage = 10;
  bool _isSubmitting = false;

  double get _subtotal {
    return widget.items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _discountAmount {
    return (_subtotal * _discountPercentage) / 100;
  }

  double get _taxAmount {
    return ((_subtotal - _discountAmount) * _taxPercentage) / 100;
  }

  double get _grandTotal {
    return _subtotal - _discountAmount + _taxAmount + _serviceFee;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final orderProvider = context.read<OrderProvider>();
      final cartProvider = context.read<CartProvider>();
      final items = widget.items
          .map(
            (item) => {'product_id': item.productId, 'quantity': item.quantity},
          )
          .toList();

      final success = await orderProvider.createOrder(
        adminId: widget.supplierId,
        items: items,
        discountPercentage: _discountPercentage,
        serviceFee: _serviceFee,
        taxPercentage: _taxPercentage,
        deliveryAddress: _addressController.text,
        deliveryDate: _selectedDate,
        notes: _notesController.text,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (success) {
          // Clear cart items for this supplier
          await cartProvider.clearCartBySupplier(widget.supplierId);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil dibuat!')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${orderProvider.error}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Checkout'),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppPadding.lg),
                        ...widget.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppPadding.md,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName),
                                      Text(
                                        '${item.quantity} x Rp${item.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppFormatter.formatCurrency(item.subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                // Delivery Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Pengiriman',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppPadding.lg),
                        // Delivery Address
                        TextFormField(
                          controller: _addressController,
                          validator: AppValidator.validateAddress,
                          decoration: const InputDecoration(
                            labelText: 'Alamat Pengiriman',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppPadding.lg),
                        // Delivery Date
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(AppPadding.lg),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderColor),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: AppPadding.lg),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tanggal Pengiriman',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                    Text(
                                      AppFormatter.formatDate(_selectedDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppPadding.lg),
                        // Notes
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan (Opsional)',
                            hintText: 'Contoh: Jangan ketinggalan...',
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                // Charges
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Biaya Tambahan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppPadding.lg),
                        // Discount Percentage
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Diskon (%)'),
                                  const SizedBox(height: AppPadding.sm),
                                  TextFormField(
                                    initialValue: '0',
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        _discountPercentage =
                                            double.tryParse(value) ?? 0;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppPadding.md,
                                        vertical: AppPadding.md,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppPadding.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pajak (%)'),
                                  const SizedBox(height: AppPadding.sm),
                                  TextFormField(
                                    initialValue: '10',
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        _taxPercentage =
                                            double.tryParse(value) ?? 0;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppPadding.md,
                                        vertical: AppPadding.md,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppPadding.lg),
                        // Service Fee
                        Row(
                          children: [
                            const Text('Biaya Layanan (Rp)'),
                            const SizedBox(width: AppPadding.md),
                            Expanded(
                              child: TextFormField(
                                initialValue: '0',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _serviceFee = double.tryParse(value) ?? 0;
                                  });
                                },
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.md,
                                    vertical: AppPadding.md,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                // Price Breakdown
                PriceBreakdownWidget(
                  subtotal: _subtotal,
                  discountPercentage: _discountPercentage,
                  serviceFee: _serviceFee,
                  taxPercentage: _taxPercentage,
                ),
                const SizedBox(height: AppPadding.lg),
                // Submit Button
                CustomButton(
                  label:
                      'Pesan Sekarang - ${AppFormatter.formatCurrency(_grandTotal)}',
                  onPressed: _submitOrder,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: AppPadding.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
