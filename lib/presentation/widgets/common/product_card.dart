import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/product.dart';

/// Reusable product card widget
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.showAddButton = true,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.all(AppSizes.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                const SizedBox(height: AppSizes.sm),
                _buildProductName(context),
                const SizedBox(height: AppSizes.xs),
                _buildMarketName(context),
                const SizedBox(height: AppSizes.sm),
                _buildPriceAndButton(context),
              ],
            ),
          ),
        ),
      );

  Widget _buildProductImage() => product.imageUrl != null
      ? ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          child: Image.network(
            product.imageUrl!,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
        )
      : _buildPlaceholder();

  Widget _buildProductName(BuildContext context) => Text(
        product.name,
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildMarketName(BuildContext context) => Text(
        product.market,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildPriceAndButton(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppUtils.formatCurrency(product.price),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.deepFern,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (showAddButton && onAddToCart != null)
            IconButton(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart),
              color: AppColors.tropicalLime,
            ),
        ],
      );

  Widget _buildPlaceholder() => Container(
        height: 120,
        width: double.infinity,
        color: AppColors.secondaryBackground,
        child: const Icon(
          Icons.image_not_supported,
          size: AppSizes.xl,
          color: AppColors.secondaryText,
        ),
      );
}
