import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:myecommerce/Admin/modular.dart';
import 'package:myecommerce/Web/service/route_service.dart';
import 'package:myecommerce/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EcommerceAppp());
}

class EcommerceAppp extends StatelessWidget {
  const EcommerceAppp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
      // home: HomeScreen(),
    );
  }
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ModularApp(module: AppModule(), child: const AppWidget());
  }
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: Modular.routerConfig,
    );
  }
}
