import 'package:admin/models/product_model.dart';

class CartModel {
  final ProductModel item; // Holds product details
  int quantity; // Quantity of this product in the cart

  CartModel({
    required this.item,
    this.quantity = 1, // Default quantity is 1
  });

  // Method to increase quantity
  void increaseQuantity() {
    quantity++;
  }

  // Setter for explicitly setting the quantity
  void setQuantity(int newQuantity) {
    if (newQuantity >= 0) {
      quantity = newQuantity;
    }
  }

  // Method to decrease quantity
  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // Convert to JSON (optional, for storage or API handling)
  Map<String, dynamic> toJson() {
    return {
      'item': item.toMap(), // Assuming ProductModel has a `toJson` method
      'quantity': quantity,
    };
  }

  // Create a CartModel from JSON (optional)
  factory CartModel.fromJson(Map<dynamic, dynamic> json) {
    return CartModel(
      item: ProductModel.fromMap(json['item']),
      quantity: json['quantity'] ?? 1,
    );
  }
}
