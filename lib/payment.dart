import 'package:flutter/material.dart';
import 'package:mad_project/dataservice.dart';

class PaymentPage extends StatelessWidget {
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCVVController = TextEditingController();

  PaymentPage({super.key});

  Future<void> savePayment(BuildContext context) async {
    String cardnumber = cardNumberController.text;
    String cardname = cardNameController.text;
    String cvv = cardCVVController.text;
    String expirydate = cardExpiryController.text;

    if (cardnumber != "" && cardname != "" && cvv != "" && expirydate != "") {
      await DataService.savePayment(cardname: cardname, cardnumber: cardnumber, cvv: cvv, expirydate: expirydate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Payment Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: cardNameController,
              decoration: InputDecoration(
                labelText: 'Name on card',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cardExpiryController,
              decoration: InputDecoration(
                labelText: 'Expiry date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cardCVVController,
              decoration: InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  savePayment(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
