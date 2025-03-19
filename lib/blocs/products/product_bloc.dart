import 'dart:async';

import 'package:admin/blocs/products/product_event.dart';
import 'package:admin/blocs/products/product_state.dart';
import 'package:admin/models/product_model.dart';
import 'package:admin/repositories/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  StreamSubscription<List<ProductModel>>? _productsSubscription;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<RemoveProduct>(_onRemoveProduct);
    on<UpdateProductAvailability>(_onUpdateProductAvailability);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<UploadProductImage>(_onUploadProductImage);
    on<RemoveProductImage>(_onRemoveProductImage);
    on<SaveProductToLocal>(_onSaveProductToLocal);
    on<RemoveProductFromLocal>(_onRemoveProductFromLocal);

    on<LoadProductFromLocal>(_onLoadProductFromLocal);
  }

  Future<void> _onLoadProductFromLocal(
    LoadProductFromLocal event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading()); // Emit a loading state

    try {
      // Retrieve the product from local storage asynchronously
      final product = await repository.getProductFromLocal(event.productId);

      if (product != null) {
        // Emit the loaded state with the retrieved product
        emit(ProductLoadedFromLocal(product));
      } else {
        // Emit a state indicating the product was not found
        emit(ProductNotFound());
      }
    } catch (error) {
      // Emit an error state if something goes wrong
      emit(ProductError(error.toString()));
    }
  }

  Future<void> _onRemoveProductFromLocal(
    RemoveProductFromLocal event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading()); // Emit a loading state

    try {
      // Call the repository method to remove the product from local storage
      await repository.removeProductFromLocal(event.productId);

      // Emit a success state after the product is removed
      emit(ProductRemoved());
    } catch (error) {
      // Emit an error state if removing the product fails
      emit(ProductError(error.toString()));
    }
  }

  Future<void> _onSaveProductToLocal(
    SaveProductToLocal event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading()); // Emit a loading state

    try {
      // Convert the product to a JSON string
      await repository.saveProductToLocal(event.product);

      // Emit the updated state, indicating that the product was saved
      emit(ProductSaved());
    } catch (error) {
      // Emit an error state if saving fails
      emit(ProductError(error.toString()));
    }
  }

  FutureOr<void> _onUploadProductImage(
      UploadProductImage event, Emitter<ProductState> emit) async {
    try {
      emit(ProductsLoading());

      final imageUrl = await repository.uploadImage(event.imagePath);

      // You might want to store this URL or emit it in a success state
      emit(ProductSuccess(ProductModel(
        id: '', // This is a temporary product just to hold the image URL
        imageUrls: [
          {'url': imageUrl}
        ],
        title: '',
        description: '',
        category: '',
        color: Colors.blue,
        price: 0,
        priceDescription: '',
        isAvailable: true,
      )));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  FutureOr<void> _onRemoveProductImage(
      RemoveProductImage event, Emitter<ProductState> emit) async {
    try {
      emit(ProductsLoading());

      await repository.removeImage(event.imageUrl);

      emit(ProductInitial());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());

    // Cancel any previous subscription
    await _productsSubscription?.cancel();

    // Subscribe to the products stream
    try {
      _productsSubscription = repository.watchProducts().listen(
        (products) {
          // Use an internal event to update the state
          add(_ProductsUpdated(products));
        },
      );
    } catch (error) {
      emit(ProductError(error.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.addProduct(event.product);
    } catch (e) {
      emit(ProductError('Failed to add product: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.updateProductInDatabase(event.product);
    } catch (e) {
      emit(ProductError('Failed to update product: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveProduct(
    RemoveProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.deleteProductById(event.id);
    } catch (e) {
      emit(ProductError('Failed to remove product: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProductAvailability(
    UpdateProductAvailability event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.updateProductAvailability(
        event.productId,
        event.isAvailable,
      );
    } catch (e) {
      emit(ProductError('Failed to update availability: ${e.toString()}'));
    }
  }

  void _onProductsUpdated(
    _ProductsUpdated event,
    Emitter<ProductState> emit,
  ) {
    final availability = {
      for (var product in event.products) product.id: product.isAvailable,
    };
    emit(ProductsLoaded(
      products: event.products,
      availability: availability,
    ));
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}

class _ProductsUpdated extends ProductEvent {
  final List<ProductModel> products;

  _ProductsUpdated(this.products);
}
