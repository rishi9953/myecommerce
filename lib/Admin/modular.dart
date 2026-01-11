import 'package:flutter_modular/flutter_modular.dart';
import 'package:myecommerce/Admin/admin_module.dart';

class AppModule extends Module {
  @override
  void routes(r) {
    r.module('/', module: AdminModule());
  }
}
