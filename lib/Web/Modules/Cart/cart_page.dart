import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myecommerce/Web/Modules/Home/Components/footer.dart';
import 'package:myecommerce/Web/Modules/Home/Components/header.dart';
import 'package:myecommerce/Web/service/cart/cart_scope.dart';
import 'package:myecommerce/Web/service/route_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cart',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (!cart.loaded)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ))
                  else if (cart.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Your cart is empty.'),
                    )
                  else
                    Card(
                      child: Column(
                        children: [
                          ...cart.items.map(
                            (item) => ListTile(
                              leading: Image.network(
                                item.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported_outlined),
                                ),
                              ),
                              title: Text(item.title),
                              subtitle: Text('₹ ${item.price}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => cart.setQty(item.productId, item.qty - 1),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('${item.qty}'),
                                  IconButton(
                                    onPressed: () => cart.setQty(item.productId, item.qty + 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Subtotal: ₹ ${cart.subtotal}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => context.go(Routes.checkout),
                                  child: const Text('Checkout'),
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
          const SliverToBoxAdapter(child: Footer()),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 130;

  @override
  double get maxExtent => 140;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const Material(
      elevation: 0,
      color: Colors.white,
      child: Column(children: [Header(), Divider(height: 1)]),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}






