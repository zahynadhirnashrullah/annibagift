// Duplicate block removed. The correct import block and class definition are already at the top of the file.
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/models.dart';

class FirebaseAdminService {

  // READ USERS FROM REALTIME DATABASE
  Stream<List<User>> getUsersStreamRTDB() {
    final ref = _adminDatabase.ref('users');
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return data.values
            .whereType<Map>()
            .map((userMap) => User.fromMap(Map<String, dynamic>.from(userMap)))
            .where((user) => user.isDeleted == false)
            .toList();
      }
      return <User>[];
    });
  }
  late final firebase_auth.FirebaseAuth _adminAuth;
  late final FirebaseFirestore _adminFirestore;
  late final FirebaseDatabase _adminDatabase;
  
  // Singleton Pattern
  FirebaseAdminService._privateConstructor() {
    _initialize();
  }
  static final FirebaseAdminService instance = FirebaseAdminService._privateConstructor();

  Future<void> _initialize() async {
    // Create a secondary Firebase app for admin operations
    final adminApp = await Firebase.initializeApp(
      name: 'admin-app',
      options: Firebase.app().options,
    );

    _adminAuth = firebase_auth.FirebaseAuth.instanceFor(app: adminApp);
    _adminFirestore = FirebaseFirestore.instanceFor(app: adminApp);
  _adminDatabase = FirebaseDatabase.instanceFor(app: adminApp);
  }

  // CREATE USER
  Future<User?> createUser(String email, String password, String username, Role role) async {
    try {
      // Create auth user
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

        // Only write to Realtime Database under /users/{uid}
        try {
          final dbRef = _adminDatabase.ref('users/${user.id}');
          await dbRef.set({
            ...user.toMap(),
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'isDeleted': false,
          });
        } catch (dbErr) {
          debugPrint('Failed to write to Realtime Database: $dbErr');
        }

        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  // READ USERS
  Stream<List<User>> getUsersStream() {
    return _adminFirestore
        .collection('users')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs
                .map((doc) => User.fromMap(doc.data()))
                .toList());
  }

  // READ SPECIFIC USER
  Future<Map<String, dynamic>?> getUserDocument(String docId) async {
    try {
      final docSnap = await _adminFirestore
          .collection('users')
          .doc(docId)
          .get();
      
      if (docSnap.exists) {
        return docSnap.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user document: $e');
      return null;
    }
  }

  // UPDATE USER
  Future<void> updateUser(String uid, {String? username, Role? role}) async {
    try {
      final updates = <String, dynamic>{};
      
      if (username != null) {
        // Check if new username is unique
        final existingUsers = await _adminFirestore
            .collection('users')
            .where('username', isEqualTo: username)
            .where(FieldPath.documentId, isNotEqualTo: uid)
            .get();
            
        if (existingUsers.docs.isNotEmpty) {
          throw Exception('Username already exists');
        }
        updates['username'] = username;
      }
      
      if (role != null) {
        updates['role'] = role.toString();
      }

      if (updates.isNotEmpty) {
        await _adminFirestore
            .collection('users')
            .doc(uid)
            .update(updates);
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // SOFT DELETE USER
  Future<void> softDeleteUser(String uid) async {
    try {
      await _adminFirestore
          .collection('users')
          .doc(uid)
          .update({
            'isDeleted': true,
            'isActive': false,
            'deletedAt': DateTime.now().toUtc().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error soft deleting user: $e');
      rethrow;
    }
  }

  // Toggle user active status
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