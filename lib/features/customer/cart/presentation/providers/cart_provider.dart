import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartState {
  final List<CartItem> items;
  CartState({this.items = const []});

  int get totalAmount => items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      final updatedItems = state.items.map((item) {
        if (item.product.id == product.id) {
          return CartItem(product: item.product, quantity: item.quantity + 1);
        }
        return item;
      }).toList();
      state = CartState(items: updatedItems);
    } else {
      state = CartState(items: [...state.items, CartItem(product: product)]);
    }
  }

  void removeProduct(String productId) {
    state = CartState(items: state.items.where((item) => item.product.id != productId).toList());
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

