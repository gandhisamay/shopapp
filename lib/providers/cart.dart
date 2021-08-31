import 'package:flutter/material.dart';

class CartItem {
  final String id; //not the id of the product
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {@required this.title,
      @required this.id, //id: DateTime.now().toString(),
      @required this.price,
      @required this.quantity});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {}; //id =>CartItem map (string is the id)

  Map<String, CartItem> get items {
    return {..._items};   //
  }

  int get itemCount {
    return _items
        .length; //count of each different objects regardless of their individual quantity
  }

  double get totalAmountInCart {
    double total = 0.0;

    _items.forEach((key, cartItem) {
      //Applies [action] to each key/value pair of the map.
      total = total + cartItem.price * cartItem.quantity;
    });

    return total;
  }

  void addItem(String productId, double price, String title) {
    //productId ='p4' example
    //if item already present just increase quantity
    if (_items.containsKey(productId)) {
      //change quantity
      _items.update(
          //Updates the value for the provided [key].
          productId,
          (existingCartItemValue) => CartItem(
              id: existingCartItemValue.id,
              title: existingCartItemValue.title,
              price: existingCartItemValue.price,
              quantity: existingCartItemValue.quantity + 1));
      //existingCartItemValue =>automatically has the existing data
    } else {
      _items.putIfAbsent(
          //Look up the value of [key], or add a new entry if it isn't there.
          productId,
          () => CartItem(
              //a CartItem object is added in _items list
              title: title,
              id: DateTime.now().toString(),
              price: price,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    print(productId); //p4
    _items.remove(productId); //the key is 'productId'
    notifyListeners();
  }

  void clearCart() {
    //after we press the order button the cart should be cleared
    _items = {};
    notifyListeners();
  }

  void undoAddingItemInCart(String productId) {
    // _items.removeWhere((key, value) => value.id==productId);
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      print(productId);
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              title: existingCartItem.title,
              id: existingCartItem.id,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity - 1));
    }
    else { //qunatity =1 =>completely remove that product 
      _items.remove(productId); //these are the methods applied on the map 
    }
    notifyListeners();
  }
}
