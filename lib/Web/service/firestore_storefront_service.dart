import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreStorefrontService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection('categories');
  CollectionReference<Map<String, dynamic>> get _subcategories =>
      _db.collection('subcategories');
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders => _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Stream<QuerySnapshot<Map<String, dynamic>>> categories({bool onlyActive = true}) {
    final ref = onlyActive ? _categories.where('isActive', isEqualTo: true) : _categories;
    return ref.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> subcategories({
    required String categoryId,
    bool onlyActive = true,
  }) {
    Query<Map<String, dynamic>> q = _subcategories.where('categoryId', isEqualTo: categoryId);
    if (onlyActive) q = q.where('isActive', isEqualTo: true);
    return q.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> products({
    String? categoryId,
    String? subcategoryId,
    bool onlyActive = true,
  }) {
    Query<Map<String, dynamic>> q = _products;
    if (categoryId != null && categoryId.isNotEmpty) {
      q = q.where('categoryId', isEqualTo: categoryId);
    }
    if (subcategoryId != null && subcategoryId.isNotEmpty) {
      q = q.where('subcategoryId', isEqualTo: subcategoryId);
    }
    if (onlyActive) q = q.where('isActive', isEqualTo: true);
    return q.orderBy('createdAt', descending: true).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> productById(String id) {
    return _products.doc(id).get();
  }

  Future<void> upsertUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    await _users.doc(uid).set({
      'email': email.trim(),
      'name': name.trim(),
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required num total,
    required Map<String, dynamic> shipping,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw 'Please sign in to place an order.';
    }

    final doc = await _orders.add({
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'items': items,
      'total': total,
      'shipping': shipping,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}






