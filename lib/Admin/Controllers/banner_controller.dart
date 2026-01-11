// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:myecommerce/Admin/Firebase/firebase_storage_service.dart';
// import 'package:myecommerce/Admin/admin_home.dart';
// import '../repositories/banner_repository.dart';

// class BannerController extends ChangeNotifier {
//   final BannerRepository _repository;
//   final FirebaseStorageService _storageService;

//   bool _isUploading = false;
//   double _uploadProgress = 0.0;

//   BannerController(this._repository, this._storageService);

//   List<BannerModel> get banners => _repository.getAllBanners();
//   bool get isUploading => _isUploading;
//   double get uploadProgress => _uploadProgress;

//   Future<void> addBanner({
//     required String title,
//     required Uint8List imageData,
//     required String fileName,
//     required String link,
//   }) async {
//     try {
//       _isUploading = true;
//       _uploadProgress = 0.0;
//       notifyListeners();

//       // Upload image to Firebase Storage
//       final String imageUrl = await _storageService.uploadBannerImage(
//         imageData,
//         fileName,
//       );

//       _uploadProgress = 1.0;
//       notifyListeners();

//       // Create banner model
//       final banner = BannerModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         title: title,
//         imageUrl: imageUrl,
//         link: link,
//         isActive: true,
//       );

//       _repository.addBanner(banner);

//       _isUploading = false;
//       notifyListeners();
//     } catch (e) {
//       _isUploading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   Future<void> deleteBanner(String id) async {
//     try {
//       final banners = _repository.getAllBanners();
//       final banner = banners.firstWhere((b) => b.id == id);

//       // Delete image from Firebase Storage
//       await _storageService.deleteImage(banner.imageUrl);

//       // Delete banner from repository
//       _repository.deleteBanner(id);
//       notifyListeners();
//     } catch (e) {
//       // Even if image deletion fails, remove from repository
//       _repository.deleteBanner(id);
//       notifyListeners();
//     }
//   }

//   void toggleBanner(String id) {
//     final banners = _repository.getAllBanners();
//     final banner = banners.firstWhere((b) => b.id == id);
//     final updatedBanner = banner.copyWith(isActive: !banner.isActive);
//     _repository.updateBanner(updatedBanner);
//     notifyListeners();
//   }
// }
