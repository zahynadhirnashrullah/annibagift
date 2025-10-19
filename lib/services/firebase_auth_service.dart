import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/models.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Singleton pattern
  static final FirebaseAuthService instance = FirebaseAuthService._internal();
  FirebaseAuthService._internal();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // Here you can fetch additional user data from Firestore if needed
        return User(
          id: firebaseUser.uid,
          username: email.split('@')[0], // Using email prefix as username
          email: email,
          role: Role.pemilik, // You might want to store this in Firestore
          isActive: true,
        );
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        final user = User(
          id: firebaseUser.uid,
          username: email.split('@')[0],
          email: email,
          role: Role.pemilik,
          isActive: true,
        );
        // Here you can store additional user data in Firestore
        return user;
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return User(
        id: firebaseUser.uid,
        username: firebaseUser.email?.split('@')[0] ?? '',
        email: firebaseUser.email ?? '',
        role: Role.pemilik,
        isActive: true,
      );
    }
    return null;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Get auth state changes
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return User(
        id: firebaseUser.uid,
        username: firebaseUser.email?.split('@')[0] ?? '',
        email: firebaseUser.email ?? '',
        role: Role.pemilik,
        isActive: true,
      );
    });
  }
}