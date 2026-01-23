import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../Firebase/firebase_services.dart';
import '../Firebase/firebase_storage_service.dart';

class SubcategoriesPage extends StatefulWidget {
  const SubcategoriesPage({super.key});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  final FirebaseServicesAdmin _db = FirebaseServicesAdmin();
  final FirebaseStorageService _storage = FirebaseStorageService();

  String? _selectedCategoryId;

  Future<void> _openCreateDialog({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> categories,
  }) async {
    final nameController = TextEditingController();
    Uint8List? bytes;
    String? fileName;
    bool isActive = true;
    String? categoryId =
        categories.isEmpty ? null : categories.first.id;

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
              if (categoryId == null || categoryId!.isEmpty) return;

              Navigator.pop(context, true);
              try {
                String imageUrl = '';
                if (bytes != null && fileName != null) {
                  final task =
                      _storage.uploadSubcategoryImage(bytes!, fileName!);
                  final snapshot = await task;
                  imageUrl = await snapshot.ref.getDownloadURL();
                }

                await _db.addSubcategory(
                  name: name,
                  categoryId: categoryId!,
                  imageUrl: imageUrl,
                  isActive: isActive,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create subcategory: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('Create Subcategory'),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: categoryId,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text((c.data()['name'] ?? c.id).toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocalState(() => categoryId = v),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fileName == null
                                ? 'No image selected (optional)'
                                : fileName!,
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
        const SnackBar(content: Text('Subcategory created')),
      );
    }
  }

  Future<void> _openEditDialog({
    required String id,
    required Map<String, dynamic> data,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> categories,
  }) async {
    final nameController =
        TextEditingController(text: (data['name'] ?? '').toString());
    bool isActive = (data['isActive'] ?? true) as bool;
    String imageUrl = (data['imageUrl'] ?? '').toString();
    String categoryId = (data['categoryId'] ?? '').toString();
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
              if (categoryId.isEmpty) return;

              Navigator.pop(context, true);
              try {
                if (bytes != null && fileName != null) {
                  final task =
                      _storage.uploadSubcategoryImage(bytes!, fileName!);
                  final snapshot = await task;
                  imageUrl = await snapshot.ref.getDownloadURL();
                }

                await _db.updateSubcategory(
                  id: id,
                  name: name,
                  categoryId: categoryId,
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
              title: const Text('Edit Subcategory'),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: categoryId.isEmpty ? null : categoryId,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text((c.data()['name'] ?? c.id).toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocalState(() => categoryId = v ?? ''),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fileName ?? (imageUrl.isEmpty ? 'No image' : imageUrl),
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
        const SnackBar(content: Text('Subcategory updated')),
      );
    }
  }

  Future<void> _deleteSubcategory({
    required String id,
    required String imageUrl,
  }) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Subcategory'),
            content:
                const Text('Are you sure you want to delete this subcategory?'),
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
      if (imageUrl.isNotEmpty) {
        await _storage.deleteImage(imageUrl);
      }
      await _db.deleteSubcategory(id);
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
                    'Subcategories',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.getCategories(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data?.docs ?? const [];
                    return ElevatedButton.icon(
                      onPressed: categories.isEmpty
                          ? null
                          : () => _openCreateDialog(categories: categories),
                      icon: const Icon(Icons.add),
                      label: const Text('New subcategory'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.getCategories(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data?.docs ?? const [];
                    return Row(
                      children: [
                        const Text('Filter by category:'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCategoryId,
                            hint: const Text('All categories'),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All categories'),
                              ),
                              ...categories.map(
                                (c) => DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text((c.data()['name'] ?? c.id).toString()),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _selectedCategoryId = v),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.getSubcategories(categoryId: _selectedCategoryId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final docs = snapshot.data?.docs ?? const [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No subcategories yet'));
                    }

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _db.getCategories(),
                      builder: (context, catSnap) {
                        final categories = catSnap.data?.docs ?? const [];
                        final catNameById = {
                          for (final c in categories)
                            c.id: (c.data()['name'] ?? c.id).toString(),
                        };

                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final doc = docs[i];
                            final data = doc.data();
                            final name = (data['name'] ?? '').toString();
                            final imageUrl = (data['imageUrl'] ?? '').toString();
                            final isActive = (data['isActive'] ?? true) as bool;
                            final categoryId = (data['categoryId'] ?? '').toString();

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
                                    child: const Icon(Icons.category_outlined),
                                  ),
                                ),
                              ),
                              title: Text(name),
                              subtitle: Text(
                                'Category: ${catNameById[categoryId] ?? categoryId} • ${isActive ? 'Active' : 'Inactive'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: isActive,
                                    onChanged: (v) => _db.updateSubcategory(
                                      id: doc.id,
                                      name: name,
                                      categoryId: categoryId,
                                      imageUrl: imageUrl,
                                      isActive: v,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: categories.isEmpty
                                        ? null
                                        : () => _openEditDialog(
                                              id: doc.id,
                                              data: data,
                                              categories: categories,
                                            ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _deleteSubcategory(
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


