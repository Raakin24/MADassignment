import 'package:cloud_firestore/cloud_firestore.dart';

class Logins {
  String username = "", password = "";

  Logins(this.username, this.password);
}

class Items {
  String item = "";
  double price = 0;
  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;
  String imageName = "";

  Items(
    this.item,
    this.price,
    this.calories,
    this.protein,
    this.carbs,
    this.fats,
    this.imageName,
  );
}

class Shops {
  String shopName = "";
  String shopLocation = "";
  String imageName = "";

  Shops(this.shopName, this.shopLocation, this.imageName);
}

List<Logins> localLoginData = [];
List<Items> localItemData = [];
List<Items> cartItems = [];
List<Shops> localShopData = [];

class DataService {
  static final CollectionReference loginData = FirebaseFirestore.instance
      .collection('logindata');

  static final CollectionReference itemData = FirebaseFirestore.instance
      .collection('menudata');

  static final CollectionReference shopData = FirebaseFirestore.instance
      .collection('shopdata');

  static Future<void> addLogin({
    required String username,
    required String email,
    required String password,
  }) async {
    final DocumentReference dr = await loginData.add({
      'username': username,
      'email': email,
      'password': password,
    });
  }

  static Future<void> getLoginDataByUsername(String enteredUsername) async {
    localLoginData.clear();

    QuerySnapshot qs = await loginData
        .where("username", isEqualTo: enteredUsername)
        .limit(1)
        .get();

    if (qs.docs.isNotEmpty) {
      final data = qs.docs.first.data() as Map<String, dynamic>;
      localLoginData.add(Logins(data['username'], data['password']));
    }
  }

  static Future<void> getShops() async {
    localShopData.clear();

    final qs = await shopData.get();

    for (final doc in qs.docs) {
      final data = doc.data() as Map<String, dynamic>;

      localShopData.add(
        Shops(
          data['shopname'] ?? '',
          data['shoplocation'] ?? '',
          data['imagename'] ?? 'logo.png',
        ),
      );
    }
  }

  static Future<void> getItemData() async {
    localItemData.clear();

    final qs = await itemData.get();

    for (final doc in qs.docs) {
      final data = doc.data() as Map<String, dynamic>;
      localItemData.add(
        Items(
          data['item'] ?? '',
          _toDouble(data['price']),
          _toDouble(data['calories']),
          _toDouble(data['protein']),
          _toDouble(data['carbs']),
          _toDouble(data['fats']),
          data['imagename'] ?? 'logo.png',
        ),
      );
    }
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
