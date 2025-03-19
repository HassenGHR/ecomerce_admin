import 'dart:ui';

class ProductModel {
  String id;
  String title;
  String description;
  String category;
  Color? color;
  double price;
  bool isAvailable;
  String priceDescription;
  List<Map<String, String>> imageUrls;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.color,
    required this.price,
    required this.isAvailable,
    required this.priceDescription,
    required this.imageUrls,
  });

  // Factory constructor to create ProductModel from a map
  factory ProductModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      color: map['color'] != null
          ? Color(int.tryParse(map['color'].toString()) ?? 0xFFFFFFFF)
          : null,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] ?? true,
      priceDescription: map['priceDescription'] ?? '',
      imageUrls: (map['imageUrls'] as List<dynamic>? ?? [])
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
    );
  }

  // Convert ProductModel object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'color': color?.value,
      'price': price,
      'isAvailable': isAvailable,
      'priceDescription': priceDescription,
      'imageUrls':
          imageUrls.map((urlMap) => Map<String, String>.from(urlMap)).toList(),
    };
  }

  // Copy with method
  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    Color? color,
    double? price,
    bool? isAvailable,
    String? priceDescription,
    List<Map<String, String>>? imageUrls,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      color: color ?? this.color,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      priceDescription: priceDescription ?? this.priceDescription,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
