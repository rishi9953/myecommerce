import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String collectionBanners = 'banners';

  CollectionReference<Object?> get users => firestore.collection('users');

  void createUser(model) async {
    return users
        .add(model)
        .then((value) => debugPrint('User Added'))
        .catchError((error) => debugPrint('Failed to add User $error'));
  }

  Stream<QuerySnapshot> getBanners() {
    return firestore
        .collection(collectionBanners)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
