import 'package:easyph/core/data/models/product.dart';

class RaffleCartItem {
  Product? raffle;
  int? quantity;

  RaffleCartItem({this.raffle, this.quantity});

  RaffleCartItem.fromJson(Map<String, dynamic> json) {
    // Use Product.fromJson to create the Product instance
    raffle = Product.fromJson(json);
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (raffle != null) {
      data['product'] = raffle!.toJson();
    }
    data['quantity'] = quantity;
    return data;
  }
}

