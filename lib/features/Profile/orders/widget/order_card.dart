
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/order_item.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../order_viewmodel.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final OrderListViewModel viewModel;

  const OrderCard({
    Key? key,
    required this.order,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => viewModel.showOrderTimeline(order),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => viewModel.showOrderTimeline(order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Details",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    " ${order.status}",
                    style: const TextStyle(fontSize: 14, color: kcOrangeColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildOrderActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "#${order.orderNumber}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Quantity: ${order.quantity}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              "Tracking: ${order.trackingNumber}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            verticalSpaceSmall,
            Text(
              "Total: ${MoneyUtils().formatAmount(order.totalPrice)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        Text(
          DateFormat("d MMM, yyyy").format(order.createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOrderActions(BuildContext context) {
    List<Widget> actions = [];

    final isInvoiceOrder = order.orderType == 'InstantPayment';
    final isDeliveryOrder = order.orderType == 'PayOnDelivery';

    if (order.status == 'Pending') {
      actions.add(_infoChip(
        icon: Icons.hourglass_top_rounded,
        color: Colors.amber,
        label: isDeliveryOrder
            ? 'Admin confirming delivery schedule…'
            : 'Admin reviewing items — invoice coming soon',
      ));
    } else if (order.status == 'Processing') {
      if (isInvoiceOrder) {
        actions.add(_infoChip(
          icon: Icons.email_rounded,
          color: Colors.blue,
          label: 'Invoice sent to your email — pay via bank transfer',
        ));
      } else if (isDeliveryOrder) {
        actions.add(_infoChip(
          icon: Icons.local_shipping_rounded,
          color: Colors.green,
          label: 'Delivery scheduled — our team will contact you',
        ));
      }
    } else if (order.status == 'Cancelled') {
      actions.add(
        ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text('Cancelled'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            disabledForegroundColor: Colors.white,
          ),
        ),
      );
    } else if (order.status == 'Completed' || order.status == 'Delivered') {
      actions.add(
        ElevatedButton.icon(
          onPressed: () => viewModel.leaveReview(order),
          icon: const Icon(Icons.star, size: 16),
          label: const Text('Leave Review'),
          style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor),
        ),
      );
    }

    return actions.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: actions
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: e,
                    ))
                .toList(),
          )
        : const SizedBox();
  }

  Widget _infoChip({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.85)),
            ),
          ),
        ],
      ),
    );
  }
}