import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_ph/ui/common/app_colors.dart';
import 'package:easy_ph/ui/common/ui_helpers.dart';
import '../../../../core/data/models/favourite.dart';
import '../../../../core/utils/money_util.dart';
import '../favourite_bottomsheet_viewmodel.dart';

class FavouriteCard extends StatelessWidget {
  final FavoriteItem favoriteItem;
  final FavoritesBottomSheetModel viewModel;

  const FavouriteCard({
    super.key,
    required this.favoriteItem,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: favoriteItem.product.images?.first ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            horizontalSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favoriteItem.product.productName ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpaceTiny,
                  Text(
                    MoneyUtils().formatAmount(
                      (double.tryParse(favoriteItem.product.salePrice ?? '0') ?? 0).toInt(),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: kcPrimaryColor),
                  onPressed: () {
                    viewModel.addProductToCart(favoriteItem.product);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.removeFavorite(favoriteItem.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}