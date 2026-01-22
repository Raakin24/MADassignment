import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PureBite - Cart'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Acai Bowl'),
            subtitle: Text('450 kcal | 5g protein | 30g carbs'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.remove)),
                Text('1'),
                IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Subtotal: \$6.50'),
            subtitle: Text('GST: \$0.59'),
          ),
          Divider(),
          ListTile(
            title: Text('Total: \$7.09'),
            trailing: ElevatedButton(
              onPressed: () {
                // Proceed to place order
              },
              child: Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}
