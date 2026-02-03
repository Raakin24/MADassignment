import 'package:cloud_firestore/cloud_firestore.dart';

int? currentOrderNumber;

Shops? selectedShop;

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

class Payment {
  String cardnumber = "";
  String expirydate = "";
  Payment(this.cardnumber, this.expirydate);
}

List<Logins> localLoginData = [];
List<Items> localItemData = [];
List<Shops> localShopData = [];
List<Payment> paymentDetails = [];

class CartLine {
  final Items item;
  int qty;

  CartLine({required this.item, this.qty = 1});
}

/// Use a Map so duplicates merge into one entry.
/// Key should be a stable unique identifier.
/// For now, we use item name + price as key (better than name only).
final Map<String, CartLine> cart = {};

String cartKeyFromItem(Items i) => '${i.item}|${i.price}';

void addToCart(Items item, {int qty = 1}) {
  final key = cartKeyFromItem(item);
  if (cart.containsKey(key)) {
    cart[key]!.qty += qty;
  } else {
    cart[key] = CartLine(item: item, qty: qty);
  }
}

void incrementCartItemByKey(String key) {
  if (cart.containsKey(key)) {
    cart[key]!.qty += 1;
  }
}

void decrementCartItemByKey(String key) {
  if (!cart.containsKey(key)) return;

  final line = cart[key]!;
  if (line.qty > 1) {
    line.qty -= 1;
  } else {
    cart.remove(key);
  }
}

void removeCartItemByKey(String key) {
  cart.remove(key);
}

void clearCart() {
  cart.clear();
}


class DataService {
  static final CollectionReference loginData =
      FirebaseFirestore.instance.collection('logindata');

  static final CollectionReference itemData =
      FirebaseFirestore.instance.collection('menudata');

  static final CollectionReference shopData =
      FirebaseFirestore.instance.collection('shopdata');

  static final CollectionReference paymentData =
      FirebaseFirestore.instance.collection('paymentdata');

  static Future<void> addLogin({
    required String username,
    required String email,
    required String password,
  }) async {
    await loginData.add({
      'username': username,
      'email': email,
      'password': password,
    });
  }

  static Future<void> addPayment({
    required String cardname,
    required String cardnumber,
    required String cvv,
    required String expirydate,
  }) async {
    await paymentData.add({
      'cardname': cardname,
      'cardnumber': cardnumber,
      'cvv': cvv,
      'expirydate': expirydate,
    });
  }

  static Future<void> getLoginDataByUsername(String enteredUsername) async {
    localLoginData.clear();

    final qs = await loginData
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

  static Future<List<Payment>> getPayment() async {
    paymentDetails.clear();
    final qs = await paymentData.get();

    for (final doc in qs.docs) {
      final data = doc.data() as Map<String, dynamic>;
      paymentDetails.add(
        Payment(data['cardnumber'] ?? '', data['expirydate'] ?? ''),
      );
    }

    return paymentDetails;
  }

  static Future<void> savePayment({
    required String cardname,
    required String cardnumber,
    required String cvv,
    required String expirydate,
  }) async {
    await paymentData.doc('paymentinfo').update({
      'cardname': cardname,
      'cardnumber': cardnumber,
      'cvv': cvv,
      'expirydate': expirydate,
    });
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
