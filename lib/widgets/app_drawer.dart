import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/auth.dart';
import 'package:flutter_complete_guide/screens/manage_products_screen.dart';
import 'package:provider/provider.dart';

import'../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Harsh!'),//name of the user logged in
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),

          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),

            Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Log Out'),
            onTap: () async  {
             
              bool isLogOut= await showDialog(context: context, builder:(bctx)=>AlertDialog(
                content: Text('Do you want to log out ?'),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.of(context).pop(true);
                  }, child: Text('YES')),
                   TextButton(onPressed: (){
                    Navigator.of(context).pop(false);
                  }, child: Text('NO')),
                ],
              ));

               isLogOut?Provider.of<Auth>(context,listen: false).logout(): print('Not logged out');
            },
          ),
        ],
      ),
    );
  }
}