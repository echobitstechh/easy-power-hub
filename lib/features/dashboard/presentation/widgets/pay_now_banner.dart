import 'package:flutter/material.dart';

import '../../../../core/utils/money_util.dart';
import '../dashboard_viewmodel.dart';

import '../../../../state.dart' as appState;

/// Dismissible floating reminder shown when the customer has an approved
/// (Processing) InstantPayment order that hasn't been paid for yet.
class PayNowBanner extends StatelessWidget {
  final DashboardViewModel viewModel;

  const PayNowBanner({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.payNowOrder,
      builder: (context, globalOrder, _) {
        return ValueListenableBuilder(
          valueListenable: appState.dismissedPayNowId,
          builder: (context, dismissedId, _) {
            if (!viewModel.showPayNowBanner) return const SizedBox.shrink();
            final order = viewModel.payNowOrder;
            if (order == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Order #${order.orderNumber} Approved',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Pay ${MoneyUtils().formatAmount(order.totalPrice)} to process delivery',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => viewModel.payNowForBannerOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                    padding: const EdgeInsets.only(left: 4),
                    constraints: const BoxConstraints(),
                    onPressed: viewModel.dismissPayNowBanner,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
