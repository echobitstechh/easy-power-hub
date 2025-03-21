import 'dart:ui';

import 'package:easyph/app/app.locator.dart';
import 'package:easyph/core/data/models/product.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:easyph/ui/components/empty_state.dart';
import 'package:easyph/utils/money_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../core/data/models/order_item.dart';

/// Define the backend OrderStatus enum
enum OrderStatus { Pending, Processing, Delivered, Cancelled, Returns }

/// Converts a status string from the order to our OrderStatus enum
OrderStatus getOrderStatusEnum(String status) {
  if (status == "Pending") return OrderStatus.Pending;
  if (status == "Processing") return OrderStatus.Processing;
  if (status == "Completed") return OrderStatus.Delivered;
  if (status == "Cancelled") return OrderStatus.Cancelled;
  if (status == "Returns") return OrderStatus.Returns;
  return OrderStatus.Pending;
}

/// Returns a list of timeline steps based on the current status
List<Map<String, dynamic>> getTimelineSteps(OrderStatus currentStatus) {
  final allSteps = [
    {
      'status': OrderStatus.Pending,
      'title': 'Order Placed',
      'description': 'We have received your order',
    },
    {
      'status': OrderStatus.Processing,
      'title': 'Order Confirmed',
      'description': 'We have confirmed your order',
    },
    {
      'status': OrderStatus.Delivered,
      'title': 'Order Shipped',
      'description': 'We have shipped your order',
    },
    {
      'status': OrderStatus.Cancelled,
      'title': 'Order Cancelled',
      'description': 'Your order has been cancelled',
    },
    {
      'status': OrderStatus.Returns,
      'title': 'Order Returned',
      'description': 'Your order has been returned',
    },
  ];

  // Filter out "Returns"
  final filteredSteps =
  allSteps.where((step) => step['status'] != OrderStatus.Returns).toList();

  // Determine the index of the current status
  final currentIndex =
  filteredSteps.indexWhere((step) => step['status'] == currentStatus);

  // Mark each step with flags for first, last, completed and active
  for (int i = 0; i < filteredSteps.length; i++) {
    filteredSteps[i]['isFirst'] = (i == 0);
    filteredSteps[i]['isLast'] = (i == filteredSteps.length - 1);
    filteredSteps[i]['isCompleted'] = (i < currentIndex);
    filteredSteps[i]['isActive'] = (i == currentIndex);
  }

  return filteredSteps;
}

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<Order> orders = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => loading = true);
    try {
      ApiResponse res = await locator<Repository>().getOrderList();
      debugPrint("API Response: ${res.data}"); // Print full response data

      if (res.statusCode == 200) {
        setState(() {
          orders = (res.data["orders"] as List)
              .map((order) =>
              Order.fromJson(Map<String, dynamic>.from(order)))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }

    setState(() => loading = false);
  }

  List<Order> _pendingOrders() {
    return orders.where((order) => order.status == "Pending").toList();
  }

  List<Order> _completedOrders() {
    return orders
        .where((order) =>
    order.status == "Cancelled" || order.status == "Completed")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const EmptyState(
          animation: "empty_order.json", label: "No Orders Yet")
          : DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrderList(_pendingOrders(), "Pending Orders"),
                  _buildOrderList(
                      _completedOrders(), "Completed Orders"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicator: const BoxDecoration(
            color: kcPrimaryColor,
            borderRadius: BorderRadius.all(Radius.circular(8)), // Optional for rounded edges
          ),
          indicatorSize: TabBarIndicatorSize.tab, // Makes the indicator cover full tab width
          tabs: [
            Tab(text: "Pending (${_pendingOrders().length})"),
            Tab(text: "Completed (${_completedOrders().length})"),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String title) {
    if (orders.isEmpty) {
      return const EmptyState(
          animation: "empty_order.json", label: "No Orders Yet");
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    Product? product =
    order.products.isNotEmpty ? order.products.first : null;
    final imageUrl = product != null && product.images!.isNotEmpty
        ? product.images!.first
        : "https://via.placeholder.com/120";

    return InkWell(
      // Pass the specific order to the timeline bottom sheet
      onTap: () => showTimelineBottomSheet(context, order),
      child: Card(
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
                  InkWell(
                    onTap: () => showTimelineBottomSheet(context,order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(" ${order.status}",
                      style: const TextStyle(
                          fontSize: 14, color: kcOrangeColor)),
                ],
              ),
              const SizedBox(height: 10),
              _buildOrderActions(order),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsBottomSheet(Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Order #${order.orderNumber}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              ...order.products.map((product) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: _buildOrderDetails(
                    product,
                    product.images != null &&
                        product.images!.isNotEmpty
                        ? product.images!.first
                        : "https://placehold.co/400"),
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Modified to accept the tapped order so we can build the timeline dynamically
  void showTimelineBottomSheet(BuildContext context, Order order) {
    final orderStatusEnum = getOrderStatusEnum(order.status);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet taller
      backgroundColor: Colors.transparent, // Transparent background
      builder: (context) => _buildBottomSheetContent(orderStatusEnum),
    );
  }

  /// Modified bottom sheet content that builds the timeline dynamically
  Widget _buildBottomSheetContent(OrderStatus currentStatus) {
    final timelineEntries = getTimelineSteps(currentStatus);

    return DraggableScrollableSheet(
      initialChildSize: 0.5, // Adjust height
      maxChildSize: 0.8, // Maximum height
      minChildSize: 0.3, // Minimum height
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Order Status",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller:
                  scrollController, // Allows scrolling inside sheet
                  itemCount: timelineEntries.length,
                  itemBuilder: (context, index) {
                    final entry = timelineEntries[index];
                    final bool isFirst = entry['isFirst'] as bool;
                    final bool isLast = entry['isLast'] as bool;
                    final bool isCompleted = entry['isCompleted'] as bool;
                    final bool isActive = entry['isActive'] as bool;

                    return TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineXY: 0.1,
                      isFirst: isFirst,
                      isLast: isLast,
                      indicatorStyle: IndicatorStyle(
                        width: 25,
                        color: isActive
                            ? kcPrimaryColor
                            : isCompleted
                            ? kcVeryLightGrey
                            : kcVeryLightGrey,
                        iconStyle: isCompleted
                            ? IconStyle(
                          iconData: Icons.check,
                          color: kcPrimaryColor,
                        )
                            : null,
                      ),
                      beforeLineStyle: LineStyle(
                        color:
                        isCompleted ? kcPrimaryColor : kcPrimaryColor,
                        thickness: 3,
                      ),
                      afterLineStyle: const LineStyle(
                          color: kcPrimaryColor, thickness: 3),
                      endChild: _buildTimelineCard(
                        title: entry['title'] as String,
                        description: entry['description'] as String,
                        isActive: isActive,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Modified timeline card that changes its background based on active state
  Widget _buildTimelineCard(
      {required String title,
        required String description,
        bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        // constraints: const BoxConstraints(minHeight: 10),
        decoration: BoxDecoration(
          color: isActive
              ? kcPrimaryColor
              : Colors.grey.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18)),
                const SizedBox(height: 8),
                Text(description,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
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
            Text("Quantity: ${order.quantity}",
                style:
                const TextStyle(fontSize: 12, color: Colors.grey)),
            Text("Tracking: ${order.trackingNumber}",
                style:
                const TextStyle(fontSize: 12, color: Colors.grey)),
            verticalSpaceSmall,
            Text("Total: ${MoneyUtils().formatAmount(order.totalPrice as int)}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(
          DateFormat("d MMM, yyyy").format(order.createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Product? product, String imageUrl) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            height: 70,
            width: 70,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.productName ?? "Unknown Product",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                  "Total: ${MoneyUtils().formatAmount((double.tryParse(product?.price ?? '0.0') ?? 0.0).toInt())}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderActions(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (order.status == "Pending")
        // ElevatedButton.icon(
        //   onPressed: () {},
        //   icon: const Icon(Icons.payment, size: 16),
        //   label: const Text("Make Payment"),
        //   style: ElevatedButton.styleFrom(backgroundColor: kcSecondaryColor),
        // ),
          if (order.status == "Cancelled")
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text("Cancelled"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
            ),
        if (order.status == "Completed")
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.star, size: 16),
            label: const Text("Leave Review"),
            style:
            ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor),
          ),
      ],
    );
  }
}
