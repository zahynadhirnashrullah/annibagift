// lib/services/auth_service.dart

import '../models/models.dart';

class AuthService {
  // Singleton Pattern
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final List<User> _users = [
    // --- PASTIKAN BARIS INI SUDAH BENAR ---
    User(id: '1', username: 'pemilik', password: '123', role: Role.pemilik, isActive: true),
  ];

  List<User> getUsers() {
    return _users;
  }

  User? login(String username, String password) {
    try {
      final user = _users.firstWhere(
        (u) => u.username == username && u.password == password && u.isActive,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  void updateUser(String id, String newUsername, String newPassword, Role newRole) {
    try {
      final user = _users.firstWhere((u) => u.id == id);
      user.username = newUsername;
      user.password = newPassword;
      user.role = newRole;
    } catch (e) {
      print("Error: Gagal menemukan user untuk diupdate. ID: $id");
    }
  }

  void deleteUser(String id) {
    _users.removeWhere((user) => user.id == id);
  }

  void toggleUserStatus(String id) {
    try {
      final user = _users.firstWhere((u) => u.id == id);
      user.isActive = !user.isActive;
    } catch (e) {
      print("Error: Gagal menemukan user untuk mengubah status. ID: $id");
    }
  }
  
  void addUser(String username, String password, Role role) {
    if (_users.any((user) => user.username == username)) {
      print('Username $username sudah ada!');
      return;
    }
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      password: password,
      role: role,
    );
    _users.add(newUser);
  }
}