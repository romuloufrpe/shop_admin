import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../db/brand.dart';
import '../db/category.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  List<String> selectedSizes = <String>[];
  File _image1;
  File _image2;
  File _image3;

  @override
  void initState() {
    _getCategories();
    _getBrands();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
              child: Text(categories[i].data['category']),
              value: categories[i].data['category'],
            ));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].data['brand']),
                value: brands[i].data['brand']));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: Icon(Icons.close, color: Colors.black),
        title: Text("Adicionar Produto", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5), width: 2.5),
                          onPressed: () {
                            _selectImage(
                                ImagePicker.pickImage(
                                    source: ImageSource.gallery),
                                1);
                          },
                          child: _displayChild1()),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5), width: 2.5),
                          onPressed: () {
                            _selectImage(
                                ImagePicker.pickImage(
                                    source: ImageSource.gallery),
                                2);
                          },
                          child: _displayChild2()),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5), width: 2.5),
                          onPressed: () {
                            _selectImage(
                                ImagePicker.pickImage(
                                    source: ImageSource.gallery),
                                3);
                          },
                          child: _displayChild3()),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Entre com o nome do produto no máximo 10 caracteres',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(hintText: 'Nome do produto'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Você deve entrar com o nome do produto';
                    } else if (value.length > 10) {
                      return 'Nome do produto muito grande';
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Categoria: ',
                      style: TextStyle(color: Colors.red),
                    ),
                    DropdownButton(
                      items: categoriesDropDown,
                      onChanged: changeSelectedCategory,
                      value: _currentCategory,
                    ),
                    Text(
                      'Modelo: ',
                      style: TextStyle(color: Colors.red),
                    ),
                    DropdownButton(
                      items: brandsDropDown,
                      onChanged: changeSelectedBrand,
                      value: _currentBrand,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: 'Quantidade'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Você deve entrar com a quantidade';
                    }
                  },
                ),
              ),
              Text('Tamanho'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: selectedSizes.contains('PP'),
                      onChanged: (value) => changeSelectedSize('PP'),
                    ),
                    Text('PP'),
                    Checkbox(
                      value: selectedSizes.contains('P'),
                      onChanged: (value) => changeSelectedSize('P'),
                    ),
                    Text('P'),
                    Checkbox(
                      value: selectedSizes.contains('M'),
                      onChanged: (value) => changeSelectedSize('M'),
                    ),
                    Text('M'),
                    Checkbox(
                      value: selectedSizes.contains('G'),
                      onChanged: (value) => changeSelectedSize('G'),
                    ),
                    Text('G'),
                    Checkbox(
                      value: selectedSizes.contains('GG'),
                      onChanged: (value) => changeSelectedSize('GG'),
                    ),
                    Text('GG'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: selectedSizes.contains('28'),
                      onChanged: (value) => changeSelectedSize('28'),
                    ),
                    Text('28'),
                    Checkbox(
                      value: selectedSizes.contains('32'),
                      onChanged: (value) => changeSelectedSize('32'),
                    ),
                    Text('32'),
                    Checkbox(
                      value: selectedSizes.contains('36'),
                      onChanged: (value) => changeSelectedSize('36'),
                    ),
                    Text('36'),
                    Checkbox(
                      value: selectedSizes.contains('40'),
                      onChanged: (value) => changeSelectedSize('40'),
                    ),
                    Text('40'),
                    Checkbox(
                      value: selectedSizes.contains('44'),
                      onChanged: (value) => changeSelectedSize('44'),
                    ),
                    Text('44'),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Adicionar'),
                onPressed: () {
                  validateAndUpload();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data['category'];
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandDropDown();
      _currentBrand = brands[0].data['brand'];
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  void changeSelectedSize(String size) {
    if (selectedSizes.contains(size)) {
      setState(() {
        selectedSizes.remove(size);
      });
    } else {
      setState(() {
        selectedSizes.insert(0, size);
      });
    }
  }

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImag = await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() => _image1 = tempImag);
        break;
      case 2:
        setState(() => _image2 = tempImag);
        break;
      case 3:
        setState(() => _image3 = tempImag);
        break;
    }
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 70.0, 14.0, 70.0),
        child: new Icon(
          FontAwesomeIcons.plus,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.file(_image1, fit: BoxFit.fill, width: double.infinity);
    }
  }

  Widget _displayChild2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 70.0, 14.0, 70.0),
        child: new Icon(
          FontAwesomeIcons.plus,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.file(_image2, fit: BoxFit.fill, width: double.infinity);
    }
  }

  Widget _displayChild3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 70.0, 14.0, 70.0),
        child: new Icon(
          FontAwesomeIcons.plus,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.file(_image3, fit: BoxFit.fill, width: double.infinity);
    }
  }

  void validateAndUpload() {
    if (_formKey.currentState.validate()) {
      if (_image1 != null && _image2 != null && _image3 != null) {
        if (selectedSizes.isNotEmpty) {
          String imageUrl;
          final String picture =
              "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          // StorageUploadTask task =
          final StorageReference firebaseStorageRef =
              FirebaseStorage.instance.ref().child(picture);
          final StorageUploadTask task = firebaseStorageRef.putFile(_image1);
          //imageUrl = task.toString();
        } else {
          Fluttertoast.showToast(msg: 'Selecione pelo menos um tamanho');
        }
      } else {
        Fluttertoast.showToast(msg: 'todas as imagens devem ser fornecidas');
      }
    }
  }
}
