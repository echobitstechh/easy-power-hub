
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/cart_item.dart';
import '../../../core/data/models/order_item.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/paystack_util.dart';
import '../../../state.dart';


enum OrderStatus { Pending, Processing, Delivered, Cancelled, Returns }

/// Converts a status string from the order to our OrderStatus enum
OrderStatus getOrderStatusEnum(String status) {
  if (status == "Pending") return OrderStatus.Pending;
  if (status == "Processing") return OrderStatus.Processing;
  if (status == "Completed") return OrderStatus.Delivered;
  if (status == "Delivered") return OrderStatus.Delivered;
  if (status == "Cancelled") return OrderStatus.Cancelled;
  if (status == "Returns") return OrderStatus.Returns;
  return OrderStatus.Pending;
}

class OrderListViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _log = getLogger("OrderListViewModel");
  final _snackBar = locator<SnackbarService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();

  List<Order> _orders = [];

  List<Order> get allOrders => _orders;
  List<Order> get pendingOrders => _orders.where((o) => o.status == "Pending").toList();
  List<Order> get processingOrders => _orders.where((o) => o.status == "Processing").toList();
  List<Order> get completedOrders => _orders.where((o) => o.status == "Delivered" || o.status == "Cancelled").toList();

  @override
  Future<void> onModelReady() async {
    await runBusyFuture(fetchOrders());
  }

  Future<void> fetchOrders() async {
    try {
      ApiResponse res = await _repo.getOrderList();
      if (res.statusCode == 200) {
        _orders = (res.data["orders"] as List)
            .map((order) => Order.fromJson(Map<String, dynamic>.from(order)))
            .toList();
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      } else {
        _snackBar.showSnackbar(message: res.data["message"] ?? "Failed to fetch orders.");
      }
    } catch (e) {
      _log.e("Error fetching orders: $e");
      _snackBar.showSnackbar(message: "An error occurred while fetching orders.");
    }
  }

  Future<void> makePayment(BuildContext context, Order order) async {
    setBusy(true);
    try {
      // Correctly map the order products to a list of CartItems
      // This assumes your Order model has a list of products and quantities
      final miniCartItems = order.products
          .map((item) => CartItem(
        product: item,
        quantity: 1, // Use the product's individual quantity
        price: double.tryParse(item.salePrice ?? '0.0') ?? 0.0,
      ))
          .toList();

      if (!context.mounted) {
        return; // Exit the function if the context is no longer valid.
      }

      ApiResponse response = await _repo.initializePayment({
        'paymentMethod': 'CreditCard',
        'paymentType': 'Paystack',
        'orderId': order.id,
      });

      if (response.statusCode == 200) {
        // Pass the context from the UI and the correct parameters
        await PaystackUtil.processPayment(
          context: context,
          ref: response.data['data']['reference'],
          accessCode: response.data['data']['access_code'],
          url: response.data['data']['authorization_url'],
          amountInNaira: order.totalPrice, // Use the order's total price
          email: profile.value.email!,
          cartItems: miniCartItems,
        );
      } else {
        _snackBar.showSnackbar(
            message: "Payment initialization failed.",
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      _log.e("Payment error: $e");
      _snackBar.showSnackbar(
          message: "An error occurred during payment.",
          duration: const Duration(seconds: 2));
    } finally {
      setBusy(false);
    }
  }

  void showOrderTimeline(Order order) {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.orderStatusTimeline,
      data: getOrderStatusEnum(order.status),
    );
  }

  void leaveReview(Order order) {
    _snackBar.showSnackbar(message: "Leaving a review for order ${order.orderNumber}");
  }
}