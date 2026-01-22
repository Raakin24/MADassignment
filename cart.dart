import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int orderCount = 1;
  final double itemPrice = 6.50;
  final int gst = 9;

  double get subTotal => itemPrice * orderCount;
  double get gstTotal => subTotal * gst / 100;
  double get total => subTotal + gstTotal;

  void orderInc() {
    setState(() {
      orderCount++;
    });
  }

  void orderDec() {
    if (orderCount > 0) {
      setState(() {
        orderCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PureBite - Cart'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: _ItemCard(
              orderCount: orderCount,
              onIncrement: orderInc,
              onDecrement: orderDec,
            ),
          ),
          _OrderSummary(
            subTotal: subTotal,
            gstTotal: gstTotal,
            total: total,
          ),
        ],
      ),
    );
  }
}


class _ItemCard extends StatelessWidget {
  final int orderCount;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ItemCard({
    required this.orderCount,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acai Bowl',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('450kcal | 5g protein | 30g carbs'),
            const SizedBox(height: 12),
            const Text('\$6.50'),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: onDecrement,
                ),
                Text(orderCount.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onIncrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double subTotal;
  final double gstTotal;
  final double total;

  const _OrderSummary({
    required this.subTotal,
    required this.gstTotal,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Subtotal: \$${subTotal.toStringAsFixed(2)}'),
          Text('GST: \$${gstTotal.toStringAsFixed(2)}'),
          const Divider(),
          Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/order_confirmation');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Place Order', style: TextStyle(color: Colors.white),),
                ),
              ),
        ],
      ),
    );
  }
}
