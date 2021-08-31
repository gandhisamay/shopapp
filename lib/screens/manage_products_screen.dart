//for us to add or delete files
//list of all the products of the user
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/cart_item.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';
import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  // const UserProductsScreen({ Key? key }) : super(key: key);

  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context, listen: false);
    //will retrigger build and then a future builder so infinite loop
    print('rebuilding ...');

    return Scaffold(
      appBar: AppBar(
        title: Text(' Manage products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              })
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (_, snapshot) => (snapshot.connectionState ==
                ConnectionState.waiting)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(
                    context), //{Future<void> Function() onRefresh}
                child: Consumer<Products>(
                  builder: (c, productsData, _) {
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: Consumer<Products>(
                        builder: (ctx, products, child) {
                          return ListView.builder(
                              itemCount: productsData.items.length,
                              itemBuilder: (c, i) {
                                return UserProductItem(
                                    id: productsData.items[i].id,
                                    title: productsData.items[i].title,
                                    imageUrl: productsData.items[i].imageUrl);
                              });
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
//ListView.builder(itemCount: ,itemBuilder: (ctx,index){})
