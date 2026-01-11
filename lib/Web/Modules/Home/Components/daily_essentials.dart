import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';

class DailyEssentials extends StatelessWidget {
  const DailyEssentials({super.key});

  final List<Map<String, String>> productList = const [
    {
      'label': 'Daily Essentials',
      'image': 'assets/essentialsItems/1.png',
      'discount': '50',
    },
    {
      'label': 'Vegitables',
      'image': 'assets/essentialsItems/2.png',
      'discount': '50',
    },
    {
      'label': 'Fruits',
      'image': 'assets/essentialsItems/3.png',
      'discount': '50',
    },
    {
      'label': 'Strowberry',
      'image': 'assets/essentialsItems/4.png',
      'discount': '50',
    },
    {
      'label': 'Mango',
      'image': 'assets/essentialsItems/5.png',
      'discount': '50',
    },
    {
      'label': 'Cherry',
      'image': 'assets/essentialsItems/6.png',
      'discount': '50',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveService.getResponsivePadding(context),
      child: Column(
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
                  'Daily Essentials',
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

          /// Horizontal Products
          SizedBox(
            height: ResponsiveService.getResponsiveValue(
              context: context,
              mobile: 220,
              tablet: 240,
              desktop: 260,
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: productList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = productList[index];
                return buildProductItem(
                  context,
                  item['image']!,
                  item['label']!,
                  item['discount']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductItem(
    BuildContext context,
    String imagePath,
    String label,
    String discount,
  ) {
    final double size = ResponsiveService.getResponsiveValue(
      context: context,
      mobile: 120,
      tablet: 140,
      desktop: 150,
    );

    return Column(
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveService.getResponsiveFontSize(
              context,
              baseFontSize: 14,
            ),
          ),
        ),
        Text(
          'Up to $discount% off',
          style: TextStyle(
            fontSize: ResponsiveService.getResponsiveFontSize(
              context,
              baseFontSize: 12,
            ),
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
