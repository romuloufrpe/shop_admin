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

  String erro;

  Map<int, File> imagesMap = new Map();

  ProductService productService = ProductService();

  TextEditingController productTitle = new TextEditingController();
  TextEditingController productPrice = new TextEditingController();
  TextEditingController productDesc = new TextEditingController();
  TextEditingController productCat = new TextEditingController();

  String productTitles;
  String productPrices;
  String productDescs;
  String productCats;
  String productBrands;

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
                controller: productTitle),
            new SizedBox(
              height: 10.0,
            ),
            productTextField(
                textTitle: "Valor do Produto",
                textHint: "Entre aqui com o valor produto",
                controller: productPrice,
                textType: TextInputType.number),
            new SizedBox(
              height: 10.0,
            ),
            productTextField(
                textTitle: "Descrição do Produto",
                textHint: "Entre aqui com a descrição do produto",
                controller: productDesc,
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
            appButton(
                btnTxt: "Add Produto",
                onBtnclicked:addNewProduct,
                btnPadding: 20.0,
                btnColor: Colors.red)
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
      imagesMap[imagesMap.length] = file;
      List<File> imageFile = new List();
      imageFile.add(file);
      //print(imageFile.length);
      //imageList = new List.from(imageFile);
      if (imageList == null) {
        imageList = new List.from(imageFile, growable: true);
      } else {
        for (int s = 0; s < imageFile.length; s++) {
          imageList.add(file);
          print(imageFile.length);
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

  addNewProduct() async{
    if (imageList == null || imageList.isEmpty) {
      showSnackBar("Adicione uma foto", scaffolKey);
      return;
    }
    if (productTitle.text == "") {
      showSnackBar("Adicione o nome do produto", scaffolKey);
      return;
    }
    if (productPrice.text == "") {
      showSnackBar("Adicione o valor do produto", scaffolKey);
      return;
    }
    if (productDesc.text == "") {
      showSnackBar("Adicione a descrição do produto", scaffolKey);
      return;
    } else {
      /*List<String> imagesUrl = [];
      int uploadCount = 0;
      final String picture =
          "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(picture);
      final StorageMetadata metadata = StorageMetadata(contentType: 'image/png');
      imageList.forEach((image){
          firebaseStorageRef.putFile(image, metadata).onComplete.then((snapshot){
            
          });
      });*/
      // _uploadImages(productTitle.text, imageList, onSuccess, onFailure)
    }

    displayProgressDialog(context);

    Map<String, dynamic> newProduct = {
      productTitles: productTitle.text,
      productPrices: productPrice.text,
      productDescs: productDesc.text,
      productCats: _currentCategory,
      productBrands: _currentBrand
    };


    // Adicionando as informações ao firebase
    String productId =
        await productService.createProduct(newProduct: newProduct);
    // envia imagens para o fibaseStorage
    List<String> imagesUrl = await productService.uploadImageProduct(
        imageList: imageList, docId: productId, title: productTitle.text);


    // checa se existe algum erro no envio das imagens para o firebase
   if(imagesUrl.contains(erro)){
      closeProgressDialog(context);
      showSnackBar("Não foi possivel enviar as imagens", scaffolKey);
      return;
    }
    bool result = await productService.updateProductImages(docID: productId, data: imagesUrl);

    if(result !=null && result == true) {
      closeProgressDialog(context);
      resetEverything();
            showSnackBar("Produto Adicionado", scaffolKey);
          }else{
            closeProgressDialog(context);
            showSnackBar("Erro ao enviar produto", scaffolKey);    }
        }
      
        void resetEverything() {
          productTitle.text = "";
          productPrice.text = "";
          productDesc.text = "";
          imageList.clear();
        }

 /* _uploadImages(
      String productId,
      List<File> images,
      Function onSuccess(List<String> imageUrls),
      Function onFailure(String e)) {
    List<String> imagesURls = [];
    int uploadCount = 0;
    final String picture =
        "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

    StorageReference storaRef = FirebaseStorage.instance
        .ref()
        .child('Products')
        .child(productId)
        .child(picture);
    StorageMetadata metadata = StorageMetadata(contentType: picture);

    images.forEach((image) {
      storaRef.putFile(image, metadata).onComplete.then((snapshot) {
        uploadCount++;
        if (uploadCount == images.length) {
          onSuccess(imagesURls);
        }
      });
    });
  }*/
}
