import 'package:myecommerce/Admin/admin_home.dart';

class BannerRepository {
  final List<BannerModel> _banners = [];

  List<BannerModel> getAllBanners() {
    return List.unmodifiable(_banners);
  }

  void addBanner(BannerModel banner) {
    _banners.add(banner);
  }

  void deleteBanner(String id) {
    _banners.removeWhere((banner) => banner.id == id);
  }

  void updateBanner(BannerModel banner) {
    final index = _banners.indexWhere((b) => b.id == banner.id);
    if (index != -1) {
      _banners[index] = banner;
    }
  }
}
