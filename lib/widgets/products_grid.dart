import 'package:admin/blocs/products/product_bloc.dart';
import 'package:admin/blocs/products/product_event.dart';
import 'package:admin/blocs/products/product_state.dart';
import 'package:admin/pages/products_page.dart';
import 'package:admin/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ProductsLoaded) {
          final products =
              state.products.take(2).toList(); // Display only 2 products
          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title and See All Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to products page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductsPage(), // Replace with your ProductsPage
                            ),
                          );
                        },
                        child: Text(
                          'See All',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                // Products Grid
                GridView.builder(
                  padding: EdgeInsets.zero, // Remove default padding
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 0, // Adjust spacing between rows
                    crossAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                ),
              ],
            ),
          );
        }
        context.read<ProductBloc>().add(LoadProducts());
        return SliverToBoxAdapter(
          child: Center(child: Text('Error loading products')),
        );
      },
    );
  }
}
