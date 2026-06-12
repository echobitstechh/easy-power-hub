
import 'package:easy_ph/features/dashboard/presentation/widgets/product_grid_item.dart';
import 'package:easy_ph/features/shop/shop_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../dashboad_view.dart';
import '../dashboard_viewmodel.dart';

class PopularProductsSection extends StatelessWidget {
  final DashboardViewModel viewModel;

  const PopularProductsSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 20),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.75,
          ),
          itemCount: viewModel.productList.length,
          itemBuilder: (context, index) {
            final item = viewModel.productList[index];
            // Use the extracted ProductGridItem widget for cleaner code
            return ProductGridItem(
              product: item,
              viewModel: viewModel,
            );
          },
        ),
      ],
    );
  }
}