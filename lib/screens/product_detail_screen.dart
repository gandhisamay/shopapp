//detailed page for each product
import 'package:flutter/material.dart';

import '../providers/products_provider.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';

class ProductDetailScreen extends StatelessWidget {
  // const ProductDetailScreen({ Key? key }) : super(key: key);

  // final String title;
  // ProductDetailScreen(this.title);

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final String productId =
        ModalRoute.of(context).settings.arguments as String;
    //get id
    // final loadedProduct=Provider.of<Products>(context).items.firstWhere((prod) => prod.id==productId);
    //better if the filtering logic is done inside the class
    final Product loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    //if say for some other logic the Products class changes =>automatically all the listeners will rebuild
    //but we only want the id of the product the user selected ,and we dont care about further changes in the class
    //then we use (context,listen : false)

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(loadedProduct.imageUrl, fit: BoxFit.cover),
            ),
            SizedBox(height: 10),
            Text(
              '\$ ${loadedProduct.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            SizedBox(height: 10),
            Container(
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(fontSize: 18),
                ))
          ],
        ),
      ),
    );
  }
}
