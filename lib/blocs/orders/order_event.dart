import 'package:admin/models/order_model.dart';
import 'package:equatable/equatable.dart';

/// Base class for all order events.
abstract class OrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to fetch orders.
class FetchOrders extends OrdersEvent {}

class FetchOrderProductsQuantityByIds extends OrdersEvent {}

class LoadDeliveryItems extends OrdersEvent {
  final List<String> selectedOrderIds;

  LoadDeliveryItems({required this.selectedOrderIds});
}

class ClearDeliveryItems extends OrdersEvent {}

class UpdateOrderIds extends OrdersEvent {
  final List<String> newOrderIds;

  UpdateOrderIds(this.newOrderIds);
}

class UpdateTotalAmount extends OrdersEvent {
  final double totalAmount;

  UpdateTotalAmount(this.totalAmount);
}

class UpdateOrder extends OrdersEvent {
  final String orderId;
  final OrderModel updatedOrder;

  UpdateOrder({required this.orderId, required this.updatedOrder});
}

class ClearSelectedOrderIds extends OrdersEvent {}

/// Event to toggle the selection of an order.
class ToggleOrderSelection extends OrdersEvent {
  final String orderId;

  ToggleOrderSelection(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Event to deselect an order ID.
class DeselectOrder extends OrdersEvent {
  final String orderId;

  DeselectOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Event to select an order ID.
class SelectOrder extends OrdersEvent {
  final String orderId;

  SelectOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
