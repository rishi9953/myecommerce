import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../Firebase/firebase_services.dart';
import '../Firebase/firebase_storage_service.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FirebaseServicesAdmin _db = FirebaseServicesAdmin();
  final FirebaseStorageService _storage = FirebaseStorageService();

  Future<void> _openCreateCategoryDialog() async {
    final nameController = TextEditingController();
    Uint8List? bytes;
    String? fileName;
    bool isActive = true;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> pickImage() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              if (result != null && result.files.isNotEmpty) {
                setLocalState(() {
                  bytes = result.files.single.bytes;
                  fileName = result.files.single.name;
                });
              }
            }

            Future<void> create() async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              if (bytes == null || fileName == null) return;

              Navigator.pop(context, true);
              try {
                final task = _storage.uploadCategoryImage(bytes!, fileName!);
                final snapshot = await task;
                final imageUrl = await snapshot.ref.getDownloadURL();
                await _db.addCategory(
                  name: name,
                  imageUrl: imageUrl,
                  isActive: isActive,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create category: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('Create Category'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fileName == null ? 'No image selected' : fileName!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Select image'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (v) => setLocalState(() => isActive = v),
                      title: const Text('Active'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: create,
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category created')),
      );
    }
  }

  Future<void> _deleteCategory({
    required String id,
    required String imageUrl,
  }) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: const Text('Are you sure you want to delete this category?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirm) return;

    try {
      await _storage.deleteImage(imageUrl);
      await _db.deleteCategory(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openEditDialog({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final nameController = TextEditingController(text: (data['name'] ?? '') as String);
    bool isActive = (data['isActive'] ?? true) as bool;
    String imageUrl = (data['imageUrl'] ?? '') as String;
    Uint8List? bytes;
    String? fileName;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> pickImage() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              if (result != null && result.files.isNotEmpty) {
                setLocalState(() {
                  bytes = result.files.single.bytes;
                  fileName = result.files.single.name;
                });
              }
            }

            Future<void> save() async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(context, true);
              try {
                if (bytes != null && fileName != null) {
                  final task = _storage.uploadCategoryImage(bytes!, fileName!);
                  final snapshot = await task;
                  imageUrl = await snapshot.ref.getDownloadURL();
                }

                await _db.updateCategory(
                  id: id,
                  name: name,
                  imageUrl: imageUrl,
                  isActive: isActive,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('Edit Category'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Category name'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fileName ?? imageUrl,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Change image'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (v) => setLocalState(() => isActive = v),
                      title: const Text('Active'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: save,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New category'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No categories yet'));
                    }

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data();
                        final name = (data['name'] ?? '') as String;
                        final imageUrl = (data['imageUrl'] ?? '') as String;
                        final isActive = (data['isActive'] ?? true) as bool;

                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(isActive ? 'Active' : 'Inactive'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isActive,
                                onChanged: (v) => _db.updateCategory(
                                  id: doc.id,
                                  name: name,
                                  imageUrl: imageUrl,
                                  isActive: v,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: () => _openEditDialog(id: doc.id, data: data),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () => _deleteCategory(
                                  id: doc.id,
                                  imageUrl: imageUrl,
                                ),
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


