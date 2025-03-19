import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:admin/constant/constants.dart';
import 'package:http/http.dart' as http;

import 'package:admin/blocs/orders/order_bloc.dart';
import 'package:admin/blocs/orders/order_event.dart';
import 'package:admin/blocs/orders/order_state.dart';
import 'package:admin/models/order_model.dart';
import 'package:admin/repositories/local_order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

class CustomerMapPage extends StatefulWidget {
  const CustomerMapPage({super.key});

  @override
  State<CustomerMapPage> createState() => _CustomerMapPageState();
}

class _CustomerMapPageState extends State<CustomerMapPage> {
  late GoogleMapController mapController;
  List<Map<String, dynamic>> customers = [];
  bool isDarkMode = false;
  Set<Marker> markers = {};
  BitmapDescriptor? customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _createCustomMarkerIcon();
  }

  Future<void> _createCustomMarkerIcon() async {
    final ByteData data = await rootBundle.load('assets/images/user.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final codec = await instantiateImageCodec(
      bytes,
      targetWidth: 80, // Specify exact width
      targetHeight: 80, // Specify exact height
    );

    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ImageByteFormat.png);

    if (byteData != null) {
      final uint8List = byteData.buffer.asUint8List();
      customMarkerIcon = BitmapDescriptor.fromBytes(uint8List);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc(
        orderRepository: context.read<LocalOrderRepository>(),
      )..add(FetchOrders()),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) async {
        if (!state.isLoading &&
            state.error == null &&
            state.orders.isNotEmpty) {
          final updatedCustomers = await processOrders(state.orders);

          // Update state safely after processing orders
          setState(() {
            customers = updatedCustomers;
          });
          _updateMarkers(); // Make sure this doesn't call setState again
        }
      },
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state.isLoading) return _buildLoadingView();
          if (state.error != null) return _buildErrorView(state.error!);
          if (state.orders.isEmpty) return _buildEmptyView();

          return Scaffold(
            body: Stack(
              children: [
                _buildMap(),
                _buildTopBar(),
                _buildMapControls(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).size.height * 0.35,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _mapButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () =>
                  mapController.animateCamera(CameraUpdate.zoomIn()),
              tooltip: 'Zoom in',
            ),
            _divider(),
            _mapButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () =>
                  mapController.animateCamera(CameraUpdate.zoomOut()),
              tooltip: 'Zoom out',
            ),
            _divider(),
            _mapButton(
              icon: const Icon(Icons.my_location, size: 20),
              onPressed: _goToCurrentLocation,
              tooltip: 'Current location',
            ),
            _divider(),
            _mapButton(
              icon: const Icon(Icons.home, size: 20),
              onPressed: _resetMapView,
              tooltip: 'Reset view',
            ),
            _divider(),
            _mapButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                size: 20,
              ),
              onPressed: _toggleMapStyle,
              tooltip: 'Toggle theme',
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapButton({
    required Icon icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: icon,
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      width: 24,
      color: Colors.black12,
    );
  }

  void _goToCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get current location')),
      );
    }
  }

  void _resetMapView() {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        const LatLng(37.7749, -122.4194),
        12,
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(36.64997, 3.3308),
        zoom: 12,
      ),
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        _setMapStyle();
        if (customers.isNotEmpty) {
          print("mrks:---------------------${markers.first}");
          _updateMarkers();
        }
      },
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      body: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 160,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<OrdersBloc>().add(FetchOrders());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Customers Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'There are no customers to display on the map.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
    _updateMarkers();
  }

  void _updateMarkers() {
    setState(() {
      markers = customers.map((customer) {
        return Marker(
          markerId: MarkerId(customer['name']),
          position: customer['latLng'],
          icon: customMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () => _showCustomerDetails(customer),
        );
      }).toSet();
    });
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              '${customers.length} Customers',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleMapStyle,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMapStyle() {
    setState(() {
      isDarkMode = !isDarkMode;
      _setMapStyle();
    });
  }

  void _setMapStyle() async {
    String style = isDarkMode
        ? '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]}...]' // Add full dark style JSON
        : '[]';
    mapController.setMapStyle(style);
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CustomerDetailsSheet(customer: customer),
    );
  }

  Future<LatLng?> getLatLngFromGoogle(
    String address,
  ) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      } else {
        return null; // Address not found
      }
    } catch (e) {
      print('Error: $e');
      return null; // Error occurred during geocoding
    }
  }

// Update your processOrders method to handle async operation
  Future<List<Map<String, dynamic>>> processOrders(
      List<OrderModel> orders) async {
    final List<Map<String, dynamic>> uniqueUsers = [];
    final Set<String> processedUserIds = {};

    for (final order in orders) {
      try {
        final user = order.user;
        if (user == null || user.id == null) continue;

        // Skip if we've already processed this user
        if (processedUserIds.contains(user.id)) continue;

        final String name = user.name ?? '';
        final String imageUrl = user.imageUrl ?? '';
        final String address = user.address ?? '';

        // Only process if we have valid data
        if (name.isNotEmpty && address.isNotEmpty) {
          // Get coordinates from address
          final LatLng? latLng = await getLatLngFromGoogle(address);
          print("latlng :------------------------------$latLng");

          if (latLng != null) {
            uniqueUsers.add({
              'id': user.id,
              'name': name,
              'latLng': latLng,
              'imageUrl': imageUrl,
              'address': address,
            });
            processedUserIds.add(user.id);
          }
        }
      } catch (e) {
        print('Error processing order: $e');
      }
    }

    print('Processed ${uniqueUsers.length} unique users');
    return uniqueUsers;
  }
}

class CustomerDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> customer;

  const CustomerDetailsSheet({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      maxChildSize: 0.9,
      minChildSize: 0.2,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCustomerHeader(),
                    const Divider(),
                    _buildCustomerInfo(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Hero(
            tag: 'customer-${customer['name']}',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(customer['imageUrl']),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.blue, width: 3),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active Customer',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.location_on,
            'Location',
            '${customer['latLng'].latitude.toStringAsFixed(4)}, '
                '${customer['latLng'].longitude.toStringAsFixed(4)}',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.history,
            'Last Order',
            '2 days ago',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.shopping_bag,
            'Total Orders',
            '12',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
