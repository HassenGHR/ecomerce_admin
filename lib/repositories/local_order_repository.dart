import 'package:admin/constant/dummy_data.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/repositories/base_repository.dart';

class LocalOrderRepository implements OrderRepository {
  @override
  Future<List<OrderModel>> fetchOrders() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final filteredOrders = dummyOrders.where((order) {
        if (order.date == null) return false;
        final orderDate = DateTime.parse(order.date!);
        return orderDate.isAfter(today);
      }).toList();

      return filteredOrders;
    } catch (e) {
      throw OrderRepositoryException('Failed to fetch orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return dummyOrders.firstWhere(
        (order) => order.id == orderId,
      );
    } catch (e) {
      throw OrderRepositoryException(
          'Failed to fetch order by ID: ${e.toString()}');
    }
  }

  @override
  Future<bool> updateOrder(OrderModel updatedOrder, String orderId) async {
    try {
      final index = dummyOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        dummyOrders[index] = updatedOrder;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, int>> fetchOrderProductsQuantityByIds(
      List<String> ids) async {
    try {
      Map<String, int> productQuantities = {};

      for (var order in dummyOrders) {
        if (ids.contains(order.id)) {
          for (var item in order.items!) {
            if (productQuantities.containsKey(item.item.title)) {
              productQuantities[item.item.title] =
                  productQuantities[item.item.title]! + item.quantity;
            } else {
              productQuantities[item.item.title] = item.quantity;
            }
          }
        }
      }

      return productQuantities;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<void> clearOrders() async {
    dummyOrders.clear();
  }

  @override
  Stream<List<OrderModel>> watchOrders() {
    return Stream.value(dummyOrders.toList());
  }
}

class OrderRepositoryException implements Exception {
  final String message;
  OrderRepositoryException(this.message);
  @override
  String toString() => message;
}
