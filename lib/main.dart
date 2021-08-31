import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/auth.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/screens/auth_screen.dart';
import 'package:flutter_complete_guide/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import './screens/edit_product_screen.dart';
import 'screens/manage_products_screen.dart';
import './screens/orders_screen.dart';
import './providers/orders.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // print('Build Method of Main Ran');

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          //when auth object changes this provider is also updated
          ChangeNotifierProxyProvider<Auth, Products>(
            //<data you depend on, actual provider>
            //depends on another provider defined before this
            //cleans up the data once used=>eg screen replaced
            //at this point we have access to the previously provided objets
            //whenever auth changes this provider rebuilds
            create: (ctx) => Products('token', [], 'user id'),
            // Provider.of<Auth>(context, listen: false).tokenData,
            // Provider.of<Products>(context, listen: false).items),

            //when we use the update method then the previous state gets erased
            update: (ctx, auth, previousProducts) => Products(
                auth.tokenData,
                previousProducts == null ? [] : previousProducts.items,
                auth.userId),

            //previousProducts->previous state of the products
            //we also need to initialize the private properties of the class to avoid to losse them
            // create: (ctx)=>Products(),
            //<Auth,Products>=>2nd arg ->type of data provided by the provider
          ), //new one and the same instance of the provider class to the MaterialApp and all its children
          //whenever you reuse an existing object => use .value constructor
          //whenever you instantiate a class =>create a new object on a class ==>use create method
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('token', [], 'user id'),
            update: (ctx, auth, previousOrders) => Orders(
                auth.tokenData,
                previousOrders == null ? [] : previousOrders.orders,
                auth.userId),
          ),
        ],
        child: Consumer<Auth>(
          //material app rebuild whenever data in auth provider changes
          builder: (c, auth, _) {
            //finds nearest instance of auth
            return MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.orange,
                  fontFamily: 'Lato'),
              home: auth.isAuth
                  ? ProductsOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (c, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen()),

              //after login/signup we want to change the home sceen =>so build should run again .
              //authenticatd ->yes =>show ProductsOverview screen
              routes: {
                // AuthScreen.routeName:(ctx)=>AuthScreen(),
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen(),
              },
              //we need to provide the data at the highest point of the widget tree ,
              //such that it is one hierarchy above the listeners
              //eg -> if we need a data in product_item.dart then we could provide the data in the product_overview_screen.dart
              //=>not necessary to provide in the main.dart
            );
          },
        ));
  }
}
