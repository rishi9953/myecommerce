import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9FD8), Color(0xFF1B8FCC)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return _buildDesktopLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              '© 2022 All rights reserved. Reliance Retail Ltd.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildContactSection()),
        Expanded(flex: 2, child: _buildPopularCategories()),
        Expanded(flex: 2, child: _buildCustomerServices()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactSection(),
        const SizedBox(height: 32),
        _buildPopularCategories(),
        const SizedBox(height: 32),
        _buildCustomerServices(),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MegaMart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Contact Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(Icons.phone, 'Whats App', '+1 202-918-2132'),
        const SizedBox(height: 12),
        _buildContactItem(Icons.phone, 'Call Us', '+1 202-918-2132'),
        // const SizedBox(height: 24),
        // const Text(
        //   'Download App',
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontSize: 16,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        // const SizedBox(height: 16),
        // Row(
        //   children: [
        //     _buildAppButton('assets/app_store.png', 'App Store'),
        //     const SizedBox(width: 12),
        //     _buildAppButton('assets/play_store.png', 'Play Store'),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String number) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            Text(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppButton(String assetPath, String storeName) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            storeName == 'App Store' ? Icons.apple : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                storeName == 'App Store' ? 'Download on the' : 'GET IT ON',
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
              Text(
                storeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Popular Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink('Staples'),
        _buildFooterLink('Beverages'),
        _buildFooterLink('Personal Care'),
        _buildFooterLink('Home Care'),
        _buildFooterLink('Baby Care'),
        _buildFooterLink('Vegetables & Fruits'),
        _buildFooterLink('Snacks & Foods'),
        _buildFooterLink('Dairy & Bakery'),
      ],
    );
  }

  Widget _buildCustomerServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Services',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink('About Us'),
        _buildFooterLink('Terms & Conditions'),
        _buildFooterLink('FAQ'),
        _buildFooterLink('Privacy Policy'),
        _buildFooterLink('E-waste Policy'),
        _buildFooterLink('Cancellation & Return Policy'),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text(
            '•  ',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
