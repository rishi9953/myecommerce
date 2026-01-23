import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:myecommerce/Web/service/firestore_storefront_service.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';
import 'package:myecommerce/Web/service/route_service.dart';

class ShopFromCategories extends StatelessWidget {
  ShopFromCategories({super.key});

  final _store = FirestoreStorefrontService();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveService.isMobile(context);

    return Padding(
      padding: ResponsiveService.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: Text(
                  'Shop from Categories',
                  style: TextStyle(
                    fontSize: ResponsiveService.getResponsiveFontSize(
                      context,
                      baseFontSize: 20,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
                label: const Text(
                  'View All',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// MOBILE → ListView | TABLET/DESKTOP → Wrap
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _store.categories(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? const [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No categories yet'),
                );
              }

              final items = docs
                  .map(
                    (d) => {
                      'id': d.id,
                      'label': (d.data()['name'] ?? d.id).toString(),
                      'icon': (d.data()['imageUrl'] ?? '').toString(),
                    },
                  )
                  .toList();

              return isMobile
                  ? SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => context.go(
                              '${Routes.category}/${items[index]['id']}?name=${Uri.encodeComponent(items[index]['label']!)}',
                            ),
                            child: CategoryChip(
                              label: items[index]['label']!,
                              icon: items[index]['icon']!,
                              isNetwork: true,
                            ),
                          );
                        },
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 16,
                      children: List.generate(
                        items.length,
                        (index) => InkWell(
                          onTap: () => context.go(
                            '${Routes.category}/${items[index]['id']}?name=${Uri.encodeComponent(items[index]['label']!)}',
                          ),
                          child: CategoryChip(
                            label: items[index]['label']!,
                            icon: items[index]['icon']!,
                            isNetwork: true,
                          ),
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}

/// Category Item (UNCHANGED UI)
class CategoryChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isNetwork;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    final double containerSize = ResponsiveService.getResponsiveValue(
      context: context,
      mobile: 120,
      tablet: 130,
      desktop: 140,
    );

    final double imageSize = ResponsiveService.getResponsiveValue(
      context: context,
      mobile: 80,
      tablet: 90,
      desktop: 100,
    );

    return SizedBox(
      width: containerSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: imageSize,
            width: imageSize,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: isNetwork
                ? Image.network(
                    icon,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.photo,
                      size: 24,
                      color: Colors.grey.shade400,
                    ),
                  )
                : Image.asset(
                    icon,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.photo,
                      size: 24,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
          const Gap(12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveService.getResponsiveFontSize(
                context,
                baseFontSize: 14,
              ),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
