// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:annibagift/main.dart';

// Mock class for Firebase initialization in tests
class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnnibaGiftApp());

    // Verify that our login page shows up
    expect(find.text('Anniba Gift'), findsOneWidget);
    expect(find.text('Silakan login untuk melanjutkan'), findsOneWidget);
    
    // Verify that we have login form fields
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
  });
}
