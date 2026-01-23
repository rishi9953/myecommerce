import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:myecommerce/Web/Modules/Home/Components/footer.dart';
import 'package:myecommerce/Web/Modules/Home/Components/header.dart';
import 'package:myecommerce/Web/service/firestore_storefront_service.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;

  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String selectedSort = 'Position';
  int itemsPerPage = 9;
  RangeValues priceRange = const RangeValues(0, 10000);
  List<String> selectedBrands = ['Zara'];

  // Expandable sections state
  bool isSizeExpanded = false;
  bool isBrandExpanded = true;
  bool isPriceExpanded = false;
  bool isDiscountExpanded = false;
  bool isAvailabilityExpanded = false;

  final _store = FirestoreStorefrontService();
  String? selectedSubcategoryId;

  final List<String> brands = [
    'Nike',
    'Reebook',
    'Zara',
    'Gearo',
    'Indi',
    'Aei',
    'Lulu',
    'Beast',
  ];

  final List<String> sortOptions = [
    'Position',
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
    'Rating',
  ];

  final List<int> itemsPerPageOptions = [9, 18, 27, 36];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveService.isMobile(context);
    final isTablet = ResponsiveService.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          /// 🔒 FIXED HEADER
          SliverPersistentHeader(
            pinned: true,
            delegate: HeaderDelegate(),
            floating: false,
          ),

          /// MAIN CONTENT
          SliverToBoxAdapter(
            child: Container(
              padding: ResponsiveService.getResponsivePadding(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FILTERS
                  if (!isMobile)
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildFiltersSection(),
                    ),

                  if (!isMobile) const Gap(16),

                  /// PRODUCTS
                  Expanded(
                    child: Column(
                      children: [
                        _buildHeaderSection(isMobile),
                        const Gap(16),
                        _buildProductGrid(isMobile, isTablet),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// FOOTER
          SliverToBoxAdapter(child: const Footer()),
        ],
      ),
    );
  }

  /// PRODUCTS TOP BAR
  Widget _buildHeaderSection(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const Gap(8),
              Text(
                widget.categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _store.subcategories(categoryId: widget.categoryId),
                builder: (context, snap) {
                  final subs = snap.data?.docs ?? const [];
                  return SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      value: selectedSubcategoryId,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Subcategory',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...subs.map(
                          (d) => DropdownMenuItem<String>(
                            value: d.id,
                            child: Text((d.data()['name'] ?? d.id).toString()),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => selectedSubcategoryId = v),
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View mode buttons
                IconButton(
                  icon: const Icon(Icons.grid_view, size: 20),
                  onPressed: () {},
                  color: Colors.blue,
                ),
                IconButton(
                  icon: const Icon(Icons.view_list, size: 20),
                  onPressed: () {},
                ),
                const Gap(16),

                // Items count
                Text(
                  'Browse products',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const Gap(16),

                // Items per page
                Text('To Show:', style: TextStyle(color: Colors.grey.shade700)),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<int>(
                    value: itemsPerPage,
                    underline: const SizedBox(),
                    items: itemsPerPageOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => itemsPerPage = value!),
                  ),
                ),
                const Gap(16),

                // Sort dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<String>(
                    value: selectedSort,
                    underline: const SizedBox(),
                    items: sortOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedSort = value!),
                  ),
                ),

                if (isMobile) ...[
                  const Gap(8),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showMobileFilters(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PRODUCT GRID
  Widget _buildProductGrid(bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 3);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _store.products(
        categoryId: widget.categoryId,
        subcategoryId: selectedSubcategoryId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No products found.'),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.68,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data();
            return InkWell(
              onTap: () => context.go('/product/${doc.id}'),
              child: ProductCard(product: {
                'id': doc.id,
                'title': (data['title'] ?? '').toString(),
                'price': data['price'] ?? 0,
                'imageUrl': ((data['imageUrls'] as List?)?.cast<String>() ?? const [])
                    .cast<String>()
                    .cast<String>()
                    .isEmpty
                    ? ''
                    : ((data['imageUrls'] as List?)!.first).toString(),
              }),
            );
          },
        );
      },
    );
  }

  /// FILTERS
  Widget _buildFiltersSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size filter
          _buildFilterSection(
            title: 'Size',
            isExpanded: isSizeExpanded,
            onToggle: () => setState(() => isSizeExpanded = !isSizeExpanded),
            child: Container(),
          ),

          Divider(color: Colors.grey.shade300),

          // Brand filter
          _buildFilterSection(
            title: 'Brand',
            isExpanded: isBrandExpanded,
            onToggle: () => setState(() => isBrandExpanded = !isBrandExpanded),
            child: Column(
              children: brands
                  .map(
                    (b) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(b, style: const TextStyle(fontSize: 14)),
                      value: selectedBrands.contains(b),
                      onChanged: (v) => setState(
                        () => v!
                            ? selectedBrands.add(b)
                            : selectedBrands.remove(b),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          Divider(color: Colors.grey.shade300),

          // Price Range filter
          _buildFilterSection(
            title: 'Price Range',
            isExpanded: isPriceExpanded,
            onToggle: () => setState(() => isPriceExpanded = !isPriceExpanded),
            child: Column(
              children: [
                RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 10000,
                  onChanged: (v) => setState(() => priceRange = v),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${priceRange.start.round()}'),
                      Text('₹${priceRange.end.round()}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade300),

          // Discount filter
          _buildFilterSection(
            title: 'Discount',
            isExpanded: isDiscountExpanded,
            onToggle: () =>
                setState(() => isDiscountExpanded = !isDiscountExpanded),
            child: Container(),
          ),

          Divider(color: Colors.grey.shade300),

          // Availability filter
          _buildFilterSection(
            title: 'Availability',
            isExpanded: isAvailabilityExpanded,
            onToggle: () => setState(
              () => isAvailabilityExpanded = !isAvailabilityExpanded,
            ),
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Icon(isExpanded ? Icons.remove : Icons.add, size: 20),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[const Gap(8), child],
      ],
    );
  }

  void _showMobileFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _buildFiltersSection(),
      ),
    );
  }
}

/// 🔒 HEADER DELEGATE (FIXED)
class HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 130;

  @override
  double get maxExtent => 140;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const Material(
      elevation: 0,
      color: Colors.white,
      child: Column(children: [Header(), Divider(height: 1)]),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

/// PRODUCT CARD
class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Card(
        elevation: isHovered ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: Image.asset(
                      '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.network(
                            (widget.product['imageUrl'] ?? '').toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 60),
                          ),
                    ),
                  ),

                  // Flash Deal Timer
                  if (widget.product['flashDeal'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Flash Deal Ends in ${widget.product['flashDeal']} !',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Gap(4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: 0.6,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.product['flashDeal'] == '1 Hours'
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action buttons (visible on hover)
                  if (isHovered)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        children: [
                          _buildActionButton(Icons.shopping_cart),
                          const Gap(8),
                          _buildActionButton(Icons.add),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (widget.product['title'] ?? '').toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const Gap(4),
                      Text(
                        '4.5',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '(ratings)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.local_offer, size: 16),
                          label: Text(
                            'GET DEAL',
                            style: const TextStyle(fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            'BUY NOW - ₹${widget.product['price'] ?? 0}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }
}
