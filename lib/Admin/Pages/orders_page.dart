import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Firebase/firebase_services.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static const List<String> statuses = [
    'pending',
    'paid',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'refunded',
  ];

  @override
  Widget build(BuildContext context) {
    final db = FirebaseServicesAdmin();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: db.getOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final docs = snapshot.data?.docs ?? const [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No orders yet (collection `orders` is empty).',
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data();
                        final status = (data['status'] ?? 'pending').toString();
                        final total = (data['total'] ?? '').toString();
                        final userId = (data['userId'] ?? '').toString();

                        return ListTile(
                          title: Text('Order ${doc.id}'),
                          subtitle: Text('User: $userId  •  Total: $total'),
                          trailing: DropdownButton<String>(
                            value: statuses.contains(status) ? status : 'pending',
                            items: statuses
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) async {
                              if (v == null) return;
                              await db.updateOrderStatus(orderId: doc.id, status: v);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Order updated to $v')),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






