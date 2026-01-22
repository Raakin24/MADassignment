import 'package:flutter/material.dart';

class OrderStatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PureBite - Order Status'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Order Number: #67'),
            subtitle: Text('Healthy Bowls - 123 Clementi Rd, Singapore'),
          ),
          Divider(),
          Text('Your items: 1x Acai Bowl'),
          ListTile(
            title: Text('Order Progress'),
            subtitle: Text('Order Placed - 2:30 PM'),
            leading: Icon(Icons.check_circle, color: Colors.green),
          ),
          ElevatedButton(
            onPressed: () {
              // Get directions or navigate
            },
            child: Text('Get Directions'),
          ),
          TextButton(
            onPressed: () {
              // Allow user to order again
            },
            child: Text('Order Again'),
          ),
        ],
      ),
    );
  }
}
