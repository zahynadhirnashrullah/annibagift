// lib/models/models.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

// ... (OrderItem dan StokItem tidak berubah) ...
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
  // --- TAMBAHAN UNTUK DATA PER-KARYAWAN ---
  final String createdById;
  final String createdByName;
  // --- AKHIR TAMBAHAN ---

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
    // --- TAMBAHAN DI KONSTRUKTOR ---
    required this.createdById,
    required this.createdByName,
  })  : id = id ?? uuid.v4(),
        tanggalDibuat = tanggalDibuat ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'noHp': noHp,
      'tanggal': Timestamp.fromDate(tanggal),
      'tanggalDibuat': Timestamp.fromDate(tanggalDibuat),
      'keterangan': keterangan,
      'totalHarga': totalHarga,
      'durasi': durasi,
      'jaminan': jaminan,
      // --- TAMBAHAN UNTUK DISIMPAN ---
      'createdById': createdById,
      'createdByName': createdByName,
    };
  }

  static Sewa fromMap(Map<String, dynamic> map) {
    return Sewa(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      noHp: map['noHp'],
      tanggal: (map['tanggal'] as Timestamp).toDate(),
      tanggalDibuat: (map['tanggalDibuat'] as Timestamp).toDate(),
      totalHarga: map['totalHarga'],
      keterangan: map['keterangan'],
      durasi: map['durasi'],
      jaminan: map['jaminan'],
      // --- TAMBAHAN UNTUK DIBACA ---
      // Jika data lama belum punya 'createdById', beri nilai default (misal 'admin_legacy')
      createdById: map['createdById'] ?? 'admin_legacy',
      createdByName: map['createdByName'] ?? 'Data Lama',
    );
  }
}

class Pesanan {
  final String id;
  final String nama;
  final String alamat;
  final String noHp;
  final double totalHarga;
  final String keterangan;
  final DateTime tanggalDibuat;
  // --- TAMBAHAN UNTUK DATA PER-KARYAWAN ---
  final String createdById;
  final String createdByName;
  // --- AKHIR TAMBAHAN ---

  Pesanan({
    String? id,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.totalHarga,
    required this.keterangan,
    DateTime? tanggalDibuat,
    // --- TAMBAHAN DI KONSTRUKTOR ---
    required this.createdById,
    required this.createdByName,
  })  : id = id ?? uuid.v4(),
        tanggalDibuat = tanggalDibuat ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'noHp': noHp,
      'totalHarga': totalHarga,
      'keterangan': keterangan,
      'tanggalDibuat': Timestamp.fromDate(tanggalDibuat),
      // --- TAMBAHAN UNTUK DISIMPAN ---
      'createdById': createdById,
      'createdByName': createdByName,
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
      tanggalDibuat: (map['tanggalDibuat'] as Timestamp).toDate(),
      // --- TAMBAHAN UNTUK DIBACA ---
      createdById: map['createdById'] ?? 'admin_legacy',
      createdByName: map['createdByName'] ?? 'Data Lama',
    );
  }
}

class Pengeluaran {
  final String id;
  final String deskripsi;
  final double harga;
  final DateTime tanggal;
  // --- TAMBAHAN UNTUK DATA PER-KARYAWAN ---
  final String createdById;
  final String createdByName;
  // Approval flag: only approved pengeluaran affect totals
  final bool isApproved;
  // Approver metadata
  final String? approvedById;
  final DateTime? approvedAt;
  final String? approvedByName;
  // --- AKHIR TAMBAHAN ---

  Pengeluaran({
    String? id,
    required this.deskripsi,
    required this.harga,
    required this.tanggal,
    // --- TAMBAHAN DI KONSTRUKTOR ---
    required this.createdById,
    required this.createdByName,
    this.isApproved = true,
    this.approvedById,
    this.approvedAt,
    this.approvedByName,
  }) : id = id ?? uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deskripsi': deskripsi,
      'harga': harga,
      'tanggal': Timestamp.fromDate(tanggal),
      // --- TAMBAHAN UNTUK DISIMPAN ---
      'createdById': createdById,
      'createdByName': createdByName,
      'isApproved': isApproved,
      'approvedById': approvedById,
      'approvedByName': approvedByName,
      'approvedAt': approvedAt?.toUtc().toIso8601String(),
    };
  }

  static Pengeluaran fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      id: map['id'],
      deskripsi: map['deskripsi'],
      harga: map['harga'],
      tanggal: (map['tanggal'] as Timestamp).toDate(),
      // --- TAMBAHAN UNTUK DIBACA ---
      createdById: map['createdById'] ?? 'admin_legacy',
      createdByName: map['createdByName'] ?? 'Data Lama',
      isApproved: map['isApproved'] ?? true,
      approvedById: map['approvedById'],
      approvedByName: map['approvedByName'],
      approvedAt: map['approvedAt'] != null ? DateTime.tryParse(map['approvedAt']) : null,
    );
  }
}

// ... (Transaksi, Role, dan User tidak berubah) ...
enum TipeTransaksi { sewa, pesanan, pengeluaran }

class Transaksi {
  final String id;
  final TipeTransaksi tipe;
  final String deskripsi;
  final double jumlah;
  final DateTime tanggal;
  final String referensiId; // id dari Sewa/Pesanan/Pengeluaran asli
  final String? nama;
  final String? alamat;
  final DateTime? tanggalDibuat;

  Transaksi({
    required this.id,
    required this.tipe,
    required this.deskripsi,
    required this.jumlah,
    required this.tanggal,
    required this.referensiId,
    this.nama,
    this.alamat,
    this.tanggalDibuat,
  });

  // Helper untuk konversi agar mudah ditampilkan
  static Transaksi dariSewa(Sewa sewa) {
    return Transaksi(
      id: uuid.v4(),
      tipe: TipeTransaksi.sewa,
      deskripsi: "Sewa: ${sewa.nama} (${sewa.createdByName}) - ${sewa.keterangan}",
      jumlah: sewa.totalHarga,
      tanggal: sewa.tanggalDibuat,
      referensiId: sewa.id,
      nama: sewa.nama,
      alamat: sewa.alamat,
      tanggalDibuat: sewa.tanggalDibuat,
    );
  }

  static Transaksi dariPesanan(Pesanan pesanan) {
    return Transaksi(
      id: uuid.v4(),
      tipe: TipeTransaksi.pesanan,
      deskripsi: "Pesanan: ${pesanan.nama} (${pesanan.createdByName}) - ${pesanan.keterangan}",
      jumlah: pesanan.totalHarga,
      tanggal: pesanan.tanggalDibuat,
      referensiId: pesanan.id,
      nama: pesanan.nama,
      alamat: pesanan.alamat,
      tanggalDibuat: pesanan.tanggalDibuat,
    );
  }

  static Transaksi dariPengeluaran(Pengeluaran pengeluaran) {
    return Transaksi(
      id: uuid.v4(),
      tipe: TipeTransaksi.pengeluaran,
      deskripsi: "Pengeluaran: ${pengeluaran.deskripsi} (${pengeluaran.createdByName})",
      jumlah: -pengeluaran.harga, // Pengeluaran adalah nilai negatif
      tanggal: pengeluaran.tanggal,
      referensiId: pengeluaran.id,
    );
  }
}

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