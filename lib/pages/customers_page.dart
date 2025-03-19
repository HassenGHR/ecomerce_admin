import 'package:admin/blocs/auth/auth_bloc.dart';
import 'package:admin/blocs/auth/auth_event.dart';
import 'package:admin/blocs/auth/auth_state.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/repositories/local_auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  List<UserModel> customers = [];
  List<UserModel> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchSubject.add(_searchController.text.toLowerCase());
    });

    _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customers);
      } else {
        filteredCustomers = customers.where((customer) {
          return customer.name.toLowerCase().contains(query) ||
              customer.email.toLowerCase().contains(query) ||
              customer.phone.toLowerCase().contains(query) ||
              customer.address.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        authRepository: context.read<LocalAuthRepository>(),
      )..add(FetchCustomers()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Customer Directory',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is CustomersLoaded) {
              customers = state.customers;
              filteredCustomers = List.from(customers);
              return _buildContent();
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<LoginBloc>().add(FetchCustomers());
            },
            child: filteredCustomers.isEmpty
                ? const Center(
                    child: Text(
                      'No customers found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return _CustomerCard(customer: customer);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search customers...',
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
          prefixIcon:
              Icon(Icons.search, color: Theme.of(context).iconTheme.color),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final UserModel customer;

  const _CustomerCard({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 2.w, // Responsive border width
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: _buildCustomerAvatar(customer),
          title: Text(
            customer.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
              color:
                  Theme.of(context).textTheme.headlineMedium?.backgroundColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.email,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.color
                        ?.withOpacity(0.5)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 7),
                  Text(customer.phone),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              _showCustomerDetails(context, customer);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar(UserModel customer) {
    return Hero(
      tag: 'customer_avatar_${customer.id}',
      child: CircleAvatar(
        radius: 30,
        backgroundImage: customer.imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(customer.imageUrl)
            : null,
        child: customer.imageUrl.isEmpty
            ? Text(
                customer.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
        backgroundColor: Colors.deepPurple[200],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, UserModel customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 2.w, // Responsive border width
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'customer_avatar_${customer.id}',
              child: CircleAvatar(
                radius: 50,
                backgroundImage: customer.imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(customer.imageUrl)
                    : null,
                child: customer.imageUrl.isEmpty
                    ? Text(
                        customer.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              customer.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.displayMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.email, customer.email, context),
            _buildDetailRow(Icons.phone, customer.phone, context),
            _buildDetailRow(Icons.location_on, customer.address, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
