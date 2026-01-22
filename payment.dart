import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final TextEditingController cardNameController = TextEditingController();

  final TextEditingController cardNumberController = TextEditingController();

  final TextEditingController cardExpiryController = TextEditingController();

  final TextEditingController cardCVVController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Information'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: cardNameController,
              decoration: InputDecoration(
                labelText: 'Name on card',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 5,),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 5,),
            TextField(
              controller: cardExpiryController,
              decoration: InputDecoration(
                labelText: 'Expiry date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 5,),
            TextField(
              controller: cardCVVController,
              decoration: InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
