import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mad_project/directions.dart';
import 'package:mad_project/menu%202.dart';
import 'firebase_options.dart';
import "dataservice.dart";
import 'payment.dart';
import 'order_confirmation.dart';
import 'login.dart';
import 'home.dart';
import 'menu.dart';
import 'cart.dart';
import 'order_status.dart';
import 'signup.dart';
import 'nutrient_tracking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(PureBiteApp());
}

class PureBiteApp extends StatelessWidget {
  const PureBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PureBite',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),

        '/home': (context) => HomePage(),
        '/menu': (context) => MenuPage(shopName: selectedShop?.shopName ?? 'Menu'),
        '/menu2': (context) => MenuPage2(shopName: selectedShop?.shopName ?? 'Menu'),
        '/cart': (context) => CartPage(),
        '/payment': (context) => PaymentPage(),
        '/order_status': (context) => OrderStatusPage(),
        '/order_confirmation': (context) => OrderConfirmationPage(),
        '/signup': (context) => SignUpPage(),
        '/nutrient_tracking': (context) => NutrientTrackingPage(),
        '/directions': (context) => DirectionsPage(),
      },
    );
  }
}
