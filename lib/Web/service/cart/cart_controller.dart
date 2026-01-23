import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String productId;
  final String title;
  final String imageUrl;
  final num price;
  int qty;

  CartItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'qty': qty,
      };

  static CartItem fromJson(Map<String, dynamic> json) => CartItem(
        productId: (json['productId'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        imageUrl: (json['imageUrl'] ?? '').toString(),
        price: (json['price'] ?? 0) as num,
        qty: (json['qty'] ?? 1) as int,
      );
}

class CartController extends ChangeNotifier {
  static const _prefsKey = 'cart_items_v1';

  final List<CartItem> _items = [];
  bool _loaded = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get loaded => _loaded;

  int get totalQty => _items.fold(0, (sum, e) => sum + e.qty);
  num get subtotal => _items.fold<num>(0, (sum, e) => sum + (e.price * e.qty));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _items.clear();
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _items.addAll(
          decoded.whereType<Map>().map((e) => CartItem.fromJson(e.cast<String, dynamic>())),
        );
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Future<void> addOrIncrement({
    required String productId,
    required String title,
    required String imageUrl,
    required num price,
  }) async {
    final existing = _items.where((e) => e.productId == productId).toList();
    if (existing.isNotEmpty) {
      existing.first.qty += 1;
    } else {
      _items.add(
        CartItem(productId: productId, title: title, imageUrl: imageUrl, price: price, qty: 1),
      );
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setQty(String productId, int qty) async {
    final idx = _items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    if (qty <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx].qty = qty;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
    notifyListeners();
  }
}






