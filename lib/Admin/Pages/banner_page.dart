import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Firebase/firebase_services.dart';
import '../Firebase/firebase_storage_service.dart';

class BannersPage extends StatefulWidget {
  const BannersPage({super.key});

  @override
  State<BannersPage> createState() => _BannersPageState();
}

class _BannersPageState extends State<BannersPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();

  List<Uint8List> _imageBytesList = [];
  List<String> _imageNames = [];
  List<UploadTask> _uploadTasks = [];
  bool _isUploading = false;

  final FirebaseServicesAdmin _firestoreService = FirebaseServicesAdmin();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imageBytesList = result.files.map((e) => e.bytes!).toList();
          _imageNames = result.files.map((e) => e.name).toList();
        });
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e', isError: true);
    }
  }

  Future<void> _uploadBanner() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytesList.isEmpty) {
      _showSnackBar('Please select at least one banner image', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadTasks.clear();
    });

    try {
      for (int i = 0; i < _imageBytesList.length; i++) {
        final task = _storageService.uploadBannerImage(
          _imageBytesList[i],
          _imageNames[i],
        );

        setState(() {
          _uploadTasks.add(task);
        });

        final snapshot = await task;
        final imageUrl = await snapshot.ref.getDownloadURL();

        await _firestoreService.addBanner(
          title: _titleController.text,
          imageUrl: imageUrl,
          link: _linkController.text.trim(),
        );
      }

      _showSnackBar(
        'Successfully uploaded ${_imageBytesList.length} banner(s)',
        isError: false,
      );
      _resetForm();
    } catch (e) {
      _showSnackBar('Error uploading banners: $e', isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _linkController.clear();
    setState(() {
      _imageBytesList.clear();
      _imageNames.clear();
      _uploadTasks.clear();
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imageBytesList.removeAt(index);
      _imageNames.removeAt(index);
    });
  }

  Future<void> _deleteBanner(String docId, String imageUrl) async {
    final confirm = await _showDeleteConfirmation();
    if (!confirm) return;

    try {
      await _storageService.deleteImage(imageUrl);
      await _firestoreService.deleteBanner(docId);
      _showSnackBar('Banner deleted successfully', isError: false);
    } catch (e) {
      _showSnackBar('Error deleting banner: $e', isError: true);
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Banner'),
            content: const Text('Are you sure you want to delete this banner?'),
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
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            backgroundColor: Colors.white,
            elevation: 2,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: const Text(
                'Banner Management',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAddBannerCard(),
                const SizedBox(height: 32),
                _buildBannersListSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBannerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_photo_alternate, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Banner',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Banner Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),
              _buildImagePickerSection(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Redirect Link (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.link),
                  hintText: 'https://example.com',
                ),
              ),
              if (_uploadTasks.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildUploadProgress(),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_imageBytesList.isNotEmpty)
                    TextButton.icon(
                      onPressed: _isUploading ? null : _resetForm,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadBanner,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      _isUploading ? 'Uploading...' : 'Upload Banners',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banner Images',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isUploading
                    ? Colors.grey.shade300
                    : Colors.blue.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _imageBytesList.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Click to select banner images',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can select multiple images',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _imageBytesList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytesList[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (!_isUploading)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        if (_imageBytesList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_imageBytesList.length} image(s) selected',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Progress',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ..._uploadTasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          return StreamBuilder<TaskSnapshot>(
            stream: task.snapshotEvents,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final progress =
                  snapshot.data!.bytesTransferred / snapshot.data!.totalBytes;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _imageNames[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBannersListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.view_carousel, color: Colors.blue[700]),
            const SizedBox(width: 12),
            const Text(
              'All Banners',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 500,
          child: StreamBuilder(
            stream: _firestoreService.getBanners(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading banners',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No banners found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload your first banner to get started',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              final banners = snapshot.data!.docs;

              return ListView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final doc = banners[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isActive = data['isActive'] ?? true;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      onTap: () {
                        html.window.open(data['imageUrl'], '_blank');
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['imageUrl'],
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        data['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  (data['link'] ?? '').isEmpty
                                      ? 'No redirect link'
                                      : data['link'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.shade50
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: isActive,
                            onChanged: (v) {
                              _firestoreService.toggleBanner(doc.id, v);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            tooltip: 'Delete banner',
                            onPressed: () {
                              _deleteBanner(doc.id, data['imageUrl']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
