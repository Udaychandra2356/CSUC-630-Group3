// since we need authentication everywhere but also need to test, we can
// store auth into a singleton and just call it when we need it. initialize it in auth_gate.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthSingleton {
  static final AuthSingleton _singleton = AuthSingleton._internal();

  late final FirebaseAuth? auth;
  FirebaseFirestore? db;

  factory AuthSingleton() {
    return _singleton;
  }

  AuthSingleton._internal();
}
