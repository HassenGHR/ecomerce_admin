import 'package:admin/models/order_model.dart';

abstract class OrderAnalyticsState {}

class OrderAnalyticsInitial extends OrderAnalyticsState {}

class OrderAnalyticsLoading extends OrderAnalyticsState {}

class OrderAnalyticsLoaded extends OrderAnalyticsState {
  final List<OrderModel> orders;

  OrderAnalyticsLoaded({
    required this.orders,
  });
}

class OrderAnalyticsError extends OrderAnalyticsState {
  final String message;

  OrderAnalyticsError(this.message);
}
