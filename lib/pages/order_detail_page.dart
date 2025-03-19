import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:admin/blocs/orders/order_bloc.dart';
import 'package:admin/blocs/orders/order_event.dart';
import 'package:admin/blocs/orders/order_state.dart';
import 'package:admin/blocs/products/product_bloc.dart';
import 'package:admin/blocs/products/product_state.dart';
import 'package:admin/models/cart_model.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/models/product_model.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late OrderModel currentOrder;
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void _removeItem(String productId) {
    setState(() {
      currentOrder.items?.removeWhere((item) => item.item.id == productId);
      currentOrder.totalPrice = currentOrder.items?.fold(
              0.0,
              (sum, item) =>
                  sum ?? 0 + ((item.item.price ?? 0) * (item.quantity ?? 0))) ??
          0.0;
    });
  }

  void _showAddItemBottomSheet() {
    ProductModel? tempSelectedProduct;
    quantityController.text = "1";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ProductsLoaded) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  height: 0.75.sh, // Responsive height
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.r)),
                  ),
                  child: Column(
                    children: [
                      _buildBottomSheetHeader(context),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16.w), // Responsive padding
                          child: _buildBottomSheetContent(
                            context,
                            state.products,
                            tempSelectedProduct,
                            (ProductModel? newValue) {
                              setModalState(
                                  () => tempSelectedProduct = newValue);
                            },
                          ),
                        ),
                      ),
                      _buildBottomSheetActions(context, tempSelectedProduct),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No products available.'));
        },
      ),
    );
  }

  Widget _buildBottomSheetHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w), // Responsive padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add New Item',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp, // Responsive font size
                ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    List<ProductModel> products,
    ProductModel? selectedProduct,
    Function(ProductModel?) onProductSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductSelector(products, selectedProduct, onProductSelected),
        SizedBox(height: 24.h), // Responsive spacing
        _buildQuantitySelector(),
        if (selectedProduct != null) ...[
          SizedBox(height: 24.h), // Responsive spacing
          _buildPriceSummary(selectedProduct),
        ],
      ],
    );
  }

  Widget _buildProductSelector(
    List<ProductModel> products,
    ProductModel? selectedProduct,
    Function(ProductModel?) onProductSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Product',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16.sp, // Responsive font size
              ),
        ),
        SizedBox(height: 8.h), // Responsive spacing
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12.r), // Responsive radius
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProductModel>(
              value: selectedProduct,
              isExpanded: true,
              hint: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w), // Responsive padding
                child: Text('Choose a product'),
              ),
              items: products.map((product) {
                return DropdownMenuItem<ProductModel>(
                  value: product,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w), // Responsive padding
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(product.title ?? 'Unknown'),
                        ),
                        Text(
                          '\$${product.price?.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: onProductSelected,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16.sp, // Responsive font size
              ),
        ),
        SizedBox(height: 8.h), // Responsive spacing
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12.r), // Responsive radius
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  int currentValue = int.tryParse(quantityController.text) ?? 0;
                  if (currentValue > 1) {
                    setState(() {
                      quantityController.text = (currentValue - 1).toString();
                    });
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  int currentValue = int.tryParse(quantityController.text) ?? 0;
                  setState(() {
                    quantityController.text = (currentValue + 1).toString();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(ProductModel product) {
    return Container(
      padding: EdgeInsets.all(16.w), // Responsive padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r), // Responsive radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unit Price:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${product.price?.toStringAsFixed(2)} Da',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 8.h), // Responsive spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${(product.price! * (int.tryParse(quantityController.text) ?? 1)).toStringAsFixed(2)} Da',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetActions(
      BuildContext context, ProductModel? selectedProduct) {
    return Container(
      padding: EdgeInsets.all(16.w), // Responsive padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: selectedProduct == null
            ? null
            : () {
                setState(() {
                  currentOrder.items?.add(
                    CartModel(
                      item: selectedProduct,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                    ),
                  );
                  currentOrder.totalPrice = currentOrder.items?.fold(
                          0.0,
                          (sum, item) =>
                              sum ??
                              0 +
                                  ((item.item.price ?? 0) *
                                      (item.quantity ?? 0))) ??
                      0.0;
                });
                Navigator.pop(context);
              },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h), // Responsive padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r), // Responsive radius
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart),
            SizedBox(width: 8.w), // Responsive spacing
            Text('Add to Order'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Text(
              'Order Details',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.background,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: Container(
            color: Theme.of(context).colorScheme.background,
            child: Column(
              children: [
                OrderSummaryWidget(
                  orderId: currentOrder.id ?? "",
                  customerPhone: currentOrder.user?.phone ?? "",
                  customerName: currentOrder.user?.name ?? "",
                  date: currentOrder.date ?? "",
                  onAddProduct: _showAddItemBottomSheet,
                ),
                Expanded(child: _buildItemsTable()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTotalAmount(state),
                    _buildEditOrderBtn(state),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditOrderBtn(OrdersState state) {
    return GestureDetector(
      onTap: () {
        context.read<OrdersBloc>().add(UpdateOrder(
              orderId: currentOrder.id!,
              updatedOrder: currentOrder,
            ));

        // Show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Updated',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Your order has been updated successfully',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Confirm Order',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount(OrdersState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            '\ ${state.totalAmount.toStringAsFixed(2)} Da',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 8.w, // Responsive border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(child: _buildTableContent()),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child:
                Text('Product', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text('Unit Price',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child:
                Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 48), // Space for action button
        ],
      ),
    );
  }

  Widget _buildTableContent() {
    double totalAmount = 0.0;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: currentOrder.items?.length ?? 0,
      itemBuilder: (context, index) {
        final item = currentOrder.items![index];
        totalAmount += ((item.item.price ?? 0) * (item.quantity ?? 0));
        // Dispatch the event to update the total amount
        context.read<OrdersBloc>().add(UpdateTotalAmount(totalAmount));

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.item.title ?? 'Unknown Product',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text('${item.item.price?.toStringAsFixed(1)}'),
                ),
                Expanded(
                  flex: 2,
                  child: Text('${item.quantity}'),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${((item.item.price ?? 0) * (item.quantity ?? 0)).toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () => _removeItem(item.item.id ?? ''),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Other methods (_buildEditOrderBtn, _buildTotalAmount, etc.) remain the same
  // but should also use `.w`, `.h`, `.sp`, and `.r` for responsiveness.
}

class OrderSummaryWidget extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String date;

  final VoidCallback onAddProduct;
  final List<Widget>? additionalContent;

  const OrderSummaryWidget({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.onAddProduct,
    required this.date,
    this.additionalContent,
  }) : super(key: key);

  String formatDate(String dateStr) {
    try {
      // Try parsing ISO 8601 formatted date
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      try {
        // If it's not ISO format, try the 'dd MMMM yyyy' format
        DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        return 'Invalid date'; // Handle any invalid date format case
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 8.w, // Responsive border width
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildCustomerInfo(context),
                const SizedBox(height: 16),
                _buildAddProductButton(context),
                if (additionalContent != null) ...[
                  const SizedBox(height: 16),
                  ...additionalContent!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Order #${orderId.substring(0, 8)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          child: Text(
            customerName[0].toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                customerPhone,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                formatDate(date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return InkWell(
      onTap: onAddProduct,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Add New Product',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
