import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServicesAdmin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionBanners = 'banners';
  static const String collectionCategories = 'categories';
  static const String collectionSubcategories = 'subcategories';
  static const String collectionProducts = 'products';
  static const String collectionOrders = 'orders';
  static const String collectionUsers = 'users';

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

  // -------------------- Categories --------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> getCategories({
    bool onlyActive = false,
  }) {
    final ref = _firestore.collection(collectionCategories);
    final query = onlyActive ? ref.where('isActive', isEqualTo: true) : ref;
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s);
  }

  Future<DocumentReference<Map<String, dynamic>>> addCategory({
    required String name,
    required String imageUrl,
    bool isActive = true,
  }) async {
    return _firestore.collection(collectionCategories).add({
      'name': name.trim(),
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String imageUrl,
    required bool isActive,
  }) async {
    await _firestore.collection(collectionCategories).doc(id).set({
      'name': name.trim(),
      'imageUrl': imageUrl,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(collectionCategories).doc(id).delete();
  }

  // -------------------- Subcategories --------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> getSubcategories({
    String? categoryId,
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collectionSubcategories);
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map((s) => s);
  }

  Future<DocumentReference<Map<String, dynamic>>> addSubcategory({
    required String name,
    required String categoryId,
    String imageUrl = '',
    bool isActive = true,
  }) async {
    return _firestore.collection(collectionSubcategories).add({
      'name': name.trim(),
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSubcategory({
    required String id,
    required String name,
    required String categoryId,
    required String imageUrl,
    required bool isActive,
  }) async {
    await _firestore.collection(collectionSubcategories).doc(id).set({
      'name': name.trim(),
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteSubcategory(String id) async {
    await _firestore.collection(collectionSubcategories).doc(id).delete();
  }

  // -------------------- Products --------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? subcategoryId,
    bool onlyActive = false,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collectionProducts);
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (subcategoryId != null && subcategoryId.isNotEmpty) {
      query = query.where('subcategoryId', isEqualTo: subcategoryId);
    }
    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s);
  }

  Future<DocumentReference<Map<String, dynamic>>> addProduct({
    required String title,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    String subcategoryId = '',
    required List<String> imageUrls,
    bool isActive = true,
  }) async {
    return _firestore.collection(collectionProducts).add({
      'title': title.trim(),
      'description': description.trim(),
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required String id,
    required String title,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    String subcategoryId = '',
    required List<String> imageUrls,
    required bool isActive,
  }) async {
    await _firestore.collection(collectionProducts).doc(id).set({
      'title': title.trim(),
      'description': description.trim(),
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection(collectionProducts).doc(id).delete();
  }

  // -------------------- Orders --------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> getOrders() {
    return _firestore
        .collection(collectionOrders)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s);
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _firestore.collection(collectionOrders).doc(orderId).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // -------------------- Users --------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return _firestore
        .collection(collectionUsers)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s);
  }

  Future<void> setUserRole({
    required String userId,
    required String role, // "admin" | "customer"
  }) async {
    await _firestore.collection(collectionUsers).doc(userId).set({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
