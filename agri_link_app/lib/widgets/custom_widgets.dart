import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final double elevation;

  const CustomAppBar({
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: AppTheme.white,
      title: Text(title),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class ProductCard extends StatelessWidget {
  final int productId;
  final String imageUrl;
  final String productName;
  final String supplierName;
  final double price;
  final int stock;
  final String unit;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.productName,
    required this.supplierName,
    required this.price,
    required this.stock,
    required this.unit,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Bagian gambar fleksibel (aman untuk berbagai ukuran grid)
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                color: AppTheme.backgroundColor,
                child: imageUrl.isEmpty
                    ? Icon(Icons.image_not_supported, color: AppTheme.textLight)
                    : Image.network(
                        imageUrl,
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

            // ✅ Bagian detail fleksibel & anti-overflow
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplierName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textGray,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp${price.toStringAsFixed(0)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'per $unit',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onAddToCart != null) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: ElevatedButton(
                              onPressed: onAddToCart,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: AppTheme.white,
                                shape: const CircleBorder(),
                                elevation: 2,
                              ),
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height ?? 48),
          side: BorderSide(color: textColor ?? AppTheme.primaryColor),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: textColor ?? AppTheme.white,
        minimumSize: Size(width ?? double.infinity, height ?? 48),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;

  const EmptyStateWidget({
    required this.title,
    required this.message,
    this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.inbox, size: 64, color: AppTheme.textLight),
          const SizedBox(height: AppPadding.lg),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppPadding.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textGray, fontSize: 14),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppPadding.lg),
            CustomButton(label: 'Coba Lagi', onPressed: onRetry!, width: 150),
          ],
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          if (message != null) ...[
            const SizedBox(height: AppPadding.lg),
            Text(message!),
          ],
        ],
      ),
    );
  }
}

class PriceBreakdownWidget extends StatelessWidget {
  final double subtotal;
  final double discountPercentage;
  final double serviceFee;
  final double taxPercentage;

  const PriceBreakdownWidget({
    required this.subtotal,
    required this.discountPercentage,
    required this.serviceFee,
    required this.taxPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final discountAmount = (subtotal * discountPercentage) / 100;
    final taxAmount = ((subtotal - discountAmount) * taxPercentage) / 100;
    final grandTotal = subtotal - discountAmount + taxAmount + serviceFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.lg),
        child: Column(
          children: [
            _buildRow('Subtotal', subtotal),
            if (discountPercentage > 0) ...[
              const SizedBox(height: AppPadding.md),
              _buildRow(
                'Diskon (${discountPercentage.toStringAsFixed(0)}%)',
                -discountAmount,
                color: AppTheme.successColor,
              ),
            ],
            if (taxPercentage > 0) ...[
              const SizedBox(height: AppPadding.md),
              _buildRow(
                'Pajak (${taxPercentage.toStringAsFixed(0)}%)',
                taxAmount,
              ),
            ],
            if (serviceFee > 0) ...[
              const SizedBox(height: AppPadding.md),
              _buildRow('Biaya Layanan', serviceFee),
            ],
            const Divider(height: 24),
            _buildRow(
              'Total',
              grandTotal,
              isBold: true,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    double amount, {
    bool isBold = false,
    Color color = AppTheme.textDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          'Rp${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
