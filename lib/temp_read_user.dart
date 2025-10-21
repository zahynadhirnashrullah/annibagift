import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

Future<void> readUserDocument() async {
  try {
    final docRef = FirebaseFirestore.instance.collection('users').doc('6DItMunnjcloEDTuLjvS');
    final docSnap = await docRef.get();
    
    if (docSnap.exists) {
      debugPrint('Document data: ${docSnap.data()}');
    } else {
      debugPrint('Document does not exist');
    }
  } catch (e) {
    debugPrint('Error getting document: $e');
  }
}