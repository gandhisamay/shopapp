//Widget for each grid item that gets rendered on the product overview screen

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/auth.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // const ProductItem({ Key? key }) : super(key: key);
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    // print('Product_item build method ran');

    final product = Provider.of<Product>(context,
        listen: false); //looks for the nearest provider
    //we are listening to  "create:(c)=>  products[index]," this provider =>according to which product has been favorited
    //listen: false => wont trigger notify listeners ,but will still change the data =>wont be affected in ui

    final cart = Provider.of<Cart>(context,
        listen: false); //we are not interested in changes to the cart
   final authData =Provider.of<Auth>(context,listen:false);
    // print('Product rebuilds in product_item.dart');
    return ClipRRect(
      //(ctx=>instance of the ChangeNotifier,
      //nearest instance it found of that data)
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          splashColor: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridTileBar(
            //The widget to show over the bottom of this grid tile.//Typically a [GridTileBar].
            backgroundColor: Colors.black87,

            leading: Consumer<Product>(
              //listener

              builder: (ctx, product, child) => (IconButton(
                //only this code is rebuild when the data changes
                icon: Icon(
                    product.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Theme.of(context).accentColor),
                //here we need Product data to know if it has already been marked favorite
                onPressed: () {
                  //pass the token here 
                  product.toggleFavoriteStatus(productId: product.id,token: authData.tokenData,userId:authData.userId);
                },
              )),
            ),
            //A widget to display before the title.
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),

            trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);

                //show an info popup to confirm if the user wants to add in the cart
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                //hide snackbar if there is already one on the screen
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Container(child: Text('Added item to cart')),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(label: 'UNDO', onPressed: (){
                    cart.undoAddingItemInCart(product.id);
                  }),
                )); //drawer opens when we click this
                //gains a connection between the nearest widget that controls this
                //page i.e the  scaffold in products overview file
                //Scaffold.of(context).openDrawer(); //drawer opens when we click this
              },
            ),
          ),
        ),
      ),
    );
  }
}
