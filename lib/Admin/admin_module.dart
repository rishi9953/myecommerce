import 'package:flutter_modular/flutter_modular.dart';
import 'package:myecommerce/Admin/Firebase/firebase_storage_service.dart';
import 'package:myecommerce/Admin/Pages/banner_page.dart';
import 'package:myecommerce/Admin/Pages/categories_page.dart';
import 'package:myecommerce/Admin/Pages/dashboard_page.dart';
import 'package:myecommerce/Admin/Pages/orders_page.dart';
import 'package:myecommerce/Admin/Pages/products_page.dart';
import 'package:myecommerce/Admin/Pages/subcategories_page.dart';
import 'package:myecommerce/Admin/Pages/user_page.dart';
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
        ChildRoute('/orders', child: (context) => const OrdersPage()),
        ChildRoute('/products', child: (context) => const ProductsPage()),
        ChildRoute('/categories', child: (context) => const CategoriesPage()),
        ChildRoute('/subcategories', child: (context) => const SubcategoriesPage()),
        ChildRoute('/users', child: (context) => const UsersPage()),
        ChildRoute('/banners', child: (context) => const BannersPage()),
      ],
    );
  }
}
