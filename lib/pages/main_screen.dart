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
    _connectivitySubscription.cancel();
    super.dispose();
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
        employeeList = loadedEmployees;
        _rebuildTransactionList(); 
        _isLoading = false; 
      });
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
    _totalSaldo =
        _transaksiList.fold(0.0, (previous, item) => previous + item.jumlah);
  }

  void _addSewa(Sewa data) async {
    try {
      await sewaCollection.doc(data.id).set(data.toMap());
      setState(() {
        sewaList.add(data);
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
        status: newData.status,
        createdById: oldData.createdById, 
        createdByName: oldData.createdByName,
      );

      await sewaCollection.doc(finalData.id).update(finalData.toMap());
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
      setState(() {
        pesananList.add(data);
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
        status: newData.status,
        createdById: oldData.createdById,
        createdByName: oldData.createdByName, 
      );
      
      await pesananCollection.doc(finalData.id).update(finalData.toMap());
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
      await pengeluaranCollection.doc(data.id).set(data.toMap());
      setState(() {
        pengeluaranList.add(data);
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
       );
       
      await pengeluaranCollection.doc(finalData.id).update(finalData.toMap());
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
          employees: employeeList,
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