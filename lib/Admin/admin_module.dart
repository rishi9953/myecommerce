import 'package:flutter_modular/flutter_modular.dart';
import 'package:myecommerce/Admin/Firebase/firebase_storage_service.dart';
import 'package:myecommerce/Admin/Pages/banner_page.dart';
import 'package:myecommerce/Admin/Pages/dashboard_page.dart';
import 'package:myecommerce/Admin/Pages/user_page.dart';
import 'package:myecommerce/Admin/controllers/banner_controller.dart';
import 'package:myecommerce/Admin/pages/admin_home_page.dart';
import 'package:myecommerce/Admin/repositories/banner_repository.dart';

class AdminModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(FirebaseStorageService.new);
    i.addSingleton(BannerRepository.new);
    // i.addSingleton(BannerController.new);
  }

  @override
  void routes(r) {
    r.child(
      '/',
      child: (context) => const AdminHomePage(),
      children: [
        ChildRoute('/dashboard', child: (context) => const DashboardPage()),
        ChildRoute('/users', child: (context) => const UsersPage()),
        ChildRoute('/banners', child: (context) => const BannersPage()),
      ],
    );
  }
}
