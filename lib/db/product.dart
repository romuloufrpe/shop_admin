import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  Firestore _firestore = Firestore.instance;
  String ref = 'product';

  @override
  Future<String> createProduct({Map newProduct}) async {
    String documentId;

    await _firestore.collection(ref).add(newProduct).then((documentRef) {
      documentId = documentRef.documentID;
    });

    return documentId;
  }

  @override
  Future<List<String>> uploadImageProduct(
      {List<File> imageList, String docId, String title}) async {
    List<String> imagesUrl = new List();
    final String picture =
        "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
    for (int s = 0; s < imageList.length; s++) {
      final StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child(title)
          .child(docId)
          .child(docId + picture);
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
          .updateData({ref: data}).whenComplete(() {
        msg = true;
      });
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
