import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServicesAdmin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionBanners = 'banners';

  Future<void> addBanner({
    required String title,
    required String imageUrl,
    required String link,
  }) async {
    await _firestore.collection(collectionBanners).add({
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'uploadedBy': 'Admin',
    });
  }

  Stream<QuerySnapshot> getBanners() {
    return _firestore
        .collection(collectionBanners)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> editBanners({
    required String imageUrl,
    required String bannerId,
    required String title,
    required bool isActive,
    String link = '',
  }) async {
    await _firestore.collection(collectionBanners).doc(bannerId).set({
      'imageUrl': imageUrl,
      'title': title,
      'link': link,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
      'uploadedBy': 'Admin',
    }, SetOptions(merge: true));
  }

  Future<void> deleteBanner(String id) async {
    await _firestore.collection(collectionBanners).doc(id).delete();
  }

  Future<void> toggleBanner(String id, bool value) async {
    await _firestore.collection(collectionBanners).doc(id).update({
      'isActive': value,
    });
  }
}
