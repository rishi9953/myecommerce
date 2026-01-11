import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UploadTask uploadBannerImage(Uint8List imageData, String fileName) {
    final String path =
        'banners/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final Reference ref = _storage.ref().child(path);

    return ref.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      print('Delete image error: $e');
    }
  }
}
