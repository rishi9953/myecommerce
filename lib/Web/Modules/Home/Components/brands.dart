import 'package:flutter/material.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';

class ShopByBrands extends StatelessWidget {
  const ShopByBrands({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> brands = [
      'assets/brands2/zara.png',
      'assets/brands2/d&g.png',
      'assets/brands2/h&m.png',
      'assets/brands2/chanel.png',
      'assets/brands2/prada.png',
      'assets/brands2/biba.png',
    ];

    final isMobile = ResponsiveService.isMobile(context);

    // Responsive padding
    final horizontalPadding = ResponsiveService.getResponsiveValue(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 80.0,
      largeDesktop: 80.0,
    );

    // Responsive font size
    final titleFontSize = ResponsiveService.getResponsiveFontSize(
      context,
      baseFontSize: 20.0,
    );

    // Responsive brand widget size
    final brandSize = ResponsiveService.getResponsiveValue(
      context: context,
      mobile: 110.0,
      tablet: 120.0,
      desktop: 138.0,
      largeDesktop: 138.0,
    );

    // Responsive spacing
    final spacing = ResponsiveService.getResponsiveValue(
      context: context,
      mobile: 12.0,
      tablet: 20.0,
      desktop: 30.0,
      largeDesktop: 30.0,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  'Shop by Brands',
                  style: TextStyle(
                    fontSize: titleFontSize,
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
          const SizedBox(height: 16),

          // Mobile: Horizontal ListView
          if (isMobile)
            SizedBox(
              height: brandSize + 20,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                separatorBuilder: (context, index) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {},
                    child: brandWidget(brands[index], brandSize),
                  );
                },
              ),
            )
          // Tablet & Desktop: Wrap layout
          else
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(
                brands.length,
                (index) => InkWell(
                  onTap: () {},
                  child: brandWidget(brands[index], brandSize),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget brandWidget(String path, double size) {
    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(path, fit: BoxFit.contain),
    );
  }
}
