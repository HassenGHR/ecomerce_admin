import 'dart:convert';
import 'package:admin/models/product_model.dart';
import 'package:admin/repositories/base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<ProductModel> dummyProducts = [];

class DummyProductRepository implements ProductRepository {
  @override
  Future<void> updateProductAvailability(
      String productId, bool isAvailable) async {
    final index = dummyProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      dummyProducts[index] =
          dummyProducts[index].copyWith(isAvailable: isAvailable);
    }
  }

  @override
  Future<bool> addProduct(ProductModel product) async {
    dummyProducts.add(product);
    return true;
  }

  @override
  Future<bool> deleteProductById(String productId) async {
    dummyProducts.removeWhere((p) => p.id == productId);
    return true;
  }

  @override
  Future<bool> updateProductInDatabase(ProductModel updatedProduct) async {
    final index = dummyProducts.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      dummyProducts[index] = updatedProduct;
      return true;
    }
    return false;
  }

  @override
  Future<ProductModel?> getProductFromLocal(String productId) async {
    return dummyProducts.firstWhere((p) => p.id == productId);
  }

  @override
  Future<void> saveProductToLocal(ProductModel product) async {
    await addProduct(product);
  }

  @override
  Future<void> removeProductFromLocal(String productId) async {
    await deleteProductById(productId);
  }

  @override
  Future<String> uploadImage(String imagePath) async {
    return imagePath; // Dummy return for testing
  }

  @override
  Future<void> removeImage(String imageUrl) async {
    // No-op for dummy repository
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await updateProductInDatabase(product);
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    return dummyProducts.firstWhere((p) => p.id == id);
  }

  @override
  Stream<List<ProductModel>> watchProducts() {
    return Stream.value(dummyProducts);
  }

  @override
  Stream<List<ProductModel>> watchProductsByCategory(String category) {
    return Stream.value(
        dummyProducts.where((p) => p.category == category).toList());
  }
}
