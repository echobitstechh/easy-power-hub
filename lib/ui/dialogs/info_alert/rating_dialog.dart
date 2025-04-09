import 'package:easyph/ui/views/dashboard/dashboard_viewmodel.dart';
import 'package:easyph/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/models/product.dart';
import '../../../utils/money_util.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';


class RatingDialog extends StackedView<HomeViewModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const RatingDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      HomeViewModel viewModel,
      Widget? child,
      ) {
    final order = request.data;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7, // Set max height
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.cancel, color: Colors.black),
                  ),
                ),
                _buildOrderCard(order),
                const Text(
                  'Rate Your Experience',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                RatingBar.builder(
                  initialRating: viewModel.rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    viewModel.setRating(rating);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: viewModel.reviewController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write a review...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    viewModel.reviewRating(order);
                    completer(DialogResponse(confirmed: true));
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Product? product =
    order.products.isNotEmpty ? order.products.first : null;
    final imageUrl = product != null && product.images!.isNotEmpty
        ? product.images!.first
        : "https://via.placeholder.com/120";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(order),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(" ${order.status}",
                    style: const TextStyle(
                        fontSize: 14, color: kcOrangeColor)),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...order.products.map((product) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.images!.isNotEmpty
                      ? product.images!.first
                      : "https://via.placeholder.com/80",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.productName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 8),
        Text("Quantity: ${order.quantity}",
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text("Tracking: ${order.trackingNumber}",
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        verticalSpaceSmall,
        Text("Total: ${MoneyUtils().formatAmount(order.totalPrice as int)}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          DateFormat("d MMM, yyyy").format(order.createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
