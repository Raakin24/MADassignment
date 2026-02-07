import 'package:flutter/material.dart';
import 'package:mad_project/dataservice.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final int gst = 9;

  double get subTotal {
    double sum = 0.0;
    for (final line in cart.values) {
      sum += line.item.price * line.qty;
    }
    return sum;
  }

  double get gstTotal => subTotal * gst / 100;
  double get total => subTotal + gstTotal;

  @override
  Widget build(BuildContext context) {
    final entries = cart.entries.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final key = entry.key;
                  final line = entry.value;
                  final cartItem = line.item;

                  return _ItemCard(
                    key: ValueKey(key),
                    itemName: cartItem.item,
                    price: cartItem.price,
                    details:
                        '${cartItem.calories}kcal | ${cartItem.protein}g protein | '
                        '${cartItem.carbs}g carbs | ${cartItem.fats}g fats',
                    orderCount: line.qty,
                    onIncrement: () {
                      setState(() => incrementCartItemByKey(key));
                    },
                    onDecrement: () {
                      setState(() => decrementCartItemByKey(key));
                    },
                  );
                },
              ),
            ),
     bottomNavigationBar: cart.isEmpty
    ? null
    : SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    child: const _PaymentCard(),
                    onTap: () {
                      Navigator.pushNamed(context, '/payment');
                    },
                  ),
                ),
              ),
              _OrderSummary(
                subTotal: subTotal,
                gstTotal: gstTotal,
                total: total,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String itemName;
  final String details;
  final double price;
  final int orderCount;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ItemCard({
    super.key,
    required this.itemName,
    required this.details,
    required this.price,
    required this.orderCount,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(details),
            const SizedBox(height: 12),
            Text('\$${price.toStringAsFixed(2)}'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: onDecrement,
                ),
                Text(orderCount.toString()),
                IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatefulWidget {
  const _PaymentCard();

  @override
  State<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<_PaymentCard> {
  late Future<List<Payment>> _paymentFuture;

  @override
  void initState() {
    super.initState();
    _paymentFuture = DataService.getPayment();
  }

  String censorCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.length >= 4) {
      final last4 = cleaned.substring(cleaned.length - 4);
      return '**** **** **** $last4';
    }
    return '**** **** **** ****';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Payment>>(
      future: _paymentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Loading payment method...'),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Failed to load payment method'),
            ),
          );
        }

        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No payment method available'),
            ),
          );
        }

        final paymentInfo = list[0];

        return Card(
          elevation: 2,
          color: Colors.white,
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
                  'Payment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(censorCardNumber(paymentInfo.cardnumber)),
                    const Spacer(),
                    Text(paymentInfo.expirydate),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Subtotal: \$${subTotal.toStringAsFixed(2)}'),
          Text('GST: \$${gstTotal.toStringAsFixed(2)}'),
          const Divider(),
          Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/order_confirmation');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
