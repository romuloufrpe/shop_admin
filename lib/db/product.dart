import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductService {
  Firestore _firestore = Firestore.instance;
  String ref = 'product';

  @override
  Future<String> addNewProduct({Map newProduct}) async {
    String documentID;

    await _firestore.collection(ref).add(newProduct).then((documentref) {
      documentID = documentref.documentID;
    });

    return documentID;
  }

  @override
  Future<List<String>> uploadImageProduct(
      {List<File> imageList, String docId}) async {
    List<String> imagesUrl = new List();
    for (int s = 0; s < imageList.length; s++) {
      final StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('products')
          .child(docId)
          .child(docId + "$s.jpg");
      final StorageUploadTask uploadTask =
          firebaseStorageRef.putFile(imageList[s]);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      imagesUrl.add(downloadUrl.toString());

      return imagesUrl;
    }
  }

  @override
  Future<bool> updateProductImages({String docID, List<String> data}) async {
    bool msg;
    await _firestore
        .collection(ref)
        .document(docID)
        .updateData({"productImages": data}).whenComplete(() {
      msg = true;
    });
    return msg;
  }

  /*void createProduct(String title, String desc, String price, String imageUrl) {
    var id = Uuid();
    String productId = id.v1();

    _firestore.collection(ref).document(productId).setData({
      'title': title,
      'desc': desc,
      'price': price,
      'imageUrl': imageUrl
    });
    String document = _firestore.collection(ref).getDocuments().toString();
  }*/

  Future<List<DocumentSnapshot>> getProducts() =>
      _firestore.collection(ref).getDocuments().then((snaps) {
        print(snaps.documents.length);
        return snaps.documents;
      });
  Future<List<DocumentSnapshot>> getSuggestions(String suggestions) =>
      _firestore
          .collection(ref)
          .where('title', isEqualTo: suggestions)
          .getDocuments()
          .then((snap) {
        return snap.documents;
      });
}
