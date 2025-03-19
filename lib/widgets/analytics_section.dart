import 'package:flutter/material.dart';
import 'package:admin/blocs/analytics/analytics_bloc.dart';
import 'package:admin/blocs/analytics/analytics_event.dart';
import 'package:admin/blocs/analytics/analytics_state.dart';
import 'package:admin/models/order_model.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalyticsSection extends StatefulWidget {
  @override
  _AnalyticsSectionState createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection>
    with SingleTickerProviderStateMixin {
  String selectedFilter = '7 Days';
  final dateFormat = DateFormat('d MMMM yyyy');
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  DateTime parseDate(String dateStr) {
    if (dateStr.contains('T')) {
      return DateTime.parse(dateStr);
    } else {
      return dateFormat.parse(dateStr);
    }
  }

  List<OrderModel> filterOrders(List<OrderModel> orders, String filter) {
    final currentDate = DateTime.now();
    Duration duration;

    // Determine the duration based on the filter
    if (filter == '7 Days') {
      duration = Duration(days: 7);
    } else if (filter == 'Last Month') {
      duration = Duration(days: 30); // Approximation for 1 month
    } else {
      return orders; // 'All Time' returns all orders without filtering
    }

    // Filter orders based on the duration
    return orders.where((order) {
      final orderDate =
          parseDate(order.date!); // Ensure parseDate works correctly
      return orderDate.isAfter(currentDate.subtract(duration));
    }).toList();
  }

  Map<String, dynamic> _calculateAnalytics(
      List<OrderModel> orders, String filter) {
    final DateTime now = DateTime.now();

    // Define the filtering logic
    DateTime startDate;
    if (filter == '7 Days') {
      startDate = now.subtract(Duration(days: 7));
    } else if (filter == 'Last Month') {
      startDate = DateTime(now.year, now.month - 1, now.day);
    } else {
      startDate = DateTime(1970); // All-time (no restriction)
    }

    // Filter orders based on the selected time range
    final filteredOrders = orders.where((order) {
      final orderDate = _parseDate(order.date!);
      return orderDate != null && orderDate.isAfter(startDate);
    }).toList();

    // Initialize counters for analytics
    final itemCount = <String, int>{};
    final customerCount = <String, int>{};

    for (var order in filteredOrders) {
      // Count items sold
      if (order.items != null) {
        for (var item in order.items!) {
          itemCount[item.item.title] =
              (itemCount[item.item.title] ?? 0) + item.quantity;
        }
      }

      // Count customer orders
      final customerId = order.user?.name;
      if (customerId != null) {
        customerCount[customerId] = (customerCount[customerId] ?? 0) + 1;
      }
    }

    // Determine the most sold item and its count
    String? mostSoldItem;
    int mostSoldItemCount = 0;
    if (itemCount.isNotEmpty) {
      final mostSoldEntry =
          itemCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      mostSoldItem = mostSoldEntry.key;
      mostSoldItemCount = mostSoldEntry.value;
    }

    // Determine the best customer and their order count
    String? bestCustomer;
    int bestCustomerOrders = 0;
    if (customerCount.isNotEmpty) {
      final bestCustomerEntry =
          customerCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      bestCustomer = bestCustomerEntry.key;
      bestCustomerOrders = bestCustomerEntry.value;
    }

    return {
      'totalOrders': filteredOrders.length,
      'itemCount': itemCount,
      'bestCustomer': bestCustomer,
      'bestCustomerOrders': bestCustomerOrders,
      'mostSoldItem': mostSoldItem,
      'mostSoldItemCount': mostSoldItemCount,
    };
  }

// Helper function to parse dates
  DateTime? _parseDate(String date) {
    try {
      // Try parsing ISO format
      return DateTime.parse(date);
    } catch (e) {
      // If not ISO format, try parsing a custom format
      try {
        final formatter =
            DateFormat('d MMMM yyyy'); // Example: 15 September 2024
        return formatter.parse(date);
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.canvasColor,
              theme.canvasColor.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(theme),
              SliverToBoxAdapter(
                child: BlocProvider(
                  create: (context) =>
                      OrderAnalyticsBloc()..add(FetchOrdersEvent()),
                  child: BlocBuilder<OrderAnalyticsBloc, OrderAnalyticsState>(
                    builder: (context, state) {
                      if (state is OrderAnalyticsLoading) {
                        return _buildLoadingState(theme);
                      } else if (state is OrderAnalyticsLoaded) {
                        return _buildAnalyticsContent(state, theme);
                      } else if (state is OrderAnalyticsError) {
                        return _buildErrorState(state);
                      }
                      return _buildWelcomeState();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 50.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.appBarTheme.backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Analytics Dashboard', style: theme.textTheme.titleLarge),
        background: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(color: theme.cardColor),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text('Preparing Your Analytics...',
                style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    ).animate().fadeIn(duration: Duration(milliseconds: 600));
  }

  Widget _buildAnalyticsContent(OrderAnalyticsLoaded state, ThemeData theme) {
    final analytics = _calculateAnalytics(state.orders, selectedFilter);
    final filteredOrders = filterOrders(state.orders, selectedFilter);
    final totalPrices =
        filteredOrders.map((order) => order.totalPrice!).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeFilterSection(theme),
          SizedBox(height: 24),
          _buildAnalyticsCards(analytics),
          SizedBox(height: 24),
          _buildOrderTrendCard(totalPrices, theme),
        ]
            .animate(interval: Duration(milliseconds: 100))
            .slideX(duration: Duration(milliseconds: 600))
            .fadeIn(duration: Duration(milliseconds: 800)),
      ),
    );
  }

  Widget _buildTimeFilterSection(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.iconTheme.color),
          items: ['7 Days', 'Last Month', 'All Time'].map((String filter) {
            return DropdownMenuItem<String>(
              value: filter,
              child: Text(filter, style: theme.textTheme.titleMedium),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedFilter = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                title: 'Total Orders',
                value: analytics['totalOrders'].toString(),
                icon: Icons.shopping_cart_outlined,
                gradient: [Color(0xFF6AC8FF), Color(0xFF4A90E2)],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildDetailCard(
                title: 'Most Sold',
                value: analytics['mostSoldItem'] ?? 'N/A',
                subtitle: '${analytics['mostSoldItemCount']} units',
                icon: Icons.inventory_2_outlined,
                gradient: [Color(0xFFFFB157), Color(0xFFFF7B54)],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildDetailCard(
          title: 'Top Customer',
          value: analytics['bestCustomer'] ?? 'N/A',
          subtitle: '${analytics['bestCustomerOrders']} orders',
          icon: Icons.person_outline,
          gradient: [Color(0xFF7ED56F), Color(0xFF28B485)],
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    String? subtitle,
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              if (subtitle != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTrendCard(List<double> totalPrices, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Orders Spend Trend', style: theme.textTheme.titleLarge),
          SizedBox(height: 24),
          Container(
            height: 200,
            child: Sparkline(
              data: totalPrices,
              lineWidth: 2,
              lineColor: Theme.of(context).primaryColor,
              fillMode: FillMode.below,
              fillGradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              useCubicSmoothing: true,
              cubicSmoothingFactor: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(OrderAnalyticsError state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.withOpacity(0.8),
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<OrderAnalyticsBloc>().add(FetchOrdersEvent());
              },
              child: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.8),
            ),
            SizedBox(height: 24),
            Text(
              'Welcome to Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your business insights are loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: Duration(milliseconds: 800));
  }
}
