
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../features/Profile/orders/order_viewmodel.dart';
import '../../../features/Profile/orders/widget/order_status_timelime_details.dart';
import 'order_status_timelinemodel.dart';

class OrderStatusTimelineSheet extends StackedView<OrderStatusTimelineModel> {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const OrderStatusTimelineSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  @override
  Widget builder(
      BuildContext context,
      OrderStatusTimelineModel viewModel,
      Widget? child,
      ) {
    // The OrderStatus is passed through the request data
    final OrderStatus currentStatus = request.data as OrderStatus;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        // We use the new OrderStatusTimeline widget to build the content
        return OrderStatusTimeline(
          currentStatus: currentStatus,
          scrollController: scrollController,
        );
      },
    );
  }

  @override
  OrderStatusTimelineModel viewModelBuilder(BuildContext context) => OrderStatusTimelineModel();
}