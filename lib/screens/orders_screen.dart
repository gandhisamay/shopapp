import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import '../widgets/order_item.dart';
import '../widgets/cart_item.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatefulWidget { 
  //convert to stateful to use didChangeDependencies etc
  // const OrdersScreen({ Key? key }) : super(key: key);

  static const routeName = '/orders-screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  Future _ordersFuture () {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  Future storeFutureOrders;

  void initState(){
  storeFutureOrders= _ordersFuture();
  super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context); //we would run into an 
    // infinite loop as we notify the listeners here =>as build would keep building 
    // =>solution =>use a consumer 
    print('build orders');

    return Scaffold(
        appBar: AppBar(
          title: Text('Orders Screen'),
        ),
        drawer: AppDrawer(),
        //as we can do this witout using stateful 
        body: FutureBuilder( //starts listening to that
        //builder gets the current snapshot of the future =>so that we can build different content based on the future
          future:storeFutureOrders, //by this we ensure that no more future is created as it is a stateful widget 
          //and the rest if the state can build anyways it wants 
              
          builder: (ctx, dataSnapshot) { //dataSnapshot which is returned by the future and the
          // widget that we want to build depends on the futures data 
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error == null) { //np error 
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) {
                    return ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, index) {
                          return OrderItemWidget(orderData.orders[index]);
                        });
                  },
                );
              } else {
                return Center(child: Text(dataSnapshot.error.toString()));
                //..do error handling stuff 
              }
            }
          },
        ));
  }
}
