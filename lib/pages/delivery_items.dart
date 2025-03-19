import 'package:admin/blocs/orders/order_bloc.dart';
import 'package:admin/blocs/orders/order_event.dart';
import 'package:admin/blocs/orders/order_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryConfirmationPage extends StatelessWidget {
  final List<String> selectedOrderIds;

  const DeliveryConfirmationPage({
    super.key,
    required this.selectedOrderIds,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<OrdersBloc>()
        ..add(LoadDeliveryItems(selectedOrderIds: selectedOrderIds)),
      child: const _DeliveryConfirmationView(),
    );
  }
}

class _DeliveryConfirmationView extends StatelessWidget {
  const _DeliveryConfirmationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد التوصيل'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return _ErrorWidget(
              error: state.error!,
              onRetry: () => context.read<OrdersBloc>().add(
                    LoadDeliveryItems(
                      selectedOrderIds: state.selectedIds.toList(),
                    ),
                  ),
            );
          }

          if (state.ordersQte.isEmpty) {
            return const _EmptyWidget();
          }

          return _ConfirmationContent(
            ordersQte: state.ordersQte,
            onConfirm: () => _handleConfirmation(context),
          );
        },
      ),
    );
  }

  void _handleConfirmation(BuildContext context) {
    context.read<OrdersBloc>().add(ClearDeliveryItems());
    Navigator.pop(context);
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'لا توجد منتجات للتأكيد',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

class _ConfirmationContent extends StatelessWidget {
  final Map<String, int> ordersQte;
  final VoidCallback onConfirm;

  const _ConfirmationContent({
    required this.ordersQte,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: _buildProductsList(),
          ),
          const SizedBox(height: 16),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Card(
      elevation: 2,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ordersQte.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final entry = ordersQte.entries.elementAt(index);
          return _ProductItem(
            name: entry.key,
            quantity: entry.value,
          );
        },
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onConfirm,
        child: const Text(
          'تأكيد التوصيل',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final String name;
  final int quantity;

  const _ProductItem({
    required this.name,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
