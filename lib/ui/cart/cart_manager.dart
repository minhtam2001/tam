import 'package:flutter/material.dart';
import 'package:myshop/ui/cart/cart_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../cart/cart_manager.dart';

class CartManager with ChangeNotifier{
  Map<String, CartItem> _items = {
    'p1': CartItem(
      id: 'c1',
      title: 'Red Shirt',
      price: 29.99,
      quantity: 2,
    ),
  };

  int get productCount {
    return _items.length;
  }

  List<CartItem> get products {
    return _items.values.toList();
  }

  Iterable<MapEntry<String, CartItem>> get productEntries {
    return {..._items}.entries;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
     });
     return total;
  }

  void addItem(Product product) {
    if(_items.containsKey(product.id)) {
      _items.update(
        product.id!,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id!,
        () => CartItem(
          id: 'c${DateTime.now().toIso8601String()}', 
          title: product.title, 
          quantity: 1, 
          price: product.price
        ),   
      );
    }
    notifyListeners();
  }
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]?.quantity as num > 1) {
      _items.update(
        productId, 
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
  void clear() {
    _items = {};
    notifyListeners();
  }
}