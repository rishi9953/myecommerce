import 'package:flutter/material.dart';
import 'package:myecommerce/Web/Modules/Home/Components/banners.dart';
import 'package:myecommerce/Web/Modules/Home/Components/best_deal_category.dart';
import 'package:myecommerce/Web/Modules/Home/Components/brands.dart';
import 'package:myecommerce/Web/Modules/Home/Components/categories.dart';
import 'package:myecommerce/Web/Modules/Home/Components/daily_essentials.dart';
import 'package:myecommerce/Web/Modules/Home/Components/footer.dart';
import 'package:myecommerce/Web/Modules/Home/Components/header.dart';
import 'package:myecommerce/Web/Modules/Home/Components/shop_from_categories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  static const double headerHeight = 140; // adjust to your Header height

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          /// 🔹 Scrollable Content
          Padding(
            padding: const EdgeInsets.only(top: headerHeight),
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              children: [
                CategoryNavigationBar(),
                Divider(color: Colors.grey.shade300),
                Banners(),
                ShopByBrands(),
                ShopFromCategories(),
                BestDealCategory(),
                DailyEssentials(),
                Footer(),
              ],
            ),
          ),

          /// 🔹 Fixed Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 0,
              color: Colors.white,
              child: Column(
                children: [
                  Header(),
                  Divider(color: Colors.grey.shade300),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D9FD8),
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}
