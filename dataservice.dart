import 'package:cloud_firestore/cloud_firestore.dart';

class Logins {
  String username = "", password = "";

  Logins(this.username, this.password);
}

List<Logins> z = [];

class DataService {
  static final CollectionReference loginData = FirebaseFirestore.instance
      .collection('logindata');

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
    z.clear();

    QuerySnapshot qs = await loginData
        .where("username", isEqualTo: enteredUsername)
        .limit(1)
        .get();

    if (qs.docs.isNotEmpty) {
      final data = qs.docs.first.data() as Map<String, dynamic>;
      z.add(Logins(data['username'], data['password']));
    }
  }
}
