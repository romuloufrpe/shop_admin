import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app_admin/utils/progressdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_admin/utils/app_tools.dart';
import 'package:shop_app_admin/db/brand.dart';
import 'package:shop_app_admin/db/category.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;

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
    return new Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0.0,
        title: new Text('Cadastrar Produto',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: new SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            new SizedBox(
              height: 10.0,
            ),
            productTextField(
                textTitle: "Nome do Produto",
                textHint: "Entre aqui com o nome do produto"),
            new SizedBox(
              height: 10.0,
            ),
            productTextField(
                textTitle: "Descrição do Produto",
                textHint: "Entre aqui com a descrição do produto",
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
              onBtnclicked: (){},
              btnPadding: 20.0,
              btnColor: Colors.red
            )
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
}
