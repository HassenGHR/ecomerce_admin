import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:admin/blocs/analytics/analytics_bloc.dart';
import 'package:admin/blocs/analytics/analytics_event.dart';
import 'package:admin/blocs/orders/order_bloc.dart';
import 'package:admin/blocs/orders/order_event.dart';
import 'package:admin/blocs/orders/order_state.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/pages/delivery_items.dart';
import 'package:admin/pages/order_detail_page.dart';
import 'package:admin/repositories/local_order_repository.dart';
import 'package:admin/widgets/order_item_tile.dart';
import 'package:intl/intl.dart';

class ConfirmedOrders extends StatelessWidget {
  const ConfirmedOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc(
        orderRepository: context.read<LocalOrderRepository>(),
      )..add(FetchOrders()),
      child: const ConfirmedOrdersView(),
    );
  }
}

class ConfirmedOrdersView extends StatelessWidget {
  const ConfirmedOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _LoadingView();
        }

        if (state.error != null) {
          return _ErrorView(error: state.error!);
        }

        if (state.orders.isEmpty) {
          return _EmptyView();
        }

        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: _OrdersList(state: state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, OrdersState state) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        'الطلبيات',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      actions: [
        _DeliveryButton(selectedIds: state.selectedIds),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60.w,
                height: 60.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Preparing Your Orders...',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60.sp,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<OrderAnalyticsBloc>().add(FetchOrdersEvent()),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.sp,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد طلبات حالياً',
              style: TextStyle(
                fontSize: 18.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final OrdersState state;

  const _OrdersList({required this.state});

  void _navigateToOrderDetails(OrderModel order, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(8.w),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        List<OrderModel> sortedOrders = state.orders
          ..sort((a, b) {
            DateTime parseDate(String dateStr) {
              try {
                return DateTime.parse(dateStr);
              } catch (e) {
                try {
                  return DateFormat('dd MMMM yyyy HH:mm:ss').parse(dateStr);
                } catch (e) {
                  return DateFormat('dd MMMM yyyy').parse(dateStr);
                }
              }
            }

            DateTime dateA = parseDate(a.date!);
            DateTime dateB = parseDate(b.date!);
            return dateB.compareTo(dateA);
          });
        final order = sortedOrders[index];
        return OrderItemTile(
          order: order,
          isSelected: state.selectedIds.contains(order.id),
          onNavigate: (order) {
            _navigateToOrderDetails(order, context);
          },
          onSelect: (_order) {
            final bloc = context.read<OrdersBloc>();
            bloc.add(
              state.selectedIds.contains(_order.id)
                  ? DeselectOrder(orderId: _order.id!)
                  : SelectOrder(orderId: _order.id!),
            );
          },
        );
      },
    );
  }
}

class _DeliveryButton extends StatelessWidget {
  final Set<String> selectedIds;

  const _DeliveryButton({required this.selectedIds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: InkWell(
        onTap: () => _navigateToDeliveryItems(context),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.local_shipping,
                size: 28.sp,
                color: theme.colorScheme.primary,
              ),
            ),
            if (selectedIds.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    selectedIds.length.toString(),
                    style: TextStyle(
                      color: theme.colorScheme.onError,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDeliveryItems(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersBloc>(),
          child: DeliveryConfirmationPage(
            selectedOrderIds:
                context.read<OrdersBloc>().state.selectedIds.toList(),
          ),
        ),
      ),
    );

    if (result == true) {
      context.read<OrdersBloc>().add(FetchOrders());
    }
  }
}
