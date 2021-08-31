//widget for each card in the Your Cart screen



import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItemWidget extends StatelessWidget {
  // const CartItemWidget({ Key? key }) : super(key: key);

  final String id;
  final String productId;   
  final double price;
  final String title;
  final int quantity;

  CartItemWidget(
      {this.id, this.productId, this.price, this.title, this.quantity});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart, //right to left

      background: Container(
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
      ),
      //A widget that is stacked behind the child. If secondaryBackground is also
      // specified then this widget only appears when the child has been dragged down or to the right.

      onDismissed: (direction) {
        //direction-> we can configure different functions for each direction
        Provider.of<Cart>(context, listen: false).removeItem(productId);
        print(productId); //'p4'
        print(id); //2021-07-24 21:08:59.497129
      },

      confirmDismiss: (direction) {
        //{Future<bool> Function(DismissDirection) confirmDismiss}
        //If the returned Future completes true, then this widget will be dismissed, otherwise it
        // will be moved back to its original location.

        //Future<T> showDialog<T> ,  Returns a [Future] when the dialog box closes that
        //resolves to the value (if any) that was passed to [Navigator.pop] when the dialog was
        // closed.

        return showDialog(
            context: context,
            builder: (bCtx) => AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text('Do you want to remove the item from cart?'),
                  elevation: 5,
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);  
                          //this false is returned as the future to the showDialog
                        },
                        child: Text('No')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Yes'))
                  ],
                ));
      },

      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(child: Text('\$ $price ')),
            ),
            title: Text(title),
            subtitle: Text('Total:\$' + (price * quantity).toString()),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
