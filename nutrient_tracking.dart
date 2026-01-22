import 'package:flutter/material.dart';

class NutrientTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PureBite - Nutrient Tracking'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Calories'),
            subtitle: LinearProgressIndicator(
              value: 0.72, // Update based on the user's progress
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            trailing: Text('1450/2000 kcal'),
          ),
          Divider(),
          Text('Macronutrients'),
          ListTile(
            title: Text('Protein'),
            subtitle: LinearProgressIndicator(
              value: 0.95, // Example value
              backgroundColor: Colors.grey[300],
              color: Colors.red,
            ),
            trailing: Text('95g/100g'),
          ),
          // Add other macronutrient details (Carbs, Fats)
        ],
      ),
    );
  }
}
