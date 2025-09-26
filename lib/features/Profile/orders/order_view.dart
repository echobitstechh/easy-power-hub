
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import '../../../core/data/models/order_item.dart';
import '../../../ui/common/app_colors.dart';
import '../../../ui/components/empty_state.dart';
import 'widget/order_card.dart';
import 'order_viewmodel.dart';

class OrderList extends StackedView<OrderListViewModel> {
  const OrderList({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      OrderListViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.fetchOrders,
        child: viewModel.isBusy
            ? _buildShimmerLoading(context)
            : viewModel.allOrders.isEmpty
            ? const EmptyState(animation: "assets/animations/empty_order.json", label: "No Orders Yet")
            : DefaultTabController(
          length: 3,
          child: Column(
            children: [
              _buildTabBar(context, viewModel),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOrderList(viewModel.pendingOrders, viewModel),
                    _buildOrderList(viewModel.processingOrders, viewModel),
                    _buildOrderList(viewModel.completedOrders, viewModel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  OrderListViewModel viewModelBuilder(BuildContext context) => OrderListViewModel();

  @override
  void onViewModelReady(OrderListViewModel viewModel) {
    viewModel.fetchOrders();
  }
}

Widget _buildShimmerLoading(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
  final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: Column(
      children: [
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(5, (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ],
    ),
  );
}

Widget _buildTabBar(BuildContext context, OrderListViewModel viewModel) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? kcWhiteColor : kcMediumGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        labelColor: kcWhiteColor,
        unselectedLabelColor: kcBlackColor,
        indicator: const BoxDecoration(
          color: kcPrimaryColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: "Pending (${viewModel.pendingOrders.length})"),
          Tab(text: "Processing (${viewModel.processingOrders.length})"),
          Tab(text: "Completed (${viewModel.completedOrders.length})"),
        ],
      ),
    ),
  );
}

Widget _buildOrderList(List<Order> orders, OrderListViewModel viewModel) {
  if (orders.isEmpty) {
    return const EmptyState(animation: "assets/animations/empty_order.json", label: "No Orders in this category");
  }
  return ListView.builder(
    itemCount: orders.length,
    itemBuilder: (context, index) {
      final order = orders[index];
      return OrderCard(order: order, viewModel: viewModel);
    },
  );
}