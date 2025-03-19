import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:admin/models/order_model.dart';

class OrderItemTile extends StatelessWidget {
  final OrderModel order;
  final bool isSelected;
  final Function(OrderModel) onSelect;
  final Function(OrderModel) onNavigate;

  const OrderItemTile({
    required this.order,
    required this.isSelected,
    required this.onSelect,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(
          vertical: 6.h, horizontal: 12.w), // Responsive margin
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16.r), // Responsive radius
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.5),
          width: 1.w, // Responsive border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r, // Responsive blur radius
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavigate(order),
          onLongPress: () => onSelect(order),
          borderRadius: BorderRadius.circular(16.r), // Responsive radius
          child: Padding(
            padding: EdgeInsets.all(16.w), // Responsive padding
            child: Row(
              children: [
                _buildSelectionIndicator(context),
                SizedBox(width: 12.w), // Responsive spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildOrderId(context),
                        ],
                      ),
                      SizedBox(height: 8.h), // Responsive spacing
                      _buildOrderDetails(context),
                      SizedBox(height: 8.h), // Responsive spacing
                      _buildDateTime(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24.w, // Responsive width
      height: 24.h, // Responsive height
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 2.w, // Responsive border width
        ),
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: 16.sp, // Responsive icon size
              color: theme.colorScheme.onPrimaryContainer,
            )
          : null,
    );
  }

  Widget _buildOrderId(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 8.w, vertical: 4.h), // Responsive padding
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r), // Responsive radius
      ),
      child: Text(
        'طلب ${order.id}#',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 14.sp, // Responsive font size
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: 20.sp, // Responsive icon size
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 8.w), // Responsive spacing
        Expanded(
          child: Text(
            order.user?.name ?? 'غير معروف',
            style: TextStyle(
              fontSize: 16.sp, // Responsive font size
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 16.w), // Responsive spacing
        Icon(
          Icons.local_phone_outlined,
          size: 20.sp, // Responsive icon size
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 8.w), // Responsive spacing
        Text(
          order.user?.phone ?? 'غير متوفر',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14.sp, // Responsive font size
          ),
        ),
      ],
    );
  }

  Widget _buildDateTime(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 18.sp, // Responsive icon size
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        SizedBox(width: 6.w), // Responsive spacing
        Text(
          _formatDate(order.date!),
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 13.sp, // Responsive font size
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
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
}
