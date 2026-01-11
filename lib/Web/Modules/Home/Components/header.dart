import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:myecommerce/Web/service/route_service.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
            final isMobile = constraints.maxWidth < 768;

            return Column(
              children: [
                if (isDesktop) ...[
                  _desktopHeader(),
                  const Gap(12),
                  _desktopSubHeader(context),
                ] else if (isTablet) ...[
                  _tabletHeader(),
                  const Gap(12),
                  _tabletSubHeader(),
                ] else ...[
                  _mobileHeader(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // Desktop Header (>= 1024px)
  Widget _desktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Text(
            'My E-commerce',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _HeaderItem(
            icon: Icons.location_on_outlined,
            text: 'Deliver to',
            boldText: '423651',
            onTap: () {},
          ),
          _Divider(),
          _HeaderItem(
            icon: Icons.fire_truck_outlined,
            text: 'Track Order',
            onTap: () {},
          ),
          _Divider(),
          _HeaderItem(
            icon: Icons.percent_rounded,
            text: 'All Offers',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _desktopSubHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            height: 50,
            width: 50,
            child: Icon(Icons.menu),
          ),
          const Gap(12),
          Text(
            'My E-commerce',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Expanded(flex: 3, child: _SearchBar()),
          _HeaderItem(
            icon: Icons.person_outline,
            text: 'Sign up/Sign in',
            onTap: () {
              context.go(Routes.login);
            },
          ),
          _HeaderItem(
            icon: Icons.shopping_cart_outlined,
            text: 'Cart',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Tablet Header (768px - 1023px)
  Widget _tabletHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Text(
            'My E-commerce',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _HeaderItem(
            icon: Icons.location_on_outlined,
            text: '423651',
            onTap: () {},
          ),
          _Divider(),
          _HeaderItem(
            icon: Icons.fire_truck_outlined,
            text: 'Track',
            onTap: () {},
          ),
          _Divider(),
          _HeaderItem(
            icon: Icons.percent_rounded,
            text: 'Offers',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _tabletSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            height: 45,
            width: 45,
            child: Icon(Icons.menu, size: 22),
          ),
          const Gap(12),
          Expanded(flex: 2, child: _SearchBar()),
          const Gap(8),
          _HeaderItem(
            icon: Icons.person_outline,
            text: 'Account',
            onTap: () {},
          ),
          _HeaderItem(
            icon: Icons.shopping_cart_outlined,
            text: 'Cart',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Mobile Header (< 768px)
  Widget _mobileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                height: 40,
                width: 40,
                child: Icon(Icons.menu, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  'My E-commerce',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.person_outline, size: 22),
                onPressed: () {},
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, size: 22),
                onPressed: () {},
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _SearchBar(),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MobileHeaderItem(
                icon: Icons.location_on_outlined,
                text: '423651',
                onTap: () {},
              ),
              _MobileHeaderItem(
                icon: Icons.fire_truck_outlined,
                text: 'Track',
                onTap: () {},
              ),
              _MobileHeaderItem(
                icon: Icons.percent_rounded,
                text: 'Offers',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Search Bar Widget
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Gap(12),
          Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          const Gap(12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search products...',
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Divider Widget
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}

// Header Item Widget
class _HeaderItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? boldText;
  final VoidCallback onTap;

  const _HeaderItem({
    required this.icon,
    required this.text,
    this.boldText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const Gap(6),
            RichText(
              text: TextSpan(
                text: text,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                children: boldText != null
                    ? [
                        TextSpan(
                          text: ' $boldText',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mobile Header Item Widget
class _MobileHeaderItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MobileHeaderItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const Gap(4),
            Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
