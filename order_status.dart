import 'dart:async';
import 'package:flutter/material.dart';
import 'dataservice.dart';

class OrderStatusPage extends StatelessWidget {
  const OrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderNo = currentOrderNumber; // same as order confirmation
    final shop = selectedShop;          // chosen on home.dart

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order status'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _OrderSummaryCard(
              orderNumber: orderNo,
              shop: shop,
            ),
            const SizedBox(height: 16),

            // ✅ 2-step simulated progress
            const _OrderProgressCard(),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //  add directions later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Get Directions',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/menu');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Order Again',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final int? orderNumber;
  final Shops? shop;

  const _OrderSummaryCard({
    required this.orderNumber,
    required this.shop,
  });

  double get _total {
    double sum = 0;
    for (final line in cart.values) {
      sum += line.item.price * line.qty;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Order Number\n#${orderNumber ?? '----'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        shop?.shopName ?? 'No shop selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        shop?.shopLocation ?? '',
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Items from cart
            if (cart.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No items in cart.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...cart.values.map((line) {
                final lineTotal = line.item.price * line.qty;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text('${line.qty}x ${line.item.item}')),
                      Text('\$${lineTotal.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              }),

            const Divider(height: 24),

            Row(
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 2-step simulation:
/// 0s  -> Order Placed (In progress...)
/// 3s  -> Preparing (Your food is being prepared...)
/// 7s  -> Delivered (Your order has arrived.)
class _OrderProgressCard extends StatefulWidget {
  const _OrderProgressCard();

  @override
  State<_OrderProgressCard> createState() => _OrderProgressCardState();
}

class _OrderProgressCardState extends State<_OrderProgressCard> {
  int stage = 0; // 0=placed, 1=preparing, 2=delivered
  Timer? _t1;
  Timer? _t2;

  @override
  void initState() {
    super.initState();

    _t1 = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => stage = 1);
    });

    _t2 = Timer(const Duration(seconds: 7), () {
      if (!mounted) return;
      setState(() => stage = 2);
    });
  }

  @override
  void dispose() {
    _t1?.cancel();
    _t2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (stage) {
      0 => 'Order Placed',
      1 => 'Preparing',
      _ => 'Delivered',
    };

    final subtitle = switch (stage) {
      0 => 'In progress...',
      1 => 'Your food is being prepared...',
      _ => 'Your order has arrived.',
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Text(
              stage == 2 ? '✓' : '—',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


