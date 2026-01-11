import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Modular.routerDelegate,
      builder: (context, _) {
        final currentPath = Modular.to.path;

        return Container(
          width: 250,
          color: const Color(0xFF2C3E50),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),

              _SidebarItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                isSelected: currentPath.startsWith('/dashboard'),
                onTap: () => Modular.to.navigate('/dashboard'),
              ),

              _SidebarItem(
                icon: Icons.people,
                title: 'Users',
                isSelected: currentPath.startsWith('/users'),
                onTap: () => Modular.to.navigate('/users'),
              ),

              _SidebarItem(
                icon: Icons.image,
                title: 'Add Banners',
                isSelected: currentPath.startsWith('/banners'),
                onTap: () => Modular.to.navigate('/banners'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
