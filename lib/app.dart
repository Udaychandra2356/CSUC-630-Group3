import 'package:flutter/material.dart';
import 'auth_gate.dart';

class MyAppRoot extends StatelessWidget {
  const MyAppRoot({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  AuthGate(),
    );
  }
}