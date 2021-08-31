import 'package:flutter/material.dart';
import '../widgets/cart_item.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  // const CartScreen({ Key? key }) : super(key: key);

  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(), //takes up all the available space
                  Chip(
                    //rounded rectangle container type
                    label: Text(
                      '\$' + cart.totalAmountInCart.toString(),
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline1.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ]),
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx, i) => CartItemWidget(
                  title: cart.items.values.toList()[i].title,
                  //The values are iterated in the order of their corresponding keys.
                  //This means that iterating [keys] and [values] in parallel will provide
                  // matching pairs of keys and values.
                  productId: cart.items.keys.toList()[i], //'p4'
                  //keys preserve state when widgets move around in
                  //your widget tree
                  id: cart.items.values
                      .toList()[i]
                      .id, //2021-07-24 21:08:59.497129(Date Time Now)
                  price: cart.items.values.toList()[i].price,
                  quantity: cart.items.values.toList()[i].quantity)),
        )
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {

  var _isLoading=false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmountInCart<=0|| _isLoading) ? null: () async  {
        setState(() {
          _isLoading=true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
            //we are not interested in ui changes ->just the data change reqd
            widget.cart.items.values.toList(),
            widget.cart.totalAmountInCart);
                 
         setState(() {
          _isLoading=false;
        });         
        widget.cart.clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: 
          Text('Order Placed Successfully'),
          duration: Duration(seconds: 2),
          ));
      },
      child: _isLoading? Center(child:CircularProgressIndicator()):Text('ORDER NOW'),
    );
  }
}
//IMPORTANT ->
// void main() {
//   Map<String, int> _items = {
//     'id1': 100,
//     'id2': 200,
//   };
//   Map<String, int> mapvar = {..._items};
//   print({..._items}); //{id: 100, id2: 200}

//   print(mapvar.values); //(100, 200)
//   print(mapvar.values.toList()); //[100, 200]
//   print(mapvar.values.toList()[1]); //200

//   print(mapvar.keys); //(id, id2)
//   print(mapvar.keys.toList()); //[id1, id2]
//   print(mapvar.keys.toList()[1]); //id2
// }
