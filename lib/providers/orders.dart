import './cart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  // final String title;
  final String id;
  final double amount;
  final List<CartItem> products; //to find which products were ordered
  final DateTime dateTime;

  OrderItem(
      // {@required this.title,
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String authToken;
  final String userId;
  Orders(this.authToken, this._orders,this.userId);

  List<OrderItem> get orders {
    return [..._orders]; //so that we cant edit orders outside the class
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shop-app-16d20-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');

    try {
      final response = await http.get(url);
      //  print(json.decode(response.body)); //{-MfsICVr2F_wrMThPvoi:
      // {amount: 37.76, dateTime: 2021-07-30T22:13:42.381138,
      //products: [{id: 2021-07-30 22:13:38.042809, price: 15.77, quantity: 15.77, title: Trousers },

      final List<OrderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ),
                )
                .toList(),
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
      // "error" : "Permission denied" when a non authenticated user gets the access
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // _orders.insert(index, element) =>to add at the beginning of the list
    //Inserts [element] at position [index] in this list.
    //This increases the length of the list by one and shifts all objects at or after
    //the index towards the end of the list.

    //currently the orders are available to all the people ->to do :URGent
    final url = Uri.parse(
        'https://shop-app-16d20-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');

    final timeStamp = DateTime.now();

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(), //to easily recreate dateTime
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'price': cp.price,
                    'quantity': cp.price,
                  })
              .toList(),
        }));
    print(response.body); //{"name":"-MfsICVr2F_wrMThPvoi"}

    _orders.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: DateTime.now()),
    );

    notifyListeners();
  }
}
