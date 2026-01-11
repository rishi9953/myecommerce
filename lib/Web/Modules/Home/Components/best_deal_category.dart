import 'package:flutter/material.dart';

class BestDealCategory extends StatefulWidget {
  const BestDealCategory({super.key});

  @override
  State<BestDealCategory> createState() => _BestDealCategoryState();
}

class _BestDealCategoryState extends State<BestDealCategory> {
  List bestDealItems = [
    // Add your best deal items here
    'assets/brands/1.png',
    'assets/brands/2.png',
    'assets/brands/3.png',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: Text(
                  'Top Electronic Brands',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              TextButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
                label: Text('View All', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 300,

            width: double.infinity,
            child: PageView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Row(
                  children: bestDealItems
                      .map((item) => bestDealItem(item))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget bestDealItem(String imagePath) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }
}
