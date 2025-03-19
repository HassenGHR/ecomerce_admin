import 'package:admin/blocs/orders/order_event.dart';
import 'package:admin/blocs/orders/order_state.dart';

import 'package:admin/repositories/local_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final LocalOrderRepository orderRepository;

  OrdersBloc({required this.orderRepository}) : super(OrdersState.initial()) {
    on<FetchOrders>(_onFetchOrders);
    on<ToggleOrderSelection>(_onToggleOrderSelection);
    on<LoadDeliveryItems>(_onLoadDeliveryItems);
    on<ClearDeliveryItems>(_onClearDeliveryItems);
    on<SelectOrder>(_onSelectOrder);
    on<DeselectOrder>(_onDeselectOrder);
    on<UpdateOrderIds>(_onUpdateOrderIds);
    on<UpdateTotalAmount>(_onUpdateTotalAmount);
    on<UpdateOrder>(_onUpdateOrder);
  }

  void _onToggleOrderSelection(
      ToggleOrderSelection event, Emitter<OrdersState> emit) {
    final updatedSelectedIds = Set<String>.from(state.selectedIds);
    updatedSelectedIds.contains(event.orderId)
        ? updatedSelectedIds.remove(event.orderId)
        : updatedSelectedIds.add(event.orderId);
    emit(state.copyWith(selectedIds: updatedSelectedIds));
  }

  void _onUpdateOrderIds(UpdateOrderIds event, Emitter<OrdersState> emit) {
    final updatedOrderIds = Set<String>.from(state.selectedIds)
      ..clear()
      ..addAll(event.newOrderIds);
    emit(state.copyWith(selectedIds: updatedOrderIds));
  }

  void _onUpdateTotalAmount(
      UpdateTotalAmount event, Emitter<OrdersState> emit) {
    emit(state.copyWith(totalAmount: event.totalAmount));
  }

  Future<void> _onLoadDeliveryItems(
      LoadDeliveryItems event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      Map<String, int> productQuantities = {};
      for (var order in state.orders) {
        if (event.selectedOrderIds.contains(order.id)) {
          for (var item in order.items!) {
            String itemName = item.item.title;
            int quantity = item.quantity;
            productQuantities[itemName] =
                (productQuantities[itemName] ?? 0) + quantity;
          }
        }
      }
      emit(state.copyWith(isLoading: false, ordersQte: productQuantities));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateOrder(UpdateOrder event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final isSuccess = await orderRepository.updateOrder(
        event.updatedOrder,
        event.orderId,
      );
      if (isSuccess) {
        final updatedOrders = state.orders.map((order) {
          return order.id == event.orderId ? event.updatedOrder : order;
        }).toList();
        emit(state.copyWith(isLoading: false, orders: updatedOrders));
      } else {
        emit(state.copyWith(
            isLoading: false, error: 'Failed to update order locally.'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onSelectOrder(SelectOrder event, Emitter<OrdersState> emit) {
    emit(state.copyWith(selectedIds: {...state.selectedIds, event.orderId}));
  }

  void _onDeselectOrder(DeselectOrder event, Emitter<OrdersState> emit) {
    emit(state.copyWith(
        selectedIds:
            state.selectedIds.where((id) => id != event.orderId).toSet()));
  }

  void _onClearDeliveryItems(
      ClearDeliveryItems event, Emitter<OrdersState> emit) {
    emit(state.copyWith(selectedIds: {}, orders: []));
  }

  Future<void> _onFetchOrders(
      FetchOrders event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final orders = await orderRepository.fetchOrders();
      emit(state.copyWith(isLoading: false, orders: orders));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
