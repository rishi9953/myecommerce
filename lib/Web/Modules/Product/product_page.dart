import 'package:flutter/material.dart';
import 'package:myecommerce/Web/Modules/Categories/category_page.dart';
import 'package:myecommerce/Web/Modules/Home/Components/footer.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedImageIndex = 0;

  final List<String> productImages = [
    'assets/images/watch1.png',
    'assets/images/watch2.png',
  ];

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LEFT SIDE - PRODUCT IMAGES
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        /// Thumbnail Images
                        Column(
                          children: List.generate(
                            productImages.length,
                            (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImageIndex = index;
                                });
                              },
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
                                child: Image.asset(
                                  productImages[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        /// Main Image
                        Expanded(
                          child: Container(
                            height: 600,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Image.asset(
                              productImages[selectedImageIndex],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 60),

                  /// RIGHT SIDE - PRODUCT DETAILS
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Brand
                        const Text(
                          'BOSS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        /// Product Name
                        Text(
                          'Women Round Analogue Watch 1502730',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// Rating
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: const [
                                  Text(
                                    '3.8',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '5 Ratings',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        /// Price
                        Row(
                          children: [
                            Text(
                              'MRP',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '₹ 13995',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'inclusive of all taxes',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        const SizedBox(height: 32),

                        /// More Color
                        const Text(
                          'MORE COLOR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Image.asset(
                            'assets/images/watch_alt.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),

                        /// Size Selection
                        const Text(
                          'SELECT SIZE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 120,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink[400]!),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Onesize',
                                style: TextStyle(
                                  color: Colors.pink[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '1 left',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        /// Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink[400],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.shopping_bag_outlined, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'ADD TO BAG',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.favorite_border,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'WISHLIST',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        /// Delivery Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '₹ 13995',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Get it by Sat, Jan 10 - 110033',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  children: const [
                                    TextSpan(text: 'Seller: '),
                                    TextSpan(
                                      text: 'OLYMPIA INDUSTRIES LIMITED',
                                      style: TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
