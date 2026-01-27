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
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      ListTile(
                        title: Text('Carbs'),
                        subtitle: LinearProgressIndicator(
                          value: 0.725, // Example value
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                        trailing: Text('145g/200g'),
                      ),
                      ListTile(
                        title: Text('Fats'),
                        subtitle: LinearProgressIndicator(
                          value: 0.738, // Example value
                          backgroundColor: Colors.grey[300],
                          color: Colors.lime,
                        ),
                        trailing: Text('48g/65g'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
