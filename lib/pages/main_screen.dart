// lib/pages/main_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart'; 
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firebase_admin_service.dart';

import 'dashboard.dart';
import 'pencatatan.dart';
// Import halaman baru
import 'transaksi_list_screen.dart'; 
import 'user_management_screen.dart';
import 'login_screen.dart';
import 'laporan_screen.dart';
import '../screens/edit_sewa_screen.dart';
import '../screens/edit_pesanan_screen.dart';
import '../screens/detail_saldo_screen.dart';

class MainScreen extends StatefulWidget {
  final User currentUser;

  const MainScreen({super.key, required this.currentUser});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true; 

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;

  double _totalSaldo = 0.0;
  List<Sewa> sewaList = [];
  List<Pesanan> pesananList = [];
  List<Pengeluaran> pengeluaranList = [];
  List<User> employeeList = []; 
  List<Transaksi> _transaksiList = [];
  // Debug counts to compare Firestore vs RTDB
  int sewaCountFirestore = 0;
  int pesananCountFirestore = 0;
  int pengeluaranCountFirestore = 0;
  int sewaCountRTDB = 0;
  int pesananCountRTDB = 0;
  int pengeluaranCountRTDB = 0;
  StreamSubscription<List<Sewa>>? _sewaStreamSub;
  StreamSubscription<List<Pesanan>>? _pesananStreamSub;
  StreamSubscription<List<Pengeluaran>>? _pengeluaranStreamSub;

  final List<StokItem> stokList = [
    StokItem(id: '1', nama: 'Kotak Kado Besar', jumlah: 15),
    StokItem(id: '2', nama: 'Pita Satin Merah (rol)', jumlah: 30),
    StokItem(id: '3', nama: 'Snack Bouquet', jumlah: 12),
    StokItem(id: '4', nama: 'Papan Bunga', jumlah: 8),
    StokItem(id: '5', nama: 'Wrapping Paper Emas', jumlah: 20),
    StokItem(id: '6', nama: 'Kartu Ucapan', jumlah: 50),
    StokItem(id: '7', nama: 'Bunga Segar (ikat)', jumlah: 9),
    StokItem(id: '8', nama: 'Kotak Kado Kecil', jumlah: 25),
    StokItem(id: '9', nama: 'Pita Satin Biru (rol)', jumlah: 18),
    StokItem(id: '10', nama: 'Snack Box', jumlah: 14),
    StokItem(id: '11', nama: 'Balon Helium (pak)', jumlah: 22),
    StokItem(id: '12', nama: 'Kertas Kado Polkadot', jumlah: 17),
    StokItem(id: '13', nama: 'Bunga Plastik (ikat)', jumlah: 11),
    StokItem(id: '14', nama: 'Kartu Ucapan Spesial', jumlah: 35),
    StokItem(id: '15', nama: 'Papan Bunga Mini', jumlah: 5),
    StokItem(id: '16', nama: 'Bouquet Hijab', jumlah: 19),
    StokItem(id: '17', nama: 'Money Bouquet', jumlah: 13),
    StokItem(id: '18', nama: 'Bloom Box', jumlah: 7),
  ];
  
  final CollectionReference sewaCollection =
      FirebaseFirestore.instance.collection('sewa');
  final CollectionReference pesananCollection =
      FirebaseFirestore.instance.collection('pesanan');
  final CollectionReference pengeluaranCollection =
      FirebaseFirestore.instance.collection('pengeluaran');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');


  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _loadAllDataFromFirestore();
    _startRTDBListeners();

    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }
  
  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _isOffline = result.contains(ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _sewaStreamSub?.cancel();
    _pesananStreamSub?.cancel();
    _pengeluaranStreamSub?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _startRTDBListeners() {
    try {
      _sewaStreamSub = FirebaseAdminService.instance.getSewaStreamRTDB().listen((remoteSewa) {
        final bool isAdmin = widget.currentUser.role == Role.admin;
        final filteredRemote = isAdmin ? remoteSewa : remoteSewa.where((s) => s.createdById == widget.currentUser.id).toList();
        // set RTDB counts for debugging
        sewaCountRTDB = filteredRemote.length;
        // Merge RTDB remote items with existing Firestore-loaded items to avoid losing entries
        final Map<String, Sewa> keyed = {};
        // Start with existing local items (from Firestore)
        for (final s in sewaList) {
          keyed[s.id] = s;
        }
        // Overlay/replace with RTDB items (prefer RTDB for freshness)
        for (final s in filteredRemote) {
          keyed[s.id] = s;
        }
        final merged = keyed.values.toList();
        setState(() {
          sewaList = merged;
          _rebuildTransactionList();
        });
        debugPrint('RTDB sewa stream merged update: ${sewaList.length} items (isAdmin: $isAdmin)');
      }, onError: (e) {
        debugPrint('Error in sewa RTDB stream: $e');
      });

      _pesananStreamSub = FirebaseAdminService.instance.getPesananStreamRTDB().listen((remotePesanan) {
        final bool isAdmin = widget.currentUser.role == Role.admin;
        final filteredRemote = isAdmin ? remotePesanan : remotePesanan.where((p) => p.createdById == widget.currentUser.id).toList();
        final Map<String, Pesanan> keyed = {};
        pesananCountRTDB = filteredRemote.length;
        // Preserve existing Firestore-loaded pesanan
        for (final p in pesananList) {
          keyed[p.id] = p;
        }
        // Overlay with RTDB items
        for (final p in filteredRemote) {
          keyed[p.id] = p;
        }
        final merged = keyed.values.toList();
        setState(() {
          pesananList = merged;
          _rebuildTransactionList();
        });
        debugPrint('RTDB pesanan stream merged update: ${pesananList.length} items (isAdmin: $isAdmin)');
      }, onError: (e) {
        debugPrint('Error in pesanan RTDB stream: $e');
      });

      _pengeluaranStreamSub = FirebaseAdminService.instance.getPengeluaranStreamRTDB().listen((remotePengeluaran) {
        final bool isAdmin = widget.currentUser.role == Role.admin;
        final filteredRemote = isAdmin ? remotePengeluaran : remotePengeluaran.where((p) => p.createdById == widget.currentUser.id).toList();
        final Map<String, Pengeluaran> keyed = {};
        pengeluaranCountRTDB = filteredRemote.length;
        // Start with existing Firestore-loaded pengeluaran
        for (final p in pengeluaranList) {
          keyed[p.id] = p;
        }
        // Overlay with RTDB items
        for (final p in filteredRemote) {
          keyed[p.id] = p;
        }
        final merged = keyed.values.toList();
        setState(() {
          pengeluaranList = merged;
          _rebuildTransactionList();
        });
        debugPrint('RTDB pengeluaran stream merged update: ${pengeluaranList.length} items (isAdmin: $isAdmin)');
      }, onError: (e) {
        debugPrint('Error in pengeluaran RTDB stream: $e');
      });

      // Reload employees list periodically or on demand for admin users
      if (widget.currentUser.role == Role.admin) {
        _reloadEmployeesList();
      }
    } catch (e) {
      debugPrint('Failed to start RTDB listeners: $e');
    }
  }

  void _reloadEmployeesList() async {
    try {
      final usersSnapshot = await usersCollection
          .where('role', isEqualTo: Role.karyawan.toString())
          .where('isDeleted', isEqualTo: false)
          .get();
      final loadedEmployees = usersSnapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        employeeList = loadedEmployees;
      });
      debugPrint('Reloaded ${loadedEmployees.length} employees');
    } catch (e) {
      debugPrint('Error reloading employees: $e');
    }
  }
  
  // ... (FUNGSI LOGIKA CRUD TIDAK BERUBAH) ...
  // (Pastikan fungsi _loadAllDataFromFirestore, _addSewa, _deleteSewa, _editSewa, dll tetap ada di sini)
  // SAYA HANYA MENYALIN BAGIAN YANG PERLU DIUBAH DI BAWAH INI UNTUK HEMAT TEMPAT
  // TETAPI ANDA HARUS TETAP MEMILIKI FUNGSI-FUNGSI TERSEBUT DI DALAM KELAS INI

  Future<void> _loadAllDataFromFirestore() async {
    try {
      final bool isAdmin = widget.currentUser.role == Role.admin;
      List<User> loadedEmployees = [];

      Query sewaQuery = sewaCollection;
      Query pesananQuery = pesananCollection;
      Query pengeluaranQuery = pengeluaranCollection;

      if (!isAdmin) {
        sewaQuery = sewaQuery.where('createdById', isEqualTo: widget.currentUser.id);
        pesananQuery = pesananQuery.where('createdById', isEqualTo: widget.currentUser.id);
        pengeluaranQuery = pengeluaranQuery.where('createdById', isEqualTo: widget.currentUser.id);
      }
      
      if (isAdmin) {
        final usersSnapshot = await usersCollection
            .where('role', isEqualTo: Role.karyawan.toString())
            .where('isDeleted', isEqualTo: false)
            .get();
        loadedEmployees = usersSnapshot.docs
            .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      }

      final sewaSnapshot = await sewaQuery.get();
      final List<Sewa> loadedSewa = sewaSnapshot.docs
          .map((doc) => Sewa.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final pesananSnapshot = await pesananQuery.get();
      final List<Pesanan> loadedPesanan = pesananSnapshot.docs
          .map((doc) => Pesanan.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
          
      final pengeluaranSnapshot = await pengeluaranQuery.get();
      final List<Pengeluaran> loadedPengeluaran = pengeluaranSnapshot.docs
          .map((doc) => Pengeluaran.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        sewaList = loadedSewa;
        pesananList = loadedPesanan;
        pengeluaranList = loadedPengeluaran;
        // store firestore counts for debugging
        sewaCountFirestore = loadedSewa.length;
        pesananCountFirestore = loadedPesanan.length;
        pengeluaranCountFirestore = loadedPengeluaran.length;
        employeeList = loadedEmployees;
        _rebuildTransactionList(); 
        _isLoading = false; 
      });
      debugPrint("Loaded ${loadedSewa.length} sewa documents (isAdmin: $isAdmin, userId: ${widget.currentUser.id})");
      debugPrint("Loaded ${loadedPesanan.length} pesanan documents (isAdmin: $isAdmin, userId: ${widget.currentUser.id})");
      debugPrint("Loaded ${loadedPengeluaran.length} pengeluaran documents");
      debugPrint("Loaded ${loadedEmployees.length} employees (isAdmin: $isAdmin)");
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _rebuildTransactionList() {
    setState(() {
      _transaksiList = [
        ...sewaList.map((s) => Transaksi.dariSewa(s)),
        ...pesananList.map((p) => Transaksi.dariPesanan(p)),
        // Include all pengeluaran in the list (show pending items), totals will ignore unapproved ones
        ...pengeluaranList.map((e) => Transaksi.dariPengeluaran(e)),
      ];
      _calculateTotalSaldo();
    });
  }

  void _calculateTotalSaldo() {
    if (_transaksiList.isEmpty) {
      _totalSaldo = 0.0;
      return;
    }
    double total = 0.0;
    for (final item in _transaksiList) {
      if (item.tipe == TipeTransaksi.pengeluaran) {
        final matches = pengeluaranList.where((x) => x.id == item.referensiId).toList();
        if (matches.isEmpty) continue;
        final p = matches.first;
        if (!p.isApproved) continue; // skip unapproved pengeluaran
        total += item.jumlah;
      } else {
        total += item.jumlah;
      }
    }
    _totalSaldo = total;
  }

  
  void _addSewa(Sewa data) async {
    try {
      await sewaCollection.doc(data.id).set(data.toMap());
      debugPrint("✓ Sewa saved to Firestore: ${data.id}");
      // Also save to Realtime Database
      try {
        await FirebaseAdminService.instance.addSewaToRTDB(data);
        debugPrint("✓ Sewa saved to RTDB: ${data.id}");
      } catch (e) {
        debugPrint("Warning: Failed to save sewa to RTDB: $e");
      }
      setState(() {
        if (!sewaList.any((s) => s.id == data.id)) sewaList.add(data);
        _rebuildTransactionList();
      });
    } catch (e) {
      debugPrint("Error adding sewa: $e");
    }
  }

  void _deleteSewa(Sewa data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Anda yakin ingin menghapus data sewa ${data.nama}? Saldo akan diperbarui.'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.accentRed)),
            onPressed: () async { 
              Navigator.of(ctx).pop();
              try {
                await sewaCollection.doc(data.id).delete();
                // Also delete from RTDB
                try {
                  await FirebaseAdminService.instance.deleteSewaFromRTDB(data.id);
                } catch (e) {
                  debugPrint('Warning: failed to delete sewa from RTDB: $e');
                }
                setState(() {
                  sewaList.removeWhere((item) => item.id == data.id);
                  _rebuildTransactionList();
                });
              } catch (e) {
                debugPrint("Error deleting sewa: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  void _editSewa(Sewa oldData, Sewa newData) async {
    try {
      final finalData = Sewa(
        id: newData.id,
        nama: newData.nama,
        alamat: newData.alamat,
        noHp: newData.noHp,
        tanggal: newData.tanggal,
        tanggalDibuat: newData.tanggalDibuat,
        totalHarga: newData.totalHarga,
        keterangan: newData.keterangan,
        durasi: newData.durasi,
        jaminan: newData.jaminan,
        createdById: oldData.createdById, 
        createdByName: oldData.createdByName,
      );

      await sewaCollection.doc(finalData.id).update(finalData.toMap());
        // Also update in Realtime Database
        try {
          await FirebaseAdminService.instance.updateSewaInRTDB(finalData);
        } catch (e) {
          debugPrint('Warning: failed to update sewa in RTDB: $e');
        }
      setState(() {
        final index = sewaList.indexWhere((item) => item.id == oldData.id);
        if (index != -1) {
          sewaList[index] = finalData;
        }
        _rebuildTransactionList();
      });
    } catch (e) {
      debugPrint("Error editing sewa: $e");
    }
  }

  void _addPesanan(Pesanan data) async {
    try {
      await pesananCollection.doc(data.id).set(data.toMap());
      debugPrint("✓ Pesanan saved to Firestore: ${data.id}");
      try {
        await FirebaseAdminService.instance.addPesananToRTDB(data);
        debugPrint("✓ Pesanan saved to RTDB: ${data.id}");
      } catch (e) {
        debugPrint("Warning: Failed to save pesanan to RTDB: $e");
      }
      setState(() {
        if (!pesananList.any((p) => p.id == data.id)) pesananList.add(data);
        _rebuildTransactionList();
      });
    } catch (e) {
      debugPrint("Error adding pesanan: $e");
    }
  }

  void _deletePesanan(Pesanan data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Anda yakin ingin menghapus data pesanan ${data.nama}? Saldo akan diperbarui.'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.accentRed)),
            onPressed: () async { 
              Navigator.of(ctx).pop();
              try {
                await pesananCollection.doc(data.id).delete();
                // Also delete from RTDB
                try {
                  await FirebaseAdminService.instance.deletePesananFromRTDB(data.id);
                } catch (e) {
                  debugPrint('Warning: failed to delete pesanan from RTDB: $e');
                }
                setState(() {
                  pesananList.removeWhere((item) => item.id == data.id);
                  _rebuildTransactionList();
                });
              } catch (e) {
                debugPrint("Error deleting pesanan: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  void _editPesanan(Pesanan oldData, Pesanan newData) async {
    try {
      final finalData = Pesanan(
        id: newData.id,
        nama: newData.nama,
        alamat: newData.alamat,
        noHp: newData.noHp,
        totalHarga: newData.totalHarga,
        keterangan: newData.keterangan,
        tanggalDibuat: newData.tanggalDibuat,
        createdById: oldData.createdById,
        createdByName: oldData.createdByName, 
      );
      
      await pesananCollection.doc(finalData.id).update(finalData.toMap());
      // Also update in RTDB
      try {
        await FirebaseAdminService.instance.updatePesananInRTDB(finalData);
      } catch (e) {
        debugPrint('Warning: failed to update pesanan in RTDB: $e');
      }
      setState(() {
        final index = pesananList.indexWhere((item) => item.id == oldData.id);
        if (index != -1) {
          pesananList[index] = finalData;
        }
        _rebuildTransactionList();
      });
    } catch (e) {
      debugPrint("Error editing pesanan: $e");
    }
  }

  void _addPengeluaran(Pengeluaran data) async {
    try {
      // If created by non-admin, mark as not approved so it won't affect totals
      final shouldApprove = widget.currentUser.role == Role.admin;
      final now = DateTime.now().toUtc();
      final pengeluaranToSave = Pengeluaran(
        id: data.id,
        deskripsi: data.deskripsi,
        harga: data.harga,
        tanggal: data.tanggal,
        createdById: data.createdById,
        createdByName: data.createdByName,
        isApproved: shouldApprove,
        approvedById: shouldApprove ? widget.currentUser.id : null,
        approvedByName: shouldApprove ? widget.currentUser.username : null,
        approvedAt: shouldApprove ? now : null,
      );

      await pengeluaranCollection.doc(pengeluaranToSave.id).set(pengeluaranToSave.toMap());
      // Also save to RTDB
      try {
        await FirebaseAdminService.instance.addPengeluaranToRTDB(pengeluaranToSave);
      } catch (e) {
        debugPrint('Warning: failed to save pengeluaran to RTDB: $e');
      }
      setState(() {
        if (!pengeluaranList.any((p) => p.id == pengeluaranToSave.id)) pengeluaranList.add(pengeluaranToSave);
        _rebuildTransactionList();
      });
    } catch (e) {
      debugPrint("Error adding pengeluaran: $e");
    }
  }

  void _deletePengeluaran(Pengeluaran data) async {
    try {
      if (widget.currentUser.role != Role.admin && data.createdById != widget.currentUser.id) {
         debugPrint("Akses ditolak: Karyawan tidak bisa menghapus data orang lain.");
         return;
      }
      
      await pengeluaranCollection.doc(data.id).delete();
      // Also delete from RTDB
      try {
        await FirebaseAdminService.instance.deletePengeluaranFromRTDB(data.id);
      } catch (e) {
        debugPrint('Warning: failed to delete pengeluaran from RTDB: $e');
      }
      setState(() {
        pengeluaranList.removeWhere((item) => item.id == data.id);
        _rebuildTransactionList();
      });
    } catch (e) {
      debugPrint("Error deleting pengeluaran: $e");
    }
  }

  void _editPengeluaran(Pengeluaran oldData, Pengeluaran newData) async {
     try {
       final finalData = Pengeluaran(
         id: newData.id,
         deskripsi: newData.deskripsi,
         harga: newData.harga,
         tanggal: newData.tanggal,
         createdById: oldData.createdById, 
         createdByName: oldData.createdByName,
         // preserve approval state unless an admin edits
         isApproved: widget.currentUser.role == Role.admin ? (newData.isApproved) : oldData.isApproved,
        approvedById: oldData.approvedById,
        approvedByName: oldData.approvedByName,
        approvedAt: oldData.approvedAt,
       );
       
      await pengeluaranCollection.doc(finalData.id).update(finalData.toMap());
      // Also update in RTDB
      try {
        await FirebaseAdminService.instance.updatePengeluaranInRTDB(finalData);
      } catch (e) {
        debugPrint('Warning: failed to update pengeluaran in RTDB: $e');
      }
      setState(() {
        final index =
            pengeluaranList.indexWhere((item) => item.id == oldData.id);
        if (index != -1) {
          pengeluaranList[index] = finalData;
        }
        _rebuildTransactionList();
      });
     } catch (e) {
       debugPrint("Error editing pengeluaran: $e");
     }
  }

  // Approve a pending pengeluaran (admin action)
  void _approvePengeluaran(Pengeluaran p) async {
    try {
      final now = DateTime.now().toUtc();
      final updated = Pengeluaran(
        id: p.id,
        deskripsi: p.deskripsi,
        harga: p.harga,
        tanggal: p.tanggal,
        createdById: p.createdById,
        createdByName: p.createdByName,
        isApproved: true,
        approvedById: widget.currentUser.id,
        approvedByName: widget.currentUser.username,
        approvedAt: now,
      );

      await pengeluaranCollection.doc(updated.id).update({
        'isApproved': true,
        'approvedById': updated.approvedById,
        'approvedByName': updated.approvedByName,
        'approvedAt': updated.approvedAt?.toUtc().toIso8601String(),
      });

      // Also update RTDB
      try {
        await FirebaseAdminService.instance.updatePengeluaranInRTDB(updated);
      } catch (e) {
        debugPrint('Warning: failed to update pengeluaran in RTDB: $e');
      }

      final idx = pengeluaranList.indexWhere((x) => x.id == p.id);
      if (idx != -1) {
        setState(() {
          pengeluaranList[idx] = updated;
          _rebuildTransactionList();
        });
      }
    } catch (e) {
      debugPrint('Error approving pengeluaran: $e');
    }
  }


  // Disapprove an approved pengeluaran (admin action)
  void _disapprovePengeluaran(Pengeluaran p) async {
    try {
      final updated = Pengeluaran(
        id: p.id,
        deskripsi: p.deskripsi,
        harga: p.harga,
        tanggal: p.tanggal,
        createdById: p.createdById,
        createdByName: p.createdByName,
        isApproved: false,
        approvedById: null,
        approvedByName: null,
        approvedAt: null,
      );

      await pengeluaranCollection.doc(updated.id).update({
        'isApproved': false,
        'approvedById': null,
        'approvedByName': null,
        'approvedAt': null,
      });

      // Also update RTDB
      try {
        await FirebaseAdminService.instance.updatePengeluaranInRTDB(updated);
      } catch (e) {
        debugPrint('Warning: failed to update pengeluaran in RTDB: $e');
      }

      final idx = pengeluaranList.indexWhere((x) => x.id == p.id);
      if (idx != -1) {
        setState(() {
          pengeluaranList[idx] = updated;
          _rebuildTransactionList();
        });
      }
    } catch (e) {
      debugPrint('Error disapproving pengeluaran: $e');
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await AuthService.instance.signOut();
    await FirebaseAdminService.instance.signOutAdmin();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToDetailSaldo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSaldoScreen(
          transactions: _transaksiList,
          pengeluaranListAsli:
              pengeluaranList, 
          onAddPengeluaran: _addPengeluaran,
          onEditPengeluaran: _editPengeluaran,
          onDeletePengeluaran: _deletePengeluaran,
            onApprovePengeluaran: _approvePengeluaran,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  void _navigateToEditSewa(Sewa sewa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSewaScreen(
          sewa: sewa,
          onConfirmEdit: _editSewa,
        ),
      ),
    );
  }

  void _navigateToEditPesanan(Pesanan pesanan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPesananScreen(
          pesanan: pesanan,
          onConfirmEdit: _editPesanan,
        ),
      ),
    );
  }
  
  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Text(
        'Anda sedang offline. Data akan disinkronkan nanti.',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final bool isAdmin = widget.currentUser.role == Role.admin;
    final List<Widget> pages = [];
    final List<BottomNavigationBarItem> navItems = [];

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 1. DASHBOARD (INDEX 0)
    pages.add(
      DashboardScreen(
        sewaCount: sewaList.length,
        pesananCount: pesananList.length,
        stokCount: stokList.length,
        totalSaldo: _totalSaldo,
        // ARAHKAN KEDUA TOMBOL KE INDEX 2 (Halaman Data Transaksi)
        onNavigateToSewa: () => _onItemTapped(2), 
        onNavigateToPesanan: () => _onItemTapped(2),
        onNavigateToStok: () => _onItemTapped(1), // Tidak ada perubahan
        onNavigateToDetailSaldo: _navigateToDetailSaldo,
        currentUser: widget.currentUser,
        onLogout: _logout,
        transactions: _transaksiList,
        employees: employeeList,
        sewaCountRTDB: sewaCountRTDB,
        pesananCountRTDB: pesananCountRTDB,
      ),
    );
    navItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_rounded),
        label: "Dashboard",
      ),
    );

    if (isAdmin) {
      // ADMIN VIEW
      pages.addAll([
        // Index 1: Laporan
        LaporanScreen(
          sewaList: sewaList,
          pesananList: pesananList,
          pengeluaranList: pengeluaranList,
          employees: employeeList,
          currentUser: widget.currentUser,
          onApprovePengeluaran: _approvePengeluaran,
          onDisapprovePengeluaran: _disapprovePengeluaran,
          onAddPengeluaran: _addPengeluaran,
        ),
        // Index 2: Users
        UserManagementScreen(currentUser: widget.currentUser),
      ]);
      navItems.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.assessment_rounded), 
          label: "Laporan",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts_rounded),
          label: "Users",
        ),
      ]);
    } else {
      // KARYAWAN VIEW
      pages.addAll([
        // Index 1: Pencatatan (Input)
        PencatatanScreen(
          onConfirmSewa: _addSewa,
          onConfirmPesanan: _addPesanan,
          onConfirmPengeluaran: _addPengeluaran,
          // Setelah input, arahkan ke Index 2 (Halaman Data)
          onNavigateAfterSubmit: (int pageIndex) => _onItemTapped(2), 
          currentUser: widget.currentUser,
        ),
        
        // Index 2: DATA TRANSAKSI (GABUNGAN SEWA & PESANAN)
        TransaksiListScreen(
          sewaList: sewaList,
          onDeleteSewa: _deleteSewa,
          onEditSewa: _navigateToEditSewa,
          pesananList: pesananList,
          onDeletePesanan: _deletePesanan,
          onEditPesanan: _navigateToEditPesanan,
          pengeluaranList: pengeluaranList,
          onDeletePengeluaran: _deletePengeluaran,
          onEditPengeluaran: _editPengeluaran,
          onApprovePengeluaran: _approvePengeluaran,
          onDisapprovePengeluaran: _disapprovePengeluaran,
          currentUser: widget.currentUser,
        ),
      ]);
      navItems.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.edit_note_rounded),
          label: "Pencatatan",
        ),
        // MENU GABUNGAN
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded), // Ikon yang merepresentasikan daftar
          label: "Data",
        ),
      ]);
    }
    
    return Scaffold(
      body: Column( 
        children: [
          if (_isOffline)
            SafeArea( 
              bottom: false,
              child: _buildOfflineBanner(),
            ),
          
          Expanded(
            child: IndexedStack(
              index: _selectedIndex, 
              children: pages
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        bottom: true, 
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.08).round()),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: Colors.grey.shade400,
                backgroundColor: Colors.white,
                elevation: 0, 
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: navItems,
              ),
            ),
          ),
        ),
      ),
    );
  }
}