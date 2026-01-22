import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Check Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 4),
                ),
                child: const Icon(
                  Icons.check,
                  size: 48,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your healthy meal is being prepared',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              const Text(
                'Order Number',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 8),

              const Text(
                '#67',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 32),

              // Pickup Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Location',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Healthy Bowls\n123 Clementi Rd, Singapore',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Track Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/order_status');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Track Order', style: TextStyle(color: Colors.white),),
                ),
              ),

              const SizedBox(height: 12),

              // Back to Home Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Back to Home', style: TextStyle(color: Colors.black),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
