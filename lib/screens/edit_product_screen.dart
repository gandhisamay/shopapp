import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();
  //A [FormState] object can be used to [save], [reset], and [validate]
  //every [FormField] that is a descendant of the associated [Form].

  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    //store the init values in a map
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;

  var _isLoading = false;

  @override
  void initState() {
    //to set a listener whether image url text field is focused or not
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
    //to get the id forwaded by edit icon =>we cant use ModalRoute.settings.arguments here
    //so we use didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    //This method is also called immediately after [initState]. It is
    //safe to call [BuildContext.dependOnInheritedWidgetOfExactType] from this method.
    //Subclasses rarely override this method because the framework always
    //calls [build] after a dependency changes.
    if (_isInit) {
      //get the id
      final productId = ModalRoute.of(context).settings.arguments as String;
      //didChangeDependencies is also called when we press '+' icon on Manage products screen
      //the code below may fail then =>check whether we have a product of that id then
      // only we can edit
      if (productId != null) {
        //find the required products from the list and initialise edited products
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        //override them in the map
        _initValues = {
          //we need them to show in the textfield if we are pressing the edit icon
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit =
        false; //didChangeDependencies will change a lot =>we just need to do this once
    super.didChangeDependencies();
  }

  @override //we have to dispose when we leave the screen
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid =
        _form.currentState.validate(); //true if all validatpors return null
    if (!isValid) {
      return;
    }
    _form.currentState
        .save(); //use a key when we need to interact with a widget from inside here(mostly used by form widgets)
    //save method provided by the state object of form

    setState(() {
      _isLoading = true; //and set it to false when we pop the screen
    }); //the loading widget shows now before we update or add the products

    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (bctx) => AlertDialog(
                  title: Text('Error!'),
                  //  content: Text(error.toString()),
                  content: Text('Something went wrong'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(bctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      } finally {  //in the end we should do this no matter succeded or failed
        setState(() {
          _isLoading = false; //now when the products are added to the list ,
          //set the _isLoading to false and pop the screen
        });
        Navigator.of(context).pop();
      } //catch error when addproduct fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              //IMP...
//User input might get lost if an input fields scrolls out of view.
// That happens because the ListView widget dynamically removes and
//re-adds widgets as they scroll out of and back into view.
// For short lists/ portrait-only apps, where only minimal scrolling might be
// needed, a ListView should be fine, since items won't scroll that far out
//of view (ListView has a certain threshold until which it will keep items in memory).
// But for longer lists or apps that should work in landscape mode as well - or maybe
// just to be safe - you might want to use a Column (combined with SingleChildScrollView)
// instead. Since SingleChildScrollView doesn't clear widgets that scroll out of view,
//you are not in danger of losing user input in that case.

              child: Form(
                // autovalidate: true,
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      //connected to the form widget
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                          labelText:
                              'Title'), //can configure error message style),
                      textInputAction: TextInputAction
                          .next, //controls what the bottom right keyboard button will do
                      onFieldSubmitted: (_) {
                        //use the focus node to move the cursor from the title input to the price input
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                        //now the focus node points to the field which has _priceFocusNode
                      },
                      validator: (value) {
                        //returns null if the input is correct
                        if (value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value) == null) {
                          //checks for invalid numbers
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: double.parse(value),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description.';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        //shows preview of image\
                        Expanded(
                          child: TextFormField(
                            // initialValue: _initValues['imageUrl'],
                            //initialValue == null || controller == null': is not true.
                            //we cant use controller and initialValue in the same textField

                            //by default gets the maximum size it can bget in a row
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            //we need to see the preview of image once this looses focus
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onEditingComplete: () {
                              setState(() {});
                              //we force flutter to update screen hence picking latest value added
                              //by the user
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
