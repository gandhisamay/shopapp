import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../providers/products_provider.dart';

enum FilterOptionsPopUp {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  // const ProductsOverviewScreen({ Key? key }) : super(key: key);

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;

  @override
  void initState() { //
    // TODO: implement initState
    // Provider.of<Products>(context).fetchAndSetProducts(); //WONT WORK
    //only if we use this in init state then we need to give listen false

    //method 2
    // Future.delayed(Duration.zero).then((_){
    //    Provider.of<Products>(context).fetchAndSetProducts();
    // });

    super.initState();
  }
  var _isInit=true;

  var _isLoading =false;

//do not use async here and change the type of value returned by the didChangeDependencies 
  @override
  void didChangeDependencies() { //after widget fully initailaised but before build ran
    if(_isInit) {  
       setState(() {
           _isLoading=true;
        });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
           _isLoading=false;
        });
       
      });
    }
    _isInit=false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // print('Build Method of Build OverView Screen Ran');

    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
            //a small pop up
            onSelected: (FilterOptionsPopUp selectedValue) {
              setState(() {
                if (selectedValue == FilterOptionsPopUp.Favorites) {
                  //0=>Favorites
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
                print('setState ran');
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (c) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value:
                    FilterOptionsPopUp.Favorites, //define enum for readability
              ),
              PopupMenuItem(
                child: Text('Show All Products'),
                value: FilterOptionsPopUp.All,
              )
            ],
          ), //{List<PopupMenuEntry<dynamic>> Function(BuildContext) itemBuilder}

          Consumer<Cart>(
            builder: (context, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, CartScreen.routeName);
                }),
          ),
          //this icon button is automatically connected to 'ch'
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? Center(child:CircularProgressIndicator()):ProductsGrid(_showOnlyFavorites),
    );
  }
}
