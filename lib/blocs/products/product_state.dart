import 'package:admin/models/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductsLoading extends ProductState {}

class ProductSuccess extends ProductState {
  final ProductModel product;

  ProductSuccess(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductLoadedFromLocal extends ProductState {
  final ProductModel product;

  ProductLoadedFromLocal(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductNotFound extends ProductState {}

class ProductRemoved extends ProductState {}

class ProductSaved extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;
  final Map<String, bool> availability;

  ProductsLoaded({
    required this.products,
    required this.availability,
  });
  @override
  List<Object?> get props => [products, availability];

  bool isAvailable(String productId) {
    return availability[productId] ?? false;
  }
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
  @override
  List<Object?> get props => [message];
}
