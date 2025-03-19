import 'package:admin/models/aanlytics_model.dart';
import 'package:admin/models/notification_model.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/models/product_model.dart';
import 'package:admin/models/user_model.dart';

abstract class OrderRepository {
  Stream<List<OrderModel>> watchOrders();
  Future<List<OrderModel>> fetchOrders();
  Future<bool> updateOrder(OrderModel updatedOrder, String orderId);
  Future<Map<String, int>> fetchOrderProductsQuantityByIds(List<String> ids);
  Future<OrderModel?> getOrderById(String orderId);
}

abstract class ProductRepository {
  Stream<List<ProductModel>> watchProducts();
  Future<bool> addProduct(ProductModel product);
  Future<bool> updateProductInDatabase(ProductModel updatedProduct);
  Future<bool> deleteProductById(String productId);
  Future<void> updateProductAvailability(String productId, bool isAvailable);
  Future<String> uploadImage(String imagePath);
  Future<void> removeImage(String imageUrl);
  Future<void> saveProductToLocal(ProductModel product);
  Future<ProductModel?> getProductFromLocal(String productId);
  Future<void> removeProductFromLocal(String productId);
  Future<ProductModel> getProduct(String id);
  Stream<List<ProductModel>> watchProductsByCategory(String category);
}

abstract class AnalyticsRepository {
  /// Fetches analytics data based on the specified time frame and category.
  Future<Analytics> getAnalytics({
    required String timeFrame,
    String? category,
  });

  /// Streams analytics updates (if needed for real-time data).
  Stream<Analytics> watchAnalytics({
    required String timeFrame,
    String? category,
  });

  /// Filters analytics data by category.
  Future<Analytics> getAnalyticsByUser({required UserModel user});
}

abstract class UserRepository {
  Future<void> saveUser(UserModel user);
  Future<void> saveToken(String token);
  Future<UserModel?> getUser();
  Future<void> signOut();
  Future<String?> getFCMToken();
  Future<List<UserModel>> fetchCustomers();
  Future<UserModel?> getUserByPhone(String phone);
}

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<bool> markNotificationAsRead(String orderId);
}
