import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String token;
  final String imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.token,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'token': token,
      'imageUrl': imageUrl,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      token: map['token'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source));
}
