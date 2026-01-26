import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class Dataservice {
  List<Logins> z = [];

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
}
