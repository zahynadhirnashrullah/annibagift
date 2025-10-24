// lib/models/models.dart

// Stock-related models have been removed

class Sewa {
  final String nama;
  final String alamat;
  final String noHp;
  final DateTime tanggal;
  final String keterangan;
  final double totalHarga;
  final int durasi;
  final String jaminan;

  Sewa({
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.tanggal,
    required this.totalHarga,
    required this.keterangan,
    required this.durasi,
    required this.jaminan,
  });
}

class Pesanan {
  final String nama;
  final String alamat;
  final String noHp;
  final double totalHarga;
  final String keterangan;

  Pesanan({
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.totalHarga,
    required this.keterangan,
  });
}

// --- PERUBAHAN DI SINI ---
enum Role { admin, karyawan }

class User {
  String id;
  String username;
  String email;
  Role role;
  bool isActive;
  bool isDeleted;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.isActive = true,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.toString(),
      'isActive': isActive,
      'isDeleted': isDeleted,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      role:
          (map['role'] == Role.admin.toString() || map['role'] == 'Role.admin')
          ? Role.admin
          : Role.karyawan,
      isActive: map['isActive'] ?? true,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
