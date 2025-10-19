// lib/models/models.dart

class OrderItem {
  final String stokItemId;
  final String namaBarang;
  int jumlah;

  OrderItem({
    required this.stokItemId,
    required this.namaBarang,
    required this.jumlah,
  });
}

class StokItem {
  String id;
  String nama;
  int jumlah;

  StokItem({required this.id, required this.nama, required this.jumlah});
}

class Sewa {
  final String nama;
  final String alamat;
  final DateTime tanggal;
  final List<OrderItem> items;
  final int durasi;
  final String jaminan;

  Sewa({
    required this.nama,
    required this.alamat,
    required this.tanggal,
    required this.items,
    required this.durasi,
    required this.jaminan,
  });
}

class Pesanan {
  final String nama;
  final String alamat;
  final DateTime tanggal;
  final List<OrderItem> items;

  Pesanan({
    required this.nama,
    required this.alamat,
    required this.tanggal,
    required this.items,
  });
}

// --- PERUBAHAN DI SINI ---
enum Role { pemilik, karyawan }

class User {
  String id;
  String username;
  String email;
  Role role;
  bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.toString(),
      'isActive': isActive,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      role: map['role'] == Role.pemilik.toString() ? Role.pemilik : Role.karyawan,
      isActive: map['isActive'] ?? true,
    );
  }
}