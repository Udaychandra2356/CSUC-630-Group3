// since we need authentication everywhere but also need to test, we can
// store auth into a singleton and just call it when we need it. initialize it in auth_gate.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthSingleton {
  static final AuthSingleton _singleton = AuthSingleton._internal();

  /// Holds either the real FirebaseAuth.instance or a test‐mock override
  FirebaseAuth? _auth;

  /// Same for Firestore
  FirebaseFirestore? _db;

  factory AuthSingleton() => _singleton;

  AuthSingleton._internal();

  // Initialize mocks before creating widgets in test
  static void initialize({
    FirebaseAuth? mockAuth,
    FirebaseFirestore? mockDb,
  }) {
    _singleton._auth = mockAuth;
    _singleton._db = mockDb;
  }

  // Lazy initializations, getters for previous variable names but if nothing is present, default to real instances.
  FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;
  FirebaseFirestore get db => _db ??= FirebaseFirestore.instance;
}
