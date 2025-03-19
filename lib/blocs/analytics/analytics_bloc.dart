import 'package:admin/blocs/analytics/analytics_event.dart';
import 'package:admin/blocs/analytics/analytics_state.dart';
import 'package:admin/constant/dummy_data.dart';

import 'package:bloc/bloc.dart';

class OrderAnalyticsBloc
    extends Bloc<OrderAnalyticsEvent, OrderAnalyticsState> {
  OrderAnalyticsBloc() : super(OrderAnalyticsInitial()) {
    on<FetchOrdersEvent>(_onFetchOrdersEvent);
  }

  Future<void> _onFetchOrdersEvent(
    FetchOrdersEvent event,
    Emitter<OrderAnalyticsState> emit,
  ) async {
    emit(OrderAnalyticsLoading());
    try {
      emit(OrderAnalyticsLoaded(orders: dummyOrders));
    } catch (e) {
      emit(OrderAnalyticsError(e.toString()));
    }
  }
}
