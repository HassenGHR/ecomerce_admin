import 'dart:math';

import 'package:admin/models/cart_model.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/models/product_model.dart';
import 'package:admin/models/user_model.dart';

List<ProductModel> dummyProducts = [
  ProductModel(
    id: "prod_001",
    title: "Wireless Earbuds",
    description: "High-quality Bluetooth earbuds with noise cancellation.",
    category: "Electronics",
    price: 49.99,
    isAvailable: true,
    priceDescription: "Per unit",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_002",
    title: "Smartphone Holder",
    description:
        "Universal car mount for smartphones with 360-degree rotation.",
    category: "Accessories",
    price: 19.99,
    isAvailable: true,
    priceDescription: "Per piece",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_003",
    title: "Men's Leather Wallet",
    description:
        "Genuine leather wallet with RFID protection and multiple slots.",
    category: "Fashion",
    price: 29.99,
    isAvailable: true,
    priceDescription: "Per unit",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_004",
    title: "Wireless Mouse",
    description: "Ergonomic design with adjustable DPI and silent clicks.",
    category: "Electronics",
    price: 24.99,
    isAvailable: true,
    priceDescription: "Per unit",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_005",
    title: "Stainless Steel Water Bottle",
    description:
        "500ml double-wall insulated bottle, keeps drinks hot or cold.",
    category: "Home & Kitchen",
    price: 15.99,
    isAvailable: true,
    priceDescription: "Per bottle",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_006",
    title: "LED Desk Lamp",
    description:
        "Touch-sensitive LED lamp with adjustable brightness and USB charging.",
    category: "Home & Office",
    price: 39.99,
    isAvailable: true,
    priceDescription: "Per unit",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_007",
    title: "Gaming Keyboard",
    description: "RGB backlit mechanical keyboard with anti-ghosting keys.",
    category: "Electronics",
    price: 59.99,
    isAvailable: true,
    priceDescription: "Per unit",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_008",
    title: "Portable Power Bank",
    description: "10000mAh power bank with fast charging and dual USB ports.",
    category: "Electronics",
    price: 34.99,
    isAvailable: true,
    priceDescription: "Per unit",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_009",
    title: "Men's Running Shoes",
    description: "Lightweight breathable sneakers for sports and casual wear.",
    category: "Fashion",
    price: 49.99,
    isAvailable: true,
    priceDescription: "Per pair",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
  ProductModel(
    id: "prod_010",
    title: "Smart Fitness Tracker",
    description:
        "Waterproof fitness band with heart rate monitor and step counter.",
    category: "Electronics",
    price: 44.99,
    isAvailable: true,
    priceDescription: "Per unit",
    imageUrls: [
      {
        "image1": "https://example.com/images/earbuds.jpg",
        "cover_image": "https://example.com/images/earbuds.jpg",
      }
    ],
  ),
];

List<UserModel> dummyUsers = [
  UserModel(
      id: "user_001",
      name: "Ali Ahmed",
      email: "ali.ahmed@example.com",
      phone: "+213123456789",
      address: "Algiers, Algeria",
      token: "token_001",
      imageUrl: ""),
  UserModel(
      id: "user_002",
      name: "Fatima Bensaid",
      email: "fatima.b@example.com",
      phone: "+213987654321",
      address: "Oran, Algeria",
      token: "token_002",
      imageUrl: ""),
  UserModel(
      id: "user_003",
      name: "Omar Meziane",
      email: "omar.m@example.com",
      phone: "+213555667788",
      address: "Constantine, Algeria",
      token: "token_003",
      imageUrl: ""),
];

List<OrderModel> dummyOrders = List.generate(10, (index) {
  final random = Random();
  List<CartModel> cartItems = List.generate(random.nextInt(3) + 1, (i) {
    ProductModel product = dummyProducts[random.nextInt(dummyProducts.length)];
    return CartModel(item: product, quantity: random.nextInt(5) + 1);
  });

  return OrderModel(
    id: "order_${index + 1}",
    date: "2024-08-${random.nextInt(30) + 1}",
    totalPrice: cartItems.fold(
        0, (sum, item) => sum! + (item.item.price * item.quantity)),
    user: dummyUsers[random.nextInt(dummyUsers.length)],
    items: cartItems,
  );
});
