// lib/services/firebase_admin_service.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/models.dart';
import 'dart:convert';
import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:googleapis_auth/auth_io.dart' as auth_io;

class FirebaseAdminService {
  late final firebase_auth.FirebaseAuth _adminAuth;
  late final FirebaseDatabase _adminDatabase;
  late final FirebaseFirestore _adminFirestore;

  // Singleton Pattern
  FirebaseAdminService._privateConstructor();
  static final FirebaseAdminService instance =
      FirebaseAdminService._privateConstructor();

  static Future<void> initialize() async {
    await instance._initialize();
  }

  Future<void> _initialize() async {
    final adminApp = Firebase.app('admin-app');

    _adminAuth = firebase_auth.FirebaseAuth.instanceFor(app: adminApp);
    _adminDatabase = FirebaseDatabase.instanceFor(app: adminApp);
    _adminFirestore = FirebaseFirestore.instanceFor(app: adminApp);
  }

  // --- GETTERS FOR DATABASE ACCESS ---
  FirebaseDatabase getDatabase() => _adminDatabase;
  FirebaseFirestore getFirestore() => _adminFirestore;

  // --- FUNGSI LOGIN/LOGOUT ADMIN ---
  Future<void> loginAsAdmin(String email, String password) async {
    try {
      if (_adminAuth.currentUser == null) {
        await _adminAuth.signInWithEmailAndPassword(
            email: email, password: password);
        debugPrint('Admin signed in to secondary app');
        // Disable karyawan login globally while admin is signed in
        try {
          await _adminDatabase.ref('settings/karyawan_login_disabled').set(true);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Failed to sign in to admin-app: $e');
    }
  }

  Future<void> signOutAdmin() async {
    try {
      await _adminAuth.signOut();
      debugPrint('Admin signed out from secondary app');
      // Re-enable karyawan login when admin signs out
      try {
        await _adminDatabase.ref('settings/karyawan_login_disabled').set(false);
      } catch (_) {}
    } catch (e) {
      debugPrint('Failed to sign out from admin-app: $e');
    }
  }
  // --- AKHIR FUNGSI LOGIN/LOGOUT ---

  // CREATE USER
  Future<User?> createUser(
      String email, String password, String username, Role role) async {
    try {
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

        // First write to RTDB
        try {
          final dbRef = _adminDatabase.ref('users/${user.id}');
          final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
          await dbRef.set({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'role': role.toString(),
            'isActive': user.isActive,
            'isDeleted': false,
            'passwordHash': passwordHash,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (dbErr) {
          debugPrint('Failed to write to Realtime Database: $dbErr');
          // Try to clean up the created auth user if DB write failed
          try {
            await userCredential.user!.delete();
          } catch (_) {}
          return null;
        }

        // Then mirror to Firestore so user data exists there as well
        try {
          await _adminFirestore.collection('users').doc(user.id).set({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'role': role.toString(),
            'isActive': user.isActive,
            'isDeleted': false,
            'passwordHash': BCrypt.hashpw(password, BCrypt.gensalt()),
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (fsErr) {
          debugPrint('Failed to write to Firestore: $fsErr');
          // Roll back RTDB and Auth user if Firestore write fails
          try {
            await _adminDatabase.ref('users/${user.id}').remove();
          } catch (_) {}
          try {
            await userCredential.user!.delete();
          } catch (_) {}
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

  // READ USERS
  // (Optional) Firestore-backed stream kept for backward compatibility.
  Stream<List<User>> getUsersStream() {
    // Not implemented for Firestore in current setup. Return empty stream.
    return Stream.value(<User>[]);
  }

  // READ SPECIFIC USER
  Future<Map<String, dynamic>?> getUserDocument(String docId) async {
    try {
      final snap = await _adminDatabase.ref('users/$docId').get();
      if (snap.exists && snap.value is Map) {
        return Map<String, dynamic>.from(snap.value as Map);
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
      final updates = <String, Object?>{};

      if (username != null) {
        // Check for existing username in RTDB
        final querySnap = await _adminDatabase.ref('users').orderByChild('username').equalTo(username).get();
        bool nameTaken = false;
        if (querySnap.exists && querySnap.value is Map) {
          final map = Map<String, dynamic>.from(querySnap.value as Map);
          for (final entry in map.entries) {
            if (entry.key != uid) {
              nameTaken = true;
              break;
            }
          }
        }
        if (nameTaken) throw Exception('Username $username sudah digunakan');
        updates['username'] = username;
      }

      if (role != null) {
        updates['role'] = role.toString();
      }

      if (updates.isNotEmpty) {
        await _adminDatabase.ref('users/$uid').update(updates);
        try {
          await _adminFirestore.collection('users').doc(uid).update(updates);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  /// Update stored password hash for a user in RTDB and Firestore using bcrypt.
  /// Returns true when the hash was updated successfully.
  Future<bool> updateUserPasswordHash(String uid, String newPassword) async {
    try {
      final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await _adminDatabase.ref('users/$uid').update({'passwordHash': newHash});
      try {
        await _adminFirestore.collection('users').doc(uid).update({'passwordHash': newHash});
      } catch (_) {}
      return true;
    } catch (e) {
      debugPrint('Error updating password hash for $uid: $e');
      return false;
    }
  }

  // SOFT DELETE USER
  Future<void> softDeleteUser(String uid) async {
    try {
      final snap = await _adminDatabase.ref('users/$uid').get();
      if (snap.exists && snap.value is Map) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        final roleStr = map['role'] as String? ?? '';
        final isKaryawan = roleStr.contains('karyawan');
        if (isKaryawan) {
          // Permanently delete karyawan user data from RTDB and Firestore
          await _adminDatabase.ref('users/$uid').remove();
          try {
            await _adminFirestore.collection('users').doc(uid).delete();
          } catch (_) {}
          // Also delete Firebase Auth user (best-effort)
          try {
            await deleteAuthUserWithServiceAccount(uid);
          } catch (_) {}
          return;
        }
      }

      // Fallback: soft delete
      await _adminDatabase.ref('users/$uid').update({
        'isDeleted': true,
        'isActive': false,
        'deletedAt': DateTime.now().toUtc().toIso8601String(),
      });
      try {
        await _adminFirestore.collection('users').doc(uid).update({
          'isDeleted': true,
          'isActive': false,
          'deletedAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {}
    } catch (e) {
      debugPrint('Error soft deleting user: $e');
      rethrow;
    }
  }

  // Toggle user active status
  Future<void> toggleUserStatus(String uid) async {
    try {
      final snap = await _adminDatabase.ref('users/$uid').get();
      if (snap.exists && snap.value is Map) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        if (map['isDeleted'] == true) return;
        final current = map['isActive'] ?? true;
        await _adminDatabase.ref('users/$uid').update({'isActive': !current});
        try {
          await _adminFirestore.collection('users').doc(uid).update({'isActive': !current});
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error toggling user status: $e');
      rethrow;
    }
  }

  // -------------------------
  // FIRESTORE CRUD FOR ADMIN
  // These methods use the secondary admin app's Firestore instance so
  // an admin user (signed into the secondary admin app) can manage
  // karyawan documents in Firestore directly.
  // -------------------------

  Future<void> firestoreCreateUser(User user) async {
    try {
      await _adminFirestore.collection('users').doc(user.id).set({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'role': user.role.toString(),
        'isActive': user.isActive,
        'isDeleted': user.isDeleted,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating Firestore user via admin: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> firestoreReadUser(String uid) async {
    try {
      final doc = await _adminFirestore.collection('users').doc(uid).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      debugPrint('Error reading Firestore user via admin: $e');
      return null;
    }
  }

  Future<void> firestoreUpdateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _adminFirestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      debugPrint('Error updating Firestore user via admin: $e');
      rethrow;
    }
  }

  Future<void> firestoreDeleteUser(String uid) async {
    try {
      await _adminFirestore.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint('Error deleting Firestore user via admin: $e');
      rethrow;
    }
  }

  // Delete Firebase Auth user using Identity Toolkit API and a service account.
  // Requires a service account JSON at project root named 'service-account.json'
  // with roles/iam.serviceAccountTokenCreator and proper Firebase permissions.
  Future<void> deleteAuthUserWithServiceAccount(String uid) async {
    try {
      final file = File('service-account.json');
      if (!await file.exists()) {
        debugPrint('Service account file not found; skipping auth deletion.');
        return;
      }

      final content = await file.readAsString();
      final serviceAccount = json.decode(content);
      final accountEmail = serviceAccount['client_email'] as String?;
      if (accountEmail == null) {
        debugPrint('Invalid service account json');
        return;
      }

      final scopes = ['https://www.googleapis.com/auth/identitytoolkit'];
      final credentials = auth_io.ServiceAccountCredentials.fromJson(content);
      final client = await auth_io.clientViaServiceAccount(credentials, scopes);
      try {
        final apiUrl = 'https://identitytoolkit.googleapis.com/v1/projects/${_adminAuth.app.options.projectId}/accounts:delete';
        final resp = await client.post(Uri.parse(apiUrl), body: json.encode({'localId': uid}), headers: {'Content-Type': 'application/json'});
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          debugPrint('Deleted auth user $uid via service account');
        } else {
          debugPrint('Failed to delete auth user: ${resp.statusCode} - ${resp.body}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Error deleting auth user with service account: $e');
    }
  }

  /// Change the currently-signed-in admin's password (secondary admin auth instance).
  /// This affects the admin account that is signed in via the admin app.
  Future<void> changeOwnPassword(String newPassword) async {
    try {
      final user = _adminAuth.currentUser;
      if (user == null) throw Exception('No admin user signed in');
      await user.updatePassword(newPassword);
      debugPrint('Admin password updated successfully');
    } catch (e) {
      debugPrint('Error updating admin password: $e');
      rethrow;
    }
  }

  /// Set another user's password using the Identity Toolkit API and a service account.
  /// Set another user's password using the Identity Toolkit API and a service account.
  /// Returns true when the password update was successful, false otherwise.
  Future<bool> setAuthUserPasswordWithServiceAccount(String uid, String newPassword) async {
    try {
      final file = File('service-account.json');
      if (!await file.exists()) {
        debugPrint('Service account file not found; skipping password set.');
        return false;
      }

      final content = await file.readAsString();
      final credentials = auth_io.ServiceAccountCredentials.fromJson(content);
      final scopes = ['https://www.googleapis.com/auth/identitytoolkit'];
      auth_io.AutoRefreshingAuthClient client;
      try {
        client = await auth_io.clientViaServiceAccount(credentials, scopes);
      } on UnsupportedError catch (e) {
        // In many cases running service account flows from a Flutter client
        // (especially on web or sandboxed environments) will fail with
        // unsupported operation errors. Provide a clearer log and instruct
        // to move this operation to a secure server (Cloud Function / Cloud Run).
        debugPrint('Service account operations are not supported in this environment: $e');
        debugPrint('Move password-management actions to a secure server-side endpoint (Cloud Function / Cloud Run) that uses the Firebase Admin SDK.');
        return false;
      }
      try {
        // Attempt to verify current passwordUpdatedAt before change
        int? beforeUpdatedAt;
        try {
          final info = await _lookupAuthUserWithServiceAccount(uid, client);
          if (info != null && info['passwordUpdatedAt'] != null) {
            beforeUpdatedAt = int.tryParse(info['passwordUpdatedAt'].toString());
          }
        } catch (_) {}

        final apiUrl = 'https://identitytoolkit.googleapis.com/v1/projects/${_adminAuth.app.options.projectId}/accounts:update';
        final body = json.encode({'localId': uid, 'password': newPassword, 'returnSecureToken': false});
        final resp = await client.post(Uri.parse(apiUrl), body: body, headers: {'Content-Type': 'application/json'});
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          debugPrint('Set password for user $uid via service account');

          // Verify by checking passwordUpdatedAt after the change
          try {
            final infoAfter = await _lookupAuthUserWithServiceAccount(uid, client);
            int? afterUpdatedAt;
            if (infoAfter != null && infoAfter['passwordUpdatedAt'] != null) {
              afterUpdatedAt = int.tryParse(infoAfter['passwordUpdatedAt'].toString());
            }

            if (beforeUpdatedAt == null && afterUpdatedAt != null) return true;
            if (beforeUpdatedAt != null && afterUpdatedAt != null && afterUpdatedAt > beforeUpdatedAt) return true;
          } catch (_) {}

          // If we couldn't verify timestamp change, assume success based on 2xx but return true conservatively
          // Update stored password hash in RTDB and Firestore
          try {
            final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            await _adminDatabase.ref('users/$uid').update({'passwordHash': newHash});
            try {
              await _adminFirestore.collection('users').doc(uid).update({'passwordHash': newHash});
            } catch (_) {}
          } catch (e) {
            debugPrint('Failed to update stored password hash: $e');
          }
          return true;
        } else {
          // Try to parse structured error message if present
          try {
            final parsed = json.decode(resp.body);
            debugPrint('Failed to set password (${resp.statusCode}): $parsed');
          } catch (_) {
            debugPrint('Failed to set password: ${resp.statusCode} - ${resp.body}');
          }
          return false;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Error setting auth user password with service account: $e');
      return false;
    }
  }

  // Helper: lookup auth user info using Identity Toolkit via provided http client.
  // If client is null, this method will create a temporary client but the caller
  // can pass the existing client to avoid double-auth flows.
  Future<Map<String, dynamic>?> _lookupAuthUserWithServiceAccount(String uid, auth_io.AutoRefreshingAuthClient client) async {
    try {
      final apiUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:lookup';
      final body = json.encode({'localId': [uid]});
      final resp = await client.post(Uri.parse(apiUrl), body: body, headers: {'Content-Type': 'application/json'});
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final parsed = json.decode(resp.body);
        if (parsed is Map && parsed['users'] is List && (parsed['users'] as List).isNotEmpty) {
          return Map<String, dynamic>.from((parsed['users'] as List).first as Map);
        }
      } else {
        debugPrint('Failed to lookup user: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      debugPrint('Error looking up auth user: $e');
    }
    return null;
  }

  // --- SEWA OPERATIONS (Realtime Database) ---
  Future<void> addSewaToRTDB(Sewa sewa) async {
    try {
      final ref = _adminDatabase.ref('sewa/${sewa.id}');
      await ref.set({
        'id': sewa.id,
        'nama': sewa.nama,
        'alamat': sewa.alamat,
        'noHp': sewa.noHp,
        'tanggal': sewa.tanggal.toIso8601String(),
        'tanggalDibuat': sewa.tanggalDibuat.toIso8601String(),
        'totalHarga': sewa.totalHarga,
        'keterangan': sewa.keterangan,
        'durasi': sewa.durasi,
        'jaminan': sewa.jaminan,
        'createdById': sewa.createdById,
        'createdByName': sewa.createdByName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Sewa added to RTDB: ${sewa.id}');
    } catch (e) {
      debugPrint('Error adding sewa to RTDB: $e');
    }
  }

  Future<void> updateSewaInRTDB(Sewa sewa) async {
    try {
      final ref = _adminDatabase.ref('sewa/${sewa.id}');
      await ref.update({
        'nama': sewa.nama,
        'alamat': sewa.alamat,
        'noHp': sewa.noHp,
        'tanggal': sewa.tanggal.toIso8601String(),
        'totalHarga': sewa.totalHarga,
        'keterangan': sewa.keterangan,
        'durasi': sewa.durasi,
        'jaminan': sewa.jaminan,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Sewa updated in RTDB: ${sewa.id}');
    } catch (e) {
      debugPrint('Error updating sewa in RTDB: $e');
    }
  }

  Future<void> deleteSewaFromRTDB(String sewaId) async {
    try {
      final ref = _adminDatabase.ref('sewa/$sewaId');
      await ref.remove();
      debugPrint('Sewa deleted from RTDB: $sewaId');
    } catch (e) {
      debugPrint('Error deleting sewa from RTDB: $e');
    }
  }

  // --- PESANAN OPERATIONS (Realtime Database) ---
  Future<void> addPesananToRTDB(Pesanan pesanan) async {
    try {
      final ref = _adminDatabase.ref('pesanan/${pesanan.id}');
      await ref.set({
        'id': pesanan.id,
        'nama': pesanan.nama,
        'alamat': pesanan.alamat,
        'noHp': pesanan.noHp,
        'tanggalDibuat': pesanan.tanggalDibuat.toIso8601String(),
        'totalHarga': pesanan.totalHarga,
        'keterangan': pesanan.keterangan,
        'createdById': pesanan.createdById,
        'createdByName': pesanan.createdByName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Pesanan added to RTDB: ${pesanan.id}');
    } catch (e) {
      debugPrint('Error adding pesanan to RTDB: $e');
    }
  }

  Future<void> updatePesananInRTDB(Pesanan pesanan) async {
    try {
      final ref = _adminDatabase.ref('pesanan/${pesanan.id}');
      await ref.update({
        'nama': pesanan.nama,
        'alamat': pesanan.alamat,
        'noHp': pesanan.noHp,
        'totalHarga': pesanan.totalHarga,
        'keterangan': pesanan.keterangan,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Pesanan updated in RTDB: ${pesanan.id}');
    } catch (e) {
      debugPrint('Error updating pesanan in RTDB: $e');
    }
  }

  Future<void> deletePesananFromRTDB(String pesananId) async {
    try {
      final ref = _adminDatabase.ref('pesanan/$pesananId');
      await ref.remove();
      debugPrint('Pesanan deleted from RTDB: $pesananId');
    } catch (e) {
      debugPrint('Error deleting pesanan from RTDB: $e');
    }
  }

  // --- PENGELUARAN OPERATIONS (Realtime Database) ---
  Future<void> addPengeluaranToRTDB(Pengeluaran pengeluaran) async {
    try {
      final ref = _adminDatabase.ref('pengeluaran/${pengeluaran.id}');
      await ref.set({
        'id': pengeluaran.id,
        'deskripsi': pengeluaran.deskripsi,
        'harga': pengeluaran.harga,
        'tanggal': pengeluaran.tanggal.toUtc().toIso8601String(),
        'createdById': pengeluaran.createdById,
        'createdByName': pengeluaran.createdByName,
        'isApproved': pengeluaran.isApproved,
        'approvedById': pengeluaran.approvedById,
        'approvedByName': pengeluaran.approvedByName,
        'approvedAt': pengeluaran.approvedAt?.toUtc().toIso8601String(),
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Pengeluaran added to RTDB: ${pengeluaran.id}');
    } catch (e) {
      debugPrint('Error adding pengeluaran to RTDB: $e');
    }
  }

  Future<void> updatePengeluaranInRTDB(Pengeluaran pengeluaran) async {
    try {
      final ref = _adminDatabase.ref('pengeluaran/${pengeluaran.id}');
      await ref.update({
        'deskripsi': pengeluaran.deskripsi,
        'harga': pengeluaran.harga,
        'tanggal': pengeluaran.tanggal.toUtc().toIso8601String(),
        'isApproved': pengeluaran.isApproved,
        'approvedById': pengeluaran.approvedById,
        'approvedByName': pengeluaran.approvedByName,
        'approvedAt': pengeluaran.approvedAt?.toUtc().toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Pengeluaran updated in RTDB: ${pengeluaran.id}');
    } catch (e) {
      debugPrint('Error updating pengeluaran in RTDB: $e');
    }
  }

  Future<void> deletePengeluaranFromRTDB(String pengeluaranId) async {
    try {
      final ref = _adminDatabase.ref('pengeluaran/$pengeluaranId');
      await ref.remove();
      debugPrint('Pengeluaran deleted from RTDB: $pengeluaranId');
    } catch (e) {
      debugPrint('Error deleting pengeluaran from RTDB: $e');
    }
  }

  // READ PENGELUARAN STREAM FROM RTDB
  Stream<List<Pengeluaran>> getPengeluaranStreamRTDB() {
    final ref = _adminDatabase.ref('pengeluaran');
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        final list = <Pengeluaran>[];
        for (final entry in value.values) {
          if (entry is Map) {
            final map = Map<String, dynamic>.from(entry);
            DateTime tanggal = DateTime.now();
            try {
              if (map['tanggal'] is String) tanggal = DateTime.parse(map['tanggal']);
            } catch (_) {}
            list.add(Pengeluaran(
              id: map['id'],
              deskripsi: map['deskripsi'] ?? '',
              harga: (map['harga'] is num) ? (map['harga'] as num).toDouble() : 0.0,
              tanggal: tanggal,
              createdById: map['createdById'] ?? 'admin_legacy',
              createdByName: map['createdByName'] ?? 'Data Lama',
              isApproved: map['isApproved'] ?? true,
              approvedById: map['approvedById'],
              approvedByName: map['approvedByName'],
              approvedAt: map['approvedAt'] != null ? DateTime.tryParse(map['approvedAt']) : null,
            ));
          }
        }
        return list;
      }
      return <Pengeluaran>[];
    });
  }

  // READ SEWA STREAM FROM RTDB
  Stream<List<Sewa>> getSewaStreamRTDB() {
    final ref = _adminDatabase.ref('sewa');
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        final list = <Sewa>[];
        for (final entry in value.values) {
          if (entry is Map) {
            final map = Map<String, dynamic>.from(entry);
            // Parse dates saved as ISO strings in RTDB
            DateTime tanggal = DateTime.now();
            DateTime tanggalDibuat = DateTime.now();
            try {
              if (map['tanggal'] is String) tanggal = DateTime.parse(map['tanggal']);
              if (map['tanggalDibuat'] is String) tanggalDibuat = DateTime.parse(map['tanggalDibuat']);
            } catch (_) {}

            list.add(Sewa(
              id: map['id'],
              nama: map['nama'] ?? '',
              alamat: map['alamat'] ?? '',
              noHp: map['noHp'] ?? '',
              tanggal: tanggal,
              tanggalDibuat: tanggalDibuat,
              totalHarga: (map['totalHarga'] is num) ? (map['totalHarga'] as num).toDouble() : 0.0,
              keterangan: map['keterangan'] ?? '',
              durasi: (map['durasi'] is int) ? map['durasi'] as int : int.tryParse(map['durasi']?.toString() ?? '') ?? 0,
              jaminan: map['jaminan'] ?? '',
              createdById: map['createdById'] ?? 'admin_legacy',
              createdByName: map['createdByName'] ?? 'Data Lama',
            ));
          }
        }
        return list;
      }
      return <Sewa>[];
    });
  }

  // READ PESANAN STREAM FROM RTDB
  Stream<List<Pesanan>> getPesananStreamRTDB() {
    final ref = _adminDatabase.ref('pesanan');
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        final list = <Pesanan>[];
        for (final entry in value.values) {
          if (entry is Map) {
            final map = Map<String, dynamic>.from(entry);
            DateTime tanggalDibuat = DateTime.now();
            try {
              if (map['tanggalDibuat'] is String) tanggalDibuat = DateTime.parse(map['tanggalDibuat']);
            } catch (_) {}

            list.add(Pesanan(
              id: map['id'],
              nama: map['nama'] ?? '',
              alamat: map['alamat'] ?? '',
              noHp: map['noHp'] ?? '',
              totalHarga: (map['totalHarga'] is num) ? (map['totalHarga'] as num).toDouble() : 0.0,
              keterangan: map['keterangan'] ?? '',
              tanggalDibuat: tanggalDibuat,
              createdById: map['createdById'] ?? 'admin_legacy',
              createdByName: map['createdByName'] ?? 'Data Lama',
            ));
          }
        }
        return list;
      }
      return <Pesanan>[];
    });
  }
}