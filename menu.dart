import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  final String shopName;

  MenuPage({required this.shopName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$shopName - Menu'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Image.asset('assets/healthy_bowl.png', height: 200),
          ListTile(
            title: Text('Acai Bowl'),
            subtitle: Text('450 kcal | 5g protein | 30g carbs'),
            trailing: ElevatedButton(
              onPressed: () {
                // Add to cart
              },
              child: Text('\$6.50'),
            ),
          ),
          // Add more menu items here
        ],
      ),
    );
  }
}
