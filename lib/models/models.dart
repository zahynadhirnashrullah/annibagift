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
  String password;
  Role role;
  bool isActive; // Properti baru untuk status

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.isActive = true, // Nilai default adalah aktif
  });
}