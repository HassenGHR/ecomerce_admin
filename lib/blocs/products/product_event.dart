import 'package:admin/models/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class SaveProductToLocal extends ProductEvent {
  final ProductModel product;
  SaveProductToLocal(this.product);
  @override
  List<Object?> get props => [product];
}

class LoadProductFromLocal extends ProductEvent {
  final String productId;
  LoadProductFromLocal(this.productId);
  @override
  List<Object?> get props => [productId];
}

class RemoveProductFromLocal extends ProductEvent {
  final String productId;

  RemoveProductFromLocal(this.productId);
  @override
  List<Object?> get props => [productId];
}

class UpdateProduct extends ProductEvent {
  final ProductModel product;
  UpdateProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class RemoveProduct extends ProductEvent {
  final String id;
  RemoveProduct(this.id);
  @override
  List<Object?> get props => [id];
}

class AddProduct extends ProductEvent {
  final ProductModel product;
  AddProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateProductAvailability extends ProductEvent {
  final String productId;
  final bool isAvailable;
  UpdateProductAvailability(this.productId, this.isAvailable);
  @override
  List<Object?> get props => [productId, isAvailable];
}

class _ProductsUpdated extends ProductEvent {
  final List<ProductModel> products;
  final Map<String, bool> availability;

  _ProductsUpdated({
    required this.products,
    required this.availability,
  });
  @override
  List<Object?> get props => [products, availability];
}

class UploadProductImage extends ProductEvent {
  final String imagePath;

  const UploadProductImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class RemoveProductImage extends ProductEvent {
  final String imageUrl;

  const RemoveProductImage(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class _ProductError extends ProductEvent {
  final String message;
  _ProductError(this.message);
}
