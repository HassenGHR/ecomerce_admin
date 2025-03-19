import 'package:admin/models/cart_model.dart';
import 'package:admin/models/user_model.dart';

class OrderModel {
  String? id;
  List<CartModel>? items;
  double? totalPrice;
  String? date;
  UserModel? user;

  OrderModel({
    this.id,
    this.items,
    this.totalPrice,
    this.date,
    this.user,
  });

  // Factory constructor to create an OrderModel from a Map
  factory OrderModel.fromMap(Map<dynamic, dynamic> map) {
    return OrderModel(
      id: map['id'],
      date: map['date'],
      totalPrice: map['totalPrice']?.toDouble(),
      user: map['user'] != null ? UserModel.fromMap(map['user']) : null,
      items: map['items'] != null
          ? List<CartModel>.from(
              map['items'].map((item) => CartModel.fromJson(item)),
            )
          : null,
    );
  }

  // Convert the OrderModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalPrice': totalPrice,
      'date': date,
      'user': user?.toMap(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}
