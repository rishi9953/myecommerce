import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../Firebase/firebase_services.dart';
import '../Firebase/firebase_storage_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final FirebaseServicesAdmin _db = FirebaseServicesAdmin();
  final FirebaseStorageService _storage = FirebaseStorageService();

  Future<void> _openCreateProductDialog({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> categories,
  }) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '0');
    String? categoryId = categories.isEmpty ? null : categories.first.id;
    bool isActive = true;
    final List<Uint8List> imageBytesList = [];
    final List<String> imageNames = [];

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> pickImages() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: true,
              );
              if (result != null && result.files.isNotEmpty) {
                setLocalState(() {
                  imageBytesList
                    ..clear()
                    ..addAll(result.files.map((e) => e.bytes!).whereType<Uint8List>());
                  imageNames
                    ..clear()
                    ..addAll(result.files.map((e) => e.name));
                });
              }
            }

            Future<void> create() async {
              final title = titleController.text.trim();
              final description = descController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              final stock = int.tryParse(stockController.text.trim());

              if (title.isEmpty || description.isEmpty) return;
              if (price == null || price < 0) return;
              if (stock == null || stock < 0) return;
              if (categoryId == null || categoryId!.isEmpty) return;
              if (imageBytesList.isEmpty) return;

              Navigator.pop(context, true);
              try {
                // Create product first to get ID, then upload images to /products/{id}/...
                final ref = await _db.addProduct(
                  title: title,
                  description: description,
                  price: price,
                  stock: stock,
                  categoryId: categoryId!,
                  imageUrls: const [],
                  isActive: isActive,
                );

                final uploadedUrls = <String>[];
                for (var i = 0; i < imageBytesList.length; i++) {
                  final task = _storage.uploadProductImage(
                    imageBytesList[i],
                    imageNames[i],
                    productId: ref.id,
                  );
                  final snapshot = await task;
                  uploadedUrls.add(await snapshot.ref.getDownloadURL());
                }

                await _db.updateProduct(
                  id: ref.id,
                  title: title,
                  description: description,
                  price: price,
                  stock: stock,
                  categoryId: categoryId!,
                  imageUrls: uploadedUrls,
                  isActive: isActive,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create product: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('Create Product'),
              content: SizedBox(
                width: 720,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Price'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Stock'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Category:'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              imageNames.isEmpty
                                  ? 'No images selected'
                                  : '${imageNames.length} image(s) selected',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: pickImages,
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Select images'),
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

    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    stockController.dispose();

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created')),
      );
    }
  }

  Future<void> _deleteProduct({
    required String id,
    required List<String> imageUrls,
  }) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: const Text('Are you sure you want to delete this product?'),
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
      for (final url in imageUrls) {
        await _storage.deleteImage(url);
      }
      await _db.deleteProduct(id);
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
            const Text(
              'Products',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 320,
                    child: Card(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _db.getCategories(),
                        builder: (context, snapshot) {
                          final categories = snapshot.data?.docs ?? const [];
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: categories.isEmpty
                                          ? null
                                          : () => _openCreateProductDialog(
                                                categories: categories,
                                              ),
                                      icon: const Icon(Icons.add),
                                      label: const Text('New'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  categories.isEmpty
                                      ? 'Create at least 1 category first.'
                                      : 'You have ${categories.length} categories.',
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Products are stored in Firestore collection `products`.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _db.getProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Center(child: Text('No products yet'));
                          }

                          return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final doc = docs[i];
                              final data = doc.data();
                              final title = (data['title'] ?? '') as String;
                              final price = (data['price'] ?? 0).toString();
                              final stock = (data['stock'] ?? 0).toString();
                              final isActive = (data['isActive'] ?? true) as bool;
                              final imageUrls =
                                  (data['imageUrls'] as List?)?.cast<String>() ?? const [];

                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    imageUrls.isEmpty ? '' : imageUrls.first,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.inventory_2_outlined),
                                    ),
                                  ),
                                ),
                                title: Text(title),
                                subtitle: Text('Price: $price | Stock: $stock'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: isActive,
                                      onChanged: (v) => _db.updateProduct(
                                        id: doc.id,
                                        title: title,
                                        description: (data['description'] ?? '').toString(),
                                        price: double.tryParse(price) ?? 0,
                                        stock: int.tryParse(stock) ?? 0,
                                        categoryId: (data['categoryId'] ?? '').toString(),
                                        imageUrls: imageUrls,
                                        isActive: v,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      onPressed: () => _deleteProduct(
                                        id: doc.id,
                                        imageUrls: imageUrls,
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
          ],
        ),
      ),
    );
  }
}






