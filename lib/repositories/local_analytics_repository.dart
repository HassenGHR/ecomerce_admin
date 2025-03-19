import 'package:admin/models/aanlytics_model.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/repositories/base_repository.dart';
import 'package:admin/widgets/reuseable_widgets.dart';

class LocalAnalyticsRepository implements AnalyticsRepository {
  final List<OrderModel> dummyOrders;

  LocalAnalyticsRepository(this.dummyOrders);

  @override
  Future<Analytics> getAnalytics({
    required String timeFrame,
    String? category,
  }) async {
    try {
      final now = DateTime.now();
      final startTime =
          ReusableWidgets.getStartTimeForTimeFrame(timeFrame, now);

      final filteredOrders = dummyOrders.where((order) {
        final orderDate = DateTime.parse(order.date!);
        return orderDate.isAfter(startTime) &&
            (category == null || order.items == category);
      }).toList();

      double totalRevenue =
          filteredOrders.fold(0, (sum, order) => sum + (order.totalPrice ?? 0));
      int totalOrders = filteredOrders.length;
      List<OrderTrend> orderTrends = _calculateOrderTrends(filteredOrders);

      return Analytics(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0,
        totalProducts: 0,
        availableProducts: 0,
        orderTrends: orderTrends,
        categoryStats: [],
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception("Failed to fetch analytics: $e");
    }
  }

  @override
  Future<Analytics> getAnalyticsByUser({
    required UserModel user,
  }) async {
    try {
      final userOrders =
          dummyOrders.where((order) => order.user!.id == user.id).toList();

      double totalRevenue =
          userOrders.fold(0, (sum, order) => sum + (order.totalPrice ?? 0));
      int totalOrders = userOrders.length;
      double averageOrderValue =
          totalOrders > 0 ? totalRevenue / totalOrders : 0;
      List<OrderTrend> orderTrends = _calculateOrderTrends(userOrders);

      return Analytics(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        orderTrends: orderTrends,
        totalProducts: 0,
        availableProducts: 0,
        averageOrderValue: averageOrderValue,
        categoryStats: [],
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception("Failed to fetch analytics for the user: $e");
    }
  }

  @override
  Stream<Analytics> watchAnalytics(
      {required String timeFrame, String? category}) {
    return Stream.periodic(Duration(seconds: 5),
            (_) => getAnalytics(timeFrame: timeFrame, category: category))
        .asyncMap((event) async => await event);
  }

  List<OrderTrend> _calculateOrderTrends(List<OrderModel> orders) {
    final Map<DateTime, List<OrderModel>> groupedOrders = {};

    for (final order in orders) {
      final parsedDate = DateTime.parse(order.date!);
      final date = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      groupedOrders.putIfAbsent(date, () => []).add(order);
    }

    return groupedOrders.entries.map((entry) {
      final dailyOrders = entry.value;
      final revenue = dailyOrders.fold(
          0, (sum, order) => sum + (order.totalPrice ?? 0).toInt());
      return OrderTrend(
        date: entry.key,
        orderCount: dailyOrders.length,
        revenue: revenue.toDouble(),
      );
    }).toList();
  }
}
