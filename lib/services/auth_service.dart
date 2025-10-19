import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/models.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton Pattern
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  Future<List<User>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
        final userData = await userDoc.get();
        if (userData.exists) {
          // Update lastLogin timestamp
          await userDoc.update({'lastLogin': DateTime.now().toUtc().toIso8601String()});
          return User.fromMap(userData.data()!);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error during login: $e');
      return null;
    }
  }

  Future<void> updateUser(String id, {String? username, Role? role}) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (role != null) updates['role'] = role.toString();
      
      await _firestore.collection('users').doc(id).update(updates);
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      // Note: This doesn't delete the Firebase Auth user
      // Add _auth.deleteUser(id) if you want to delete the auth account too
    } catch (e) {
      debugPrint('Error deleting user: $e');
    }
  }

  Future<void> toggleUserStatus(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        final currentStatus = doc.data()?['isActive'] ?? true;
        await doc.reference.update({'isActive': !currentStatus});
      }
    } catch (e) {
      debugPrint('Error toggling user status: $e');
    }
  }

  Future<User?> createUser(String email, String username, String password, Role role) async {
    try {
      // First check if username exists
      final existingUsers = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (existingUsers.docs.isNotEmpty) {
        debugPrint('Username $username already exists!');
        return null;
      }

      // Create auth user and Firestore user atomically
      firebase_auth.UserCredential? userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        debugPrint('Error creating Firebase Auth user: $e');
        return null;
      }

      if (userCredential.user != null) {
        final user = User(
          id: userCredential.user!.uid,
          username: username,
          email: email,
          role: role,
          isActive: true,
        );
        try {
          await _firestore
              .collection('users')
              .doc(user.id)
              .set({
                ...user.toMap(),
                'createdAt': DateTime.now().toUtc().toIso8601String(),
              });
        } catch (e) {
          // Rollback: delete auth user if Firestore fails
          await userCredential.user!.delete();
          debugPrint('Error creating Firestore user, rolled back Auth user: $e');
          return null;
        }
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }
}