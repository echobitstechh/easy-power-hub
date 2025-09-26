
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/order_item.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../ui/common/app_colors.dart';
import '../../../../ui/common/ui_helpers.dart';
import '../../../../ui/components/submit_button.dart';
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

    if (order.isPaid == false && order.status != "Cancelled" && order.status != "Completed") {
      actions.add(
        SubmitButton(
          isLoading: false,
          label: "Make Payment",
          submit: () => viewModel.makePayment( context, order),
          boldText: true,
          color: kcPrimaryColor,
        ),
      );
    }

    if (order.status == "Cancelled") {
      actions.add(
        ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text("Cancelled"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            disabledForegroundColor: Colors.white,
          ),
        ),
      );
    }

    if (order.status == "Completed") {
      actions.add(
        ElevatedButton.icon(
          onPressed: () => viewModel.leaveReview(order),
          icon: const Icon(Icons.star, size: 16),
          label: const Text("Leave Review"),
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
}