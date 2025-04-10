import 'package:easyph/core/data/models/raffle_cart_item.dart';

import '../core/data/models/cart_item.dart';


double getRaffleSubTotal(List<CartItem> cart) {
  double total = 0;

  for (var element in cart) {
    // Convert the price from string to double before performing the multiplication
    double price = double.parse(element.product!.salePrice!);

    total = total + (price * element.quantity!);
  }

  return total;
}





int getTotalRaffleItems(List<RaffleCartItem> cart) {
  int quantity = 0;
  for (var element in cart) {
    quantity = quantity + element.quantity!;
  }

  return quantity;
}