import 'package:flutter/material.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';

class CategoryNavigationBar extends StatefulWidget {
  const CategoryNavigationBar({super.key});

  @override
  State<CategoryNavigationBar> createState() => _CategoryNavigationBarState();
}

class _CategoryNavigationBarState extends State<CategoryNavigationBar> {
  int selectedIndex = 0;
  bool showOptions = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  final Map<String, List<String>> categoriesWithOptions = {
    'Groceries': [
      'Fresh Vegetables',
      'Fruits',
      'Dairy Products',
      'Bakery',
      'Beverages',
    ],
    'Premium Fruits': [
      'Imported Fruits',
      'Organic Fruits',
      'Seasonal Fruits',
      'Exotic Fruits',
    ],
    'Home & Kitchen': [
      'Cookware',
      'Kitchen Tools',
      'Storage',
      'Dining',
      'Appliances',
    ],
    'Fashion': [
      'Men\'s Wear',
      'Women\'s Wear',
      'Kids Wear',
      'Footwear',
      'Accessories',
    ],
    'Electronics': ['Mobiles', 'Laptops', 'Cameras', 'Audio', 'Smart Devices'],
    'Beauty': ['Skincare', 'Makeup', 'Haircare', 'Fragrances', 'Personal Care'],
    'Home Improvement': [
      'Tools',
      'Hardware',
      'Paints',
      'Lighting',
      'Furniture',
    ],
    'Sports, Toys & Luggage': [
      'Sports Equipment',
      'Fitness',
      'Toys',
      'Bags',
      'Travel Gear',
    ],
  };

  List<String> get categories => categoriesWithOptions.keys.toList();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    showOptions = false;
  }

  void _showCategoryOptions(BuildContext context, int index) {
    _removeOverlay();

    setState(() {
      selectedIndex = index;
      showOptions = true;
    });

    final String selectedCategory = categories[index];
    final List<String> options = categoriesWithOptions[selectedCategory] ?? [];

    _overlayEntry = _createOverlayEntry(context, options);
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(BuildContext context, List<String> options) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier to detect outside clicks
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _removeOverlay();
                });
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          // Options dropdown
          Positioned(
            width: MediaQuery.of(context).size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 5),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Handle option selection
                          print('Selected: ${options[index]}');
                          setState(() {
                            _removeOverlay();
                          });
                          // Add your navigation or action here
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                options[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ResponsiveBuilder(
        builder: (context, deviceType) {
          if (deviceType == DeviceType.mobile) {
            return _buildMobileDropdown();
          }
          return _buildScrollableChips(deviceType);
        },
      ),
    );
  }

  Widget _buildMobileDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedIndex,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedIndex = newValue;
                      showOptions = !showOptions;
                    });
                  }
                },
                items: categories.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
              ),
            ),
          ),
          // Show options below dropdown on mobile
          if (showOptions) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount:
                    categoriesWithOptions[categories[selectedIndex]]?.length ??
                    0,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final option =
                      categoriesWithOptions[categories[selectedIndex]]![index];
                  return InkWell(
                    onTap: () {
                      print('Selected: $option');
                      setState(() {
                        showOptions = false;
                      });
                      // Add your navigation or action here
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScrollableChips(DeviceType deviceType) {
    final horizontalPadding = deviceType == DeviceType.tablet ? 24.0 : 80.0;
    final chipHeight = deviceType == DeviceType.tablet ? 38.0 : 40.0;
    final fontSize = deviceType == DeviceType.tablet ? 13.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 10,
      ),
      child: SizedBox(
        height: chipHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CategoryChip(
                label: categories[index],
                isSelected: isSelected,
                fontSize: fontSize,
                onTap: () {
                  _showCategoryOptions(context, index);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double fontSize;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.fontSize = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E9BD6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E9BD6) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
