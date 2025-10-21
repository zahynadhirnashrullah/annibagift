// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/models.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Singleton Pattern
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  // Fungsi sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

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
      // First, check global setting whether karyawan logins are disabled
      bool karyawanDisabled = false;
      try {
        final settingSnap = await _database.ref('settings/karyawan_login_disabled').get();
        if (settingSnap.exists && settingSnap.value == true) karyawanDisabled = true;
      } catch (_) {}

      // Try to find user in RTDB by email
      try {
        final querySnap = await _database.ref('users').orderByChild('email').equalTo(email).get();
        if (querySnap.exists && querySnap.value is Map) {
          final mapAll = Map<String, dynamic>.from(querySnap.value as Map);
          if (mapAll.isNotEmpty) {
            final entry = mapAll.entries.first;
            final uid = entry.key;
            final map = Map<String, dynamic>.from(entry.value as Map);
            final roleStr = map['role'] as String? ?? '';

            if (map['isDeleted'] == true) return null;
            if (karyawanDisabled && roleStr.contains('karyawan')) return null;

            final storedHash = map['passwordHash'] as String?;
            if (storedHash == null) return null;
            // Verify bcrypt
            final ok = BCrypt.checkpw(password, storedHash);
            if (!ok) return null;

            // Update lastLogin
            try {
              await _database.ref('users/$uid').update({'lastLogin': DateTime.now().toUtc().toIso8601String()});
            } catch (_) {}

            return User.fromMap({...map, 'id': uid});
          }
        }
      } catch (_) {}

      // Fallback to Firestore lookup by email
      try {
        final q = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
        if (q.docs.isNotEmpty) {
          final doc = q.docs.first;
          final map = doc.data();
          final roleStr = map['role'] as String? ?? '';
          if ((map['isDeleted'] ?? false) == true) return null;
          if (karyawanDisabled && roleStr.contains('karyawan')) return null;

          final storedHash = map['passwordHash'] as String?;
          if (storedHash == null) return null;
          final ok = BCrypt.checkpw(password, storedHash);
          if (!ok) return null;

          // Update lastLogin
          try {
            await _firestore.collection('users').doc(doc.id).set({'lastLogin': DateTime.now().toUtc().toIso8601String()}, SetOptions(merge: true));
          } catch (_) {}

          return User.fromMap({...map, 'id': doc.id});
        }
      } catch (e) {
        debugPrint('Error during login DB lookup: $e');
      }

      // User not found or auth failed
      return null;
    } catch (e) {
      debugPrint('Error during login: $e');
      return null;
    }
  }

  /// Convenience: set login-related fields for a user document (merges with existing data).
  Future<void> setLoginInfo(String uid, {String? email, Role? role}) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final data = <String, dynamic>{
        // PERBAIKAN DI SINI
        'lastLogin': DateTime.now().toUtc().toIso8601String(),
      };
      if (email != null) data['email'] = email;
      if (role != null) data['role'] = role.toString();

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error setting login info for $uid: $e');
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
      // (Fungsi ini sepertinya tidak digunakan oleh login, tapi oleh admin service)
      // (Biarkan saja untuk kelengkapan)
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
                // PERBAIKAN DI SINI
                'createdAt': DateTime.now().toUtc().toIso8601String(),
              });
        } catch (e) {
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