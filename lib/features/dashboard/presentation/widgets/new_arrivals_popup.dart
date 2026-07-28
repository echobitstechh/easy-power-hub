import 'package:flutter/material.dart';

import '../../../../core/data/models/product.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../ui/common/app_colors.dart';
import '../dashboard_viewmodel.dart';
import '../product_details/product_card.dart';

/// Shows up to 3 products newer than the last time this device saw the
/// catalog, matching web's "New Arrivals" nudge popup.
class NewArrivalsPopup extends StatelessWidget {
  final DashboardViewModel viewModel;

  const NewArrivalsPopup({super.key, required this.viewModel});

  static Future<void> show(BuildContext context, DashboardViewModel viewModel) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => NewArrivalsPopup(viewModel: viewModel),
    ).then((_) => viewModel.dismissNewArrivalsPopup());
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProductCard(product: product, dashboardViewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Arrivals!',
              style: TextStyle(fontFamily: 'HostGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Fresh items just added to the store.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            ...viewModel.newArrivals.map((product) => InkWell(
                  onTap: () => _openProduct(context, product),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (product.images?.isNotEmpty == true)
                              ? Image.network(
                                  product.images!.first,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 52,
                                    height: 52,
                                    color: Colors.grey[200],
                                  ),
                                )
                              : Container(
                                  width: 52,
                                  height: 52,
                                  color: Colors.grey[200],
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'HostGrotesk',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (product.brandName != null)
                                Text(
                                  product.brandName!,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                              Text(
                                MoneyUtils().formatAmount(
                                  (double.tryParse(product.salePrice ?? '0') ?? 0).toInt(),
                                ),
                                style: const TextStyle(fontFamily: 'Roboto',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kcSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Dismiss'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
