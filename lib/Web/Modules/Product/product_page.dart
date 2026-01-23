import 'package:flutter/material.dart';
import 'package:myecommerce/Web/Modules/Categories/category_page.dart';
import 'package:myecommerce/Web/Modules/Home/Components/footer.dart';
import 'package:myecommerce/Web/service/cart/cart_scope.dart';
import 'package:myecommerce/Web/service/firestore_storefront_service.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedImageIndex = 0;

  final _store = FirestoreStorefrontService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// 🔒 FIXED HEADER
          SliverPersistentHeader(
            pinned: true,
            delegate: HeaderDelegate(),
            floating: false,
          ),

          /// BREADCRUMB
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
              child: Text(
                'Home / Accessories / Women Accessories / Watches / BOSS Watches > More By BOSS',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ),

          /// MAIN CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              child: FutureBuilder(
                future: _store.productById(widget.productId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final doc = snapshot.data;
                  if (doc == null || !doc.exists) {
                    return const Text('Product not found');
                  }
                  final data = doc.data()!;
                  final title = (data['title'] ?? '').toString();
                  final description = (data['description'] ?? '').toString();
                  final price = (data['price'] ?? 0) as num;
                  final images = (data['imageUrls'] as List?)?.cast<String>() ?? const [];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Column(
                              children: List.generate(
                                images.length,
                                (index) => GestureDetector(
                                  onTap: () => setState(() => selectedImageIndex = index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    width: 80,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedImageIndex == index
                                            ? Colors.black
                                            : Colors.grey[300]!,
                                        width: selectedImageIndex == index ? 2 : 1,
                                      ),
                                    ),
                                    child: Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                height: 600,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: images.isEmpty
                                    ? const Center(child: Icon(Icons.image_not_supported_outlined))
                                    : Image.network(
                                        images[selectedImageIndex.clamp(0, images.length - 1)],
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image, size: 48),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 60),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(description, style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text('MRP', style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(width: 8),
                                Text(
                                  '₹ $price',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final cart = CartScope.of(context);
                                      await cart.addOrIncrement(
                                        productId: doc.id,
                                        title: title,
                                        imageUrl: images.isEmpty ? '' : images.first,
                                        price: price,
                                      );
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Added to cart')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink[400],
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: const Text('ADD TO BAG'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          /// FOOTER
          const SliverToBoxAdapter(child: Footer()),
        ],
      ),
    );
  }
}
