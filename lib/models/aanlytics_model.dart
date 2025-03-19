class Analytics {
  final int totalOrders;
  final double totalRevenue;
  final List<OrderTrend> orderTrends;
  final int totalProducts;
  final int availableProducts;
  final double averageOrderValue;
  final List<CategoryStats> categoryStats;
  final DateTime lastUpdated;

  Analytics({
    required this.totalOrders,
    required this.totalRevenue,
    required this.orderTrends,
    required this.totalProducts,
    required this.availableProducts,
    required this.averageOrderValue,
    required this.categoryStats,
    required this.lastUpdated,
  });

  factory Analytics.fromRealtimeDatabase(Map<dynamic, dynamic> data) {
    return Analytics(
      totalOrders: data['totalOrders'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),
      orderTrends: (data['orderTrends'] as Map<dynamic, dynamic>? ?? {})
          .entries
          .map((entry) => OrderTrend.fromRealtimeDatabase(
              entry.value as Map<dynamic, dynamic>))
          .toList(),
      totalProducts: data['totalProducts'] ?? 0,
      availableProducts: data['availableProducts'] ?? 0,
      averageOrderValue: (data['averageOrderValue'] ?? 0.0).toDouble(),
      categoryStats: (data['categoryStats'] as Map<dynamic, dynamic>? ?? {})
          .entries
          .map((entry) => CategoryStats.fromRealtimeDatabase(
              entry.value as Map<dynamic, dynamic>))
          .toList(),
      lastUpdated:
          DateTime.tryParse(data['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }
}

class OrderTrend {
  final DateTime date;
  final int orderCount;
  final double revenue;

  OrderTrend({
    required this.date,
    required this.orderCount,
    required this.revenue,
  });

  factory OrderTrend.fromRealtimeDatabase(Map<dynamic, dynamic> data) {
    return OrderTrend(
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      orderCount: data['orderCount'] ?? 0,
      revenue: (data['revenue'] ?? 0.0).toDouble(),
    );
  }
}

class CategoryStats {
  final String category;
  final int totalProducts;
  final int availableProducts;
  final double revenue;

  CategoryStats({
    required this.category,
    required this.totalProducts,
    required this.availableProducts,
    required this.revenue,
  });

  factory CategoryStats.fromRealtimeDatabase(Map<dynamic, dynamic> data) {
    return CategoryStats(
      category: data['category'] ?? '',
      totalProducts: data['totalProducts'] ?? 0,
      availableProducts: data['availableProducts'] ?? 0,
      revenue: (data['revenue'] ?? 0.0).toDouble(),
    );
  }
}
