import 'package:admin/models/order_model.dart';

class OrdersState {
  final bool isLoading;
  final List<OrderModel> orders;
  final Set<String> selectedIds;
  final Map<String, int> ordersQte;
  final double totalAmount; // New field to track the total amount
  final String? error;

  OrdersState({
    required this.isLoading,
    required this.orders,
    required this.selectedIds,
    required this.ordersQte,
    required this.totalAmount,
    this.error,
  });

  OrdersState.initial()
      : isLoading = false,
        orders = const [],
        selectedIds = const {},
        ordersQte = {},
        totalAmount = 0.0,
        error = null;

  OrdersState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    Set<String>? selectedIds,
    String? error,
    Map<String, int>? ordersQte,
    double? totalAmount,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      selectedIds: selectedIds ?? this.selectedIds,
      ordersQte: ordersQte ?? this.ordersQte,
      totalAmount: totalAmount ?? this.totalAmount,
      error: error,
    );
  }
}
