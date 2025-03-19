import 'package:admin/widgets/reuseable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:admin/blocs/products/product_bloc.dart';
import 'package:admin/blocs/products/product_state.dart';
import 'package:admin/widgets/product_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  String _searchQuery = "";
  String _selectedCategoryId = "حلويات";
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> categories = [
    {
      'id': 1,
      'name': 'حلويات',
      'image': "assets/images/gattaux.png",
      'color': Color(0xFFFFE0E0),
    },
    {
      'id': 2,
      'name': 'مشروبات',
      'image': "assets/images/drinks.jpg",
      'color': Color(0xFFE0F7FF),
    },
    {
      'id': 3,
      'name': 'شاي',
      'image': "assets/images/tea.jpg",
      'color': Color(0xFFE6FFE0),
    },
    {
      'id': 4,
      'name': 'مكسرات',
      'image': "assets/images/nuts.jpg",
      'color': Color(0xFFFFF0E0),
    },
    {
      'id': 5,
      'name': 'تغليف',
      'image': "assets/images/emballage.jpg",
      'color': Color(0xFFE0E6FF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
        appBar: _buildAppBar(theme),
        body: Column(
          children: [
            _buildSearchBar(theme),
            _buildCategories(theme),
            _buildProductsGrid(theme),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ReusableWidgets.showProductForm(context);
          },
          label: Text('Add Product', style: theme.textTheme.labelLarge),
          icon: Icon(
            Icons.add_circle_outline,
            size: 24,
          ),
          backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
          elevation: 6,
          highlightElevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          extendedPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          enableFeedback: true,
          // Add a gradient effect
          foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
          // Add a hover effect
          hoverColor: theme.floatingActionButtonTheme.hoverColor,
          // Add a splash effect
          splashColor: theme.floatingActionButtonTheme.splashColor,
          // Add a tooltip
          tooltip: 'Add a new product',
          // Optional: Wrap with Hero widget for transition animation
          heroTag: 'add_product_fab',
        ));
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.appBarTheme.backgroundColor,
      title: Text('Products', style: theme.appBarTheme.titleTextStyle),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: theme.iconTheme.color),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.sort, color: theme.iconTheme.color),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: theme.inputDecorationTheme.hintStyle,
          prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
          suffixIcon: Icon(Icons.mic, color: theme.iconTheme.color),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategories(ThemeData theme) {
    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategoryId == category['name'];

          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? 1 + (_animation.value * 0.1) : 1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId =
                          isSelected ? null : category['name'];
                    });
                    if (isSelected) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                category['color'],
                                category['color'].withOpacity(0.4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : theme.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: category['color'].withOpacity(0.3),
                          ),
                          child: ClipOval(
                            // Ensures the image is clipped into a circular shape
                            child: Image.asset(
                              category['image'],
                              height:
                                  65, // Adjust size to fit within the circular container
                              width: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          category['name'],
                          style: isSelected
                              ? theme.textTheme.titleMedium
                                  ?.copyWith(color: Colors.black)
                              : theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(ThemeData theme) {
    return Expanded(
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            );
          }
          if (state is ProductsLoaded) {
            final filteredProducts = state.products.where((product) {
              final matchesSearchQuery =
                  product.title.toLowerCase().contains(_searchQuery);
              final matchesCategory = _selectedCategoryId == null ||
                  product.category == _selectedCategoryId;

              return matchesSearchQuery && matchesCategory;
            }).toList();

            if (filteredProducts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.iconTheme.color,
                    ),
                    SizedBox(height: 16),
                    Text('No products found',
                        style: theme.textTheme.headlineMedium),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Hero(
                  tag: 'product-${product.id}',
                  child: ProductCard(product: product),
                );
              },
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Error loading products',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
