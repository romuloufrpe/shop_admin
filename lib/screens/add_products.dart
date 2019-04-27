import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app_admin/utils/progressdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_admin/utils/app_tools.dart';
import 'package:shop_app_admin/db/brand.dart';
import 'package:shop_app_admin/db/category.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app_admin/db/product.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  // ====================== CATEGORIAS
  CategoryService _categoryService = CategoryService();
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  String _currentCategory;

  List<String> categoriesList = new List();
// ======================= MODELOS
  BrandService _brandService = BrandService();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentBrand;
  List<String> brandsList = new List();

   List<String> selectedSizes = <String>[];

  String erro;

  Map<int, File> imagesMap = new Map();

  ProductService productService = ProductService();

  TextEditingController productControllerTitle = new TextEditingController();
  TextEditingController productControllerPrice = new TextEditingController();
  TextEditingController productControllerDesc = new TextEditingController();
  TextEditingController productControllerCat = new TextEditingController();

  static const String productTitle = "productTitle";
  static const String productPrice = "productPrice";
  static const String productDesc = "productDesc";
  static const String productCat = "productCat";
  static const String productBrand = "productBrand";
  static const String productSize = "productSize";

  final scaffolKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
    return new Scaffold(
      key: scaffolKey,
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0.0,
        title: new Text('Cadastrar Produto',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: new RaisedButton.icon(
              color: Colors.green,
              shape: new RoundedRectangleBorder(
                  borderRadius:
                      new BorderRadius.all(new Radius.circular(15.0))),
              onPressed: () => pickImage(),
              icon: Icon(
                FontAwesomeIcons.plus,
                color: Colors.white,
              ),
              label: new Text(
                'imagens',
                style: new TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: new SingleChildScrollView(
        key: _formKey,
        child: new Column(
          children: <Widget>[
            new SizedBox(
              height: 10.0,
            ),
            MultiImagePickerList(
                imageList: imageList,
                removeNewImage: (index) {
                  removeImage(index);
                }),
            productTextField(
                textTitle: "Nome do Produto",
                textHint: "Entre aqui com o nome do produto",
                controller: productControllerTitle),
            new SizedBox(
              height: 10.0,
            ),
            productTextField(
                textTitle: "Valor do Produto",
                textHint: "Entre aqui com o valor produto",
                controller: productControllerPrice,
                textType: TextInputType.number),
            new SizedBox(
              height: 10.0,
            ),
            productTextField(
                textTitle: "Descrição do Produto",
                textHint: "Entre aqui com a descrição do produto",
                controller: productControllerDesc,
                maxLines: 4,
                height: 150.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                productDropDown(
                    textTitle: "categoria",
                    selectedItem: _currentCategory,
                    dropDownItems: categoriesDropDown,
                    changedDropDownItems: changeSelectedCategory),
                productDropDown(
                    textTitle: "Modelo",
                    selectedItem: _currentBrand,
                    dropDownItems: brandsDropDown,
                    changedDropDownItems: changeSelectedBrand)
              ],
            ),
            new SizedBox(height: 20.0),
            Text('Tamanho', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('PP'),
                      onChanged: (value) => changeSelectedSize('PP'),
                    ),
                    Text('PP'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('P'),
                      onChanged: (value) => changeSelectedSize('P'),
                    ),
                    Text('P'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('M'),
                      onChanged: (value) => changeSelectedSize('M'),
                    ),
                    Text('M'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('G'),
                      onChanged: (value) => changeSelectedSize('G'),
                    ),
                    Text('G'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('28'),
                      onChanged: (value) => changeSelectedSize('28'),
                    ),
                    Text('28'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('32'),
                      onChanged: (value) => changeSelectedSize('32'),
                    ),
                    Text('32'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('36'),
                      onChanged: (value) => changeSelectedSize('36'),
                    ),
                    Text('36'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('40'),
                      onChanged: (value) => changeSelectedSize('40'),
                    ),
                    Text('40'),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: selectedSizes.contains('44'),
                      onChanged: (value) => changeSelectedSize('44'),
                    ),
                    Text('44'),
                  ],
                ),
),
            new SizedBox(height: 20.0),
            appButton(
                btnTxt: "Add Produto",
                onBtnclicked: addNewProduct,
                btnPadding: 20.0,
                btnColor: Colors.red),

          
          ],
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

  List<File> imageList;

  pickImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      //imagesMap[imagesMap.length] = file;
      List<File> imageFile = new List();
      imageFile.add(file);
      //print(imageFile.length);
      //imageList = new List.from(imageFile);
      if (imageList == null) {
        imageList = new List.from(imageFile, growable: true);
      } else {
        for (int s = 0; s < imageFile.length; s++) {
          imageList.add(file);
          print(imageList.length);
        }
      }
      setState(() {});
    }
  }

  removeImage(int index) async {
    //imagesMap.remove(index);
    imageList.removeAt(index);
    setState(() {});
  }

  addNewProduct() async {
    if (imageList == null || imageList.isEmpty) {
      showSnackBar("Adicione uma foto", scaffolKey);
      return;
    }
    if (productControllerTitle.text == "") {
      showSnackBar("Adicione o nome do produto", scaffolKey);
      return;
    }
    if (productControllerPrice.text == "") {
      showSnackBar("Adicione o valor do produto", scaffolKey);
      return;
    }
    if (productControllerDesc.text == "") {
      showSnackBar("Adicione a descrição do produto", scaffolKey);
      return;
    } else {
    }

    displayProgressDialog(context);

    Map<String, dynamic> newProduct = {
      productTitle: productControllerTitle.text,
      productPrice: productControllerPrice.text,
      productDesc: productControllerDesc.text,
      productCat: _currentCategory,
      productBrand: _currentBrand,
      productSize: selectedSizes
    };

    //    adiciona informação para o firebase
    String productId =
        await productService.addNewProduct(newProduct: newProduct);
// faz o upload das imagens
    List<String> imagesURL = await productService.uploadImageProduct(
        docId: productId, imageList: imageList);

    if (imagesURL.contains("erro")) {
      closeProgressDialog(context);
      showSnackBar("Erro ao enviar as imagens", scaffolKey);
      return;
    }
    bool result = await productService.updateProductImages(
        docID: productId, data: imagesURL);
    if (result != null && result == true) {
      closeProgressDialog(context);
      resetEverything();
      showSnackBar("Cadastrado com Sucesso!", scaffolKey);
    } else {
      closeProgressDialog(context);
      showSnackBar("erro tente novamente!", scaffolKey);
    }
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


  void resetEverything() {
    imageList.clear();
    productControllerTitle.text = "";
    productControllerPrice.text = "";
    productControllerDesc.text = "";
    setState(() {});
  }
}
