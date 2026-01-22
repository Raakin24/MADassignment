import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'menu.dart';
import 'cart.dart';
import 'order_status.dart';
import 'signup.dart'; // Add this if you have a SignUpPage
import 'nutrient_tracking.dart'; // Add this if you have a NutrientTrackingPage

void main() {
  runApp(PureBiteApp());
}

class PureBiteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureBite',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        // Set initial route to Login Page
        '/': (context) => LoginPage(),
        
        // Define routes for other pages
        '/home': (context) => HomePage(),
        '/menu': (context) => MenuPage(shopName: 'Healthy Bowls'), // Example with a shop name
        '/cart': (context) => CartPage(),
        '/order_status': (context) => OrderStatusPage(),
        '/signup': (context) => SignUpPage(),
        '/nutrient_tracking': (context) => NutrientTrackingPage(),
      },
    );
  }
}
