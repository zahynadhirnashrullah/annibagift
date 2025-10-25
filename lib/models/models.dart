// lib/models/models.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // <-- TAMBAHKAN IMPORT INI
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

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

enum SewaStatus {
  proses,
  selesai,
  dibatalkan,
}

class Sewa {
  final String id;
  final String nama;
  final String alamat;
  final String noHp;
  final DateTime tanggal;
  final DateTime tanggalDibuat;
  final String keterangan;
  final double totalHarga;
  final int durasi;
  final String jaminan;
  final SewaStatus status;

  Sewa({
    String? id,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.tanggal,
    DateTime? tanggalDibuat,
    required this.totalHarga,
    required this.keterangan,
    required this.durasi,
    required this.jaminan,
    SewaStatus? status,
  })  : id = id ?? uuid.v4(),
        tanggalDibuat = tanggalDibuat ?? DateTime.now(),
        status = status ?? SewaStatus.proses;

  // --- TAMBAHAN UNTUK FIRESTORE ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'noHp': noHp,
      'tanggal': Timestamp.fromDate(tanggal), // Simpan sebagai Timestamp
      'tanggalDibuat': Timestamp.fromDate(tanggalDibuat), // Simpan sebagai Timestamp
      'keterangan': keterangan,
      'totalHarga': totalHarga,
      'durasi': durasi,
      'jaminan': jaminan,
      'status': status.name, // Simpan enum sebagai String (e.g., "proses")
    };
  }

  static Sewa fromMap(Map<String, dynamic> map) {
    return Sewa(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      noHp: map['noHp'],
      tanggal: (map['tanggal'] as Timestamp).toDate(), // Baca Timestamp
      tanggalDibuat: (map['tanggalDibuat'] as Timestamp).toDate(), // Baca Timestamp
      totalHarga: map['totalHarga'],
      keterangan: map['keterangan'],
      durasi: map['durasi'],
      jaminan: map['jaminan'],
      // Baca String dan ubah kembali ke Enum
      status: SewaStatus.values
          .firstWhere((e) => e.name == map['status'], orElse: () => SewaStatus.proses),
    );
  }
  // --- AKHIR TAMBAHAN ---
}

enum PesananStatus {
  proses,
  selesai,
  dibatalkan,
}

class Pesanan {
  final String id;
  final String nama;
  final String alamat;
  final String noHp;
  final double totalHarga;
  final String keterangan;
  final DateTime tanggalDibuat;
  final PesananStatus status;

  Pesanan({
    String? id,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.totalHarga,
    required this.keterangan,
    DateTime? tanggalDibuat,
    PesananStatus? status,
  })  : id = id ?? uuid.v4(),
        tanggalDibuat = tanggalDibuat ?? DateTime.now(),
        status = status ?? PesananStatus.proses;

  // --- TAMBAHAN UNTUK FIRESTORE ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'noHp': noHp,
      'totalHarga': totalHarga,
      'keterangan': keterangan,
      'tanggalDibuat': Timestamp.fromDate(tanggalDibuat), // Simpan sebagai Timestamp
      'status': status.name, // Simpan enum sebagai String
    };
  }

  static Pesanan fromMap(Map<String, dynamic> map) {
    return Pesanan(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      noHp: map['noHp'],
      totalHarga: map['totalHarga'],
      keterangan: map['keterangan'],
      tanggalDibuat: (map['tanggalDibuat'] as Timestamp).toDate(), // Baca Timestamp
      status: PesananStatus.values
          .firstWhere((e) => e.name == map['status'], orElse: () => PesananStatus.proses),
    );
  }
  // --- AKHIR TAMBAHAN ---
}

class Pengeluaran {
  final String id;
  final String deskripsi;
  final double harga;
  final DateTime tanggal;

  Pengeluaran({
    String? id,
    required this.deskripsi,
    required this.harga,
    required this.tanggal,
  }) : id = id ?? uuid.v4();
  
  // --- TAMBAHAN UNTUK FIRESTORE ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deskripsi': deskripsi,
      'harga': harga,
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }
  
  static Pengeluaran fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      id: map['id'],
      deskripsi: map['deskripsi'],
      harga: map['harga'],
      tanggal: (map['tanggal'] as Timestamp).toDate(),
    );
  }
  // --- AKHIR TAMBAHAN ---
}

// ... (Sisa Transaksi, Role, dan User tidak perlu diubah, sudah benar) ...

// --- FILE BARU DI SINI ---
enum TipeTransaksi { sewa, pesanan, pengeluaran }

class Transaksi {
  final String id;
  final TipeTransaksi tipe;
  final String deskripsi;
  final double jumlah;
  final DateTime tanggal;
  final String referensiId; // id dari Sewa/Pesanan/Pengeluaran asli

  Transaksi({
    required this.id,
    required this.tipe,
    required this.deskripsi,
    required this.jumlah,
    required this.tanggal,
    required this.referensiId,
  });

  // Helper untuk konversi agar mudah ditampilkan
  static Transaksi dariSewa(Sewa sewa) {
    return Transaksi(
      id: uuid.v4(),
      tipe: TipeTransaksi.sewa,
      deskripsi: "Sewa: ${sewa.nama} - ${sewa.keterangan}",
      jumlah: sewa.totalHarga,
      tanggal: sewa.tanggalDibuat,
      referensiId: sewa.id,
    );
  }

  static Transaksi dariPesanan(Pesanan pesanan) {
    return Transaksi(
      id: uuid.v4(),
      tipe: TipeTransaksi.pesanan,
      deskripsi: "Pesanan: ${pesanan.nama} - ${pesanan.keterangan}",
      jumlah: pesanan.totalHarga,
      tanggal: pesanan.tanggalDibuat,
      referensiId: pesanan.id,
    );
  }

  static Transaksi dariPengeluaran(Pengeluaran pengeluaran) {
    return Transaksi(
      id: uuid.v4(),
      tipe: TipeTransaksi.pengeluaran,
      deskripsi: "Pengeluaran: ${pengeluaran.deskripsi}",
      jumlah: -pengeluaran.harga, // Pengeluaran adalah nilai negatif
      tanggal: pengeluaran.tanggal,
      referensiId: pengeluaran.id,
    );
  }
}

// --- Role dan User tidak berubah ---
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