import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habitstacker/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:habitstacker/firebase_options.dart';  // adjust path as needed

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'mock.dart';

// // If using mockito, you can create a MockFirebaseAuth, etc.
// class MockUser extends Mock implements User {}
// class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() async{
  
  //   TestWidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);



  testWidgets('AuthGate shows SignInScreen when user is not signed in', (WidgetTester tester) async {
    // In a real test, you'd configure mock FirebaseAuth to return null for currentUser.

    final mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'someUid',
        email: 'someuser@test.com',
      ),
      signedIn: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(),
      ),
    );

    // We expect to see a SignInScreen from firebase_ui_auth by default:
    // It might contain sign-in form fields, "Habit Stacker" header, etc.
    expect(find.text('Habit Stacker'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets); // Email + password fields
  }); 
}
