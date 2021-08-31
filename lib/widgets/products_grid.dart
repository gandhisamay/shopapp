//contains the list view which builds the overview screen
import 'package:flutter/material.dart';

import '../providers/products_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  
  final bool showFavoritesOnly;

  ProductsGrid(this.showFavoritesOnly);

  @override
  Widget build(BuildContext context) {

    final productsData = Provider.of<Products>(context); 

    // print('Build method of the products_grid ran after the provider method');
    //only use this if directly or indirectly some provider
    // has been added to the parent widgets
    //only this child widgets are rebuild
    //<Products> by this we want to specify that we need communication chanel between the type
    //of data i.e =>provided instance of the Products class and this widget

    final products = showFavoritesOnly? productsData.favoriteItems:productsData.items; //'items' is the getter specefied in the Products class

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //A delegate that controls the layout of the children within the [GridView].
        crossAxisCount: 2,
        childAspectRatio: 3 /
            2, //The ratio of the cross-axis to the main-axis extent of each child.),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (BuildContext ctx, int index) {
        //chnages in the favorite status =>(changes in single Product model are only needed in the ProductItem class )
        return ChangeNotifierProvider.value(   //use the .value constructor for list/grid 
        //and for existing objects in the memory 
            value: products[index],  //will return a single product item as 
            //.value ensures that the provider works even if the data changes
            //it is stored in the products class,it will do this multiple times as it is in a list view builder 
            //it will automatically be disposed of =>avoiding memory leaks 
            
            child: ProductItem(  //in a grid/list =>widget is reused and the data attached to it changes =>recycles it
              // products[index].id, 
              // products[index].title,
              // products[index].imageUrl
              ));
      },
    );
  }
}
