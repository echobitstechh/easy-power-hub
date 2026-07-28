import 'package:flutter/material.dart';

import '../../../../core/utils/money_util.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../dashboard_viewmodel.dart';

/// Dismissible reminder shown when the customer has an approved
/// (Processing) InstantPayment order that hasn't been paid for yet.
class PayNowBanner extends StatelessWidget {
  final DashboardViewModel viewModel;

  const PayNowBanner({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (!viewModel.showPayNowBanner) return const SizedBox.shrink();
    final order = viewModel.payNowOrder!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
          horizontalSpaceSmall,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #${order.orderNumber} approved",
                  style: const TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Complete payment of ${MoneyUtils().formatAmount(order.totalPrice)} to get it moving.",
                  style: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
                ),
                verticalSpaceSmall,
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => viewModel.payNowForBannerOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Pay Now', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: viewModel.dismissPayNowBanner,
          ),
        ],
      ),
    );
  }
}
