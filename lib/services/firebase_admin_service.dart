// lib/services/firebase_admin_service.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/models.dart';

class FirebaseAdminService {
  late final firebase_auth.FirebaseAuth _adminAuth;
  late final FirebaseFirestore _adminFirestore;

  // Singleton Pattern
  FirebaseAdminService._privateConstructor() {
    _initialize();
  }
  static final FirebaseAdminService instance =
      FirebaseAdminService._privateConstructor();

  Future<void> _initialize() async {
    // Buat aplikasi Firebase sekunder untuk operasi admin
    final adminApp = await Firebase.initializeApp(
      name: 'admin-app',
      options: Firebase.app().options,
    );

    _adminAuth = firebase_auth.FirebaseAuth.instanceFor(app: adminApp);
    _adminFirestore = FirebaseFirestore.instanceFor(app: adminApp);
  }

  // --- FUNGSI BARU UNTUK LOGIN/LOGOUT ---
  /// Logs the admin user into the secondary 'admin-app'
  Future<void> loginAsAdmin(String email, String password) async {
    try {
      // Hanya login jika belum ada yang login di app ini
      if (_adminAuth.currentUser == null) {
        await _adminAuth.signInWithEmailAndPassword(
            email: email, password: password);
        debugPrint('Admin signed in to secondary app');
      }
    } catch (e) {
      debugPrint('Failed to sign in to admin-app: $e');
    }
  }

  /// Logs the admin user out from the secondary 'admin-app'
  Future<void> signOutAdmin() async {
    try {
      await _adminAuth.signOut();
      debugPrint('Admin signed out from secondary app');
    } catch (e) {
      debugPrint('Failed to sign out from admin-app: $e');
    }
  }
  // --- AKHIR FUNGSI BARU ---

  // CREATE USER
  Future<User?> createUser(
      String email, String password, String username, Role role) async {
    try {
      // Buat auth user
      final userCredential = await _adminAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = User(
          id: userCredential.user!.uid,
          username: username,
          email: email,
          role: role,
          isActive: true,
        );
        
        try {
          // Tulis ke Firestore menggunakan _adminFirestore
          final docRef = _adminFirestore.collection('users').doc(user.id);
          await docRef.set({
            ...user.toMap(),
            // PERBAIKAN DI SINI
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'isDeleted': false,
          });
        } catch (dbErr) {
          debugPrint('Failed to write to Firestore: $dbErr');
          // Rollback: hapus auth user jika Firestore gagal
          await userCredential.user!.delete();
          debugPrint(
              'Error creating Firestore user, rolled back Auth user: $dbErr');
          return null;
        }
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // READ USERS (dari Firestore)
  Stream<List<User>> getUsersStream() {
    return _adminFirestore
        .collection('users')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => User.fromMap(doc.data())).toList());
  }

  // READ SPECIFIC USER (dari Firestore)
  Future<Map<String, dynamic>?> getUserDocument(String docId) async {
    try {
      final docSnap = await _adminFirestore.collection('users').doc(docId).get();

      if (docSnap.exists) {
        return docSnap.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user document: $e');
      return null;
    }
  }

  // UPDATE USER (di Firestore)
  Future<void> updateUser(String uid, {String? username, Role? role}) async {
    try {
      final updates = <String, dynamic>{};

      if (username != null) {
        final existingUsers = await _adminFirestore
            .collection('users')
            .where('username', isEqualTo: username)
            .where(FieldPath.documentId, isNotEqualTo: uid)
            .get();

        if (existingUsers.docs.isNotEmpty) {
          throw Exception('Username $username sudah digunakan');
        }
        updates['username'] = username;
      }

      if (role != null) {
        updates['role'] = role.toString();
      }

      if (updates.isNotEmpty) {
        await _adminFirestore.collection('users').doc(uid).update(updates);
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // SOFT DELETE USER (di Firestore)
  Future<void> softDeleteUser(String uid) async {
    try {
      await _adminFirestore.collection('users').doc(uid).update({
        'isDeleted': true,
        'isActive': false,
        // PERBAIKAN DI SINI
        'deletedAt': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error soft deleting user: $e');
      rethrow;
    }
  }

  // Toggle user active status (di Firestore)
  Future<void> toggleUserStatus(String uid) async {
    try {
      final docRef = _adminFirestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (doc.exists && !(doc.data()?['isDeleted'] ?? false)) {
        final currentStatus = doc.data()?['isActive'] ?? true;
        await docRef.update({'isActive': !currentStatus});
      }
    } catch (e) {
      debugPrint('Error toggling user status: $e');
      rethrow;
    }
  }
}