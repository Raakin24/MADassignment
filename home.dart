import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PureBite - Home'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Text(
            'Shops near you!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Healthy Bowls'),
                  subtitle: Text('Beauty World'),
                  onTap: () {
                    // Navigate to the menu page
                  },
                ),
                ListTile(
                  title: Text('Healthy Wraps'),
                  subtitle: Text('Clementi'),
                  onTap: () {
                    // Navigate to the menu page
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
