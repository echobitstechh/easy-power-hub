import 'package:afriprize/app/app.locator.dart';
import 'package:afriprize/core/data/models/product.dart';
import 'package:afriprize/core/data/repositories/repository.dart';
import 'package:afriprize/core/network/api_response.dart';
import 'package:afriprize/ui/common/app_colors.dart';
import 'package:afriprize/ui/common/ui_helpers.dart';
import 'package:afriprize/ui/components/empty_state.dart';
import 'package:afriprize/utils/money_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/data/models/order_item.dart';

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
              .map((order) => Order.fromJson(Map<String, dynamic>.from(order)))
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
    return Container(
      color: Colors.white,
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        indicator: const BoxDecoration(color: kcPrimaryColor),
        tabs: [
          Tab(text: "Pending (${_pendingOrders().length})"),
          Tab(text: "Completed (${_completedOrders().length})"),
        ],
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

    Product? product = order.products.isNotEmpty ? order.products.first : null;
    final imageUrl = product != null && product.images!.isNotEmpty
        ? product.images!.first
        : "https://via.placeholder.com/120";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  onTap: () => _showOrderDetailsBottomSheet(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1), // Borderline
                      borderRadius: BorderRadius.circular(12), // Optional: Rounded corners
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
                    style: const TextStyle(fontSize: 14, color: kcOrangeColor)),
              ],
            ),

    //         ...order.products.map((product) => Padding(
    //               padding: EdgeInsets.symmetric(vertical: 5),
    //               child: _buildOrderDetails(
    //                   product,
    //                   //e.images!.first),
    //               product.images != null && product.images!.isNotEmpty ? product.images!.first : 'https://img.icons8.com/?size=100&id=53386&format=png'),
    //
    // )
            //),
            const SizedBox(height: 10),
            _buildOrderActions(order),
          ],
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
                child: _buildOrderDetails(product, product.images != null && product.images!.isNotEmpty ? product.images!.first : "https://placehold.co/400"),
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            // Text("Status: ${order.status}",
            //     style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text("Tracking: ${order.trackingNumber}",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
        if (order.status == "Completed")
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.star, size: 16),
            label: const Text("Leave Review"),
            style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor),
          ),
      ],
    );
  }
}
