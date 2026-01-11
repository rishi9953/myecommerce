// lib/modules/admin/admin_home.dart
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [const UsersScreen(), const BannersScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

// lib/modules/admin/widgets/admin_sidebar.dart
class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            icon: Icons.people,
            title: 'Users',
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _SidebarItem(
            icon: Icons.image,
            title: 'Add Banners',
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
        ],
      ),
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

// lib/modules/admin/screens/users_screen.dart
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Users Management',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Text(
                'Users screen content goes here',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/modules/admin/screens/banners_screen.dart
class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final List<BannerModel> _banners = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _linkController = TextEditingController();

  void _addBanner() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _banners.add(
          BannerModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text,
            imageUrl: _imageUrlController.text,
            link: _linkController.text,
            isActive: true,
          ),
        );
      });
      _titleController.clear();
      _imageUrlController.clear();
      _linkController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner added successfully!')),
      );
    }
  }

  void _deleteBanner(String id) {
    setState(() {
      _banners.removeWhere((banner) => banner.id == id);
    });
  }

  void _toggleBanner(String id) {
    setState(() {
      final index = _banners.indexWhere((banner) => banner.id == id);
      if (index != -1) {
        _banners[index] = _banners[index].copyWith(
          isActive: !_banners[index].isActive,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Banner Management',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Banner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Banner Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an image URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link URL (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addBanner,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Banner'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All Banners',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _banners.isEmpty
                ? Center(
                    child: Text(
                      'No banners added yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              banner.imageUrl,
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                          title: Text(banner.title),
                          subtitle: Text(
                            banner.link.isEmpty ? 'No link' : banner.link,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: banner.isActive,
                                onChanged: (_) => _toggleBanner(banner.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _deleteBanner(banner.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}

// lib/modules/admin/models/banner_model.dart
class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String link;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.isActive,
  });

  BannerModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? link,
    bool? isActive,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      isActive: isActive ?? this.isActive,
    );
  }
}
