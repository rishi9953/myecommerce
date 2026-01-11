import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../widgets/admin_sidebar.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: RouterOutlet(),
          ),
        ],
      ),
    );
  }
}