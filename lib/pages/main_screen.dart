// lib/pages/main_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- 1. IMPORT FIRESTORE
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firebase_admin_service.dart';

// ... (import halaman lainnya tidak berubah) ...
import 'dashboard.dart';
import 'pencatatan.dart';
import 'sewa.dart';
import 'pemesanan.dart';
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
  bool _isLoading = true; // <-- 2. TAMBAHKAN STATE LOADING

  double _totalSaldo = 0.0;
  // --- 3. UBAH DARI 'final' MENJADI LIST BIASA ---
  List<Sewa> sewaList = [];
  List<Pesanan> pesananList = [];
  List<Pengeluaran> pengeluaranList = [];
  List<Transaksi> _transaksiList = [];

  // (stokList bisa tetap di-hardcode jika tidak dikelola di DB)
  final List<StokItem> stokList = [
    StokItem(id: '1', nama: 'Kotak Kado Besar', jumlah: 15),
    // ... sisa stok ...
  ];
  
  // --- 4. BUAT REFERENSI KE COLLECTION FIRESTORE ---
  final CollectionReference sewaCollection =
      FirebaseFirestore.instance.collection('sewa');
  final CollectionReference pesananCollection =
      FirebaseFirestore.instance.collection('pesanan');
  final CollectionReference pengeluaranCollection =
      FirebaseFirestore.instance.collection('pengeluaran');


  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    // --- 5. PANGGIL FUNGSI UNTUK MEMUAT DATA DARI FIRESTORE ---
    _loadAllDataFromFirestore();
  }
  
  // --- 6. BUAT FUNGSI BARU UNTUK MEMUAT DATA ---
  Future<void> _loadAllDataFromFirestore() async {
    try {
      // Ambil data Sewa
      final sewaSnapshot = await sewaCollection.get();
      final List<Sewa> loadedSewa = sewaSnapshot.docs
          .map((doc) => Sewa.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Ambil data Pesanan
      final pesananSnapshot = await pesananCollection.get();
      final List<Pesanan> loadedPesanan = pesananSnapshot.docs
          .map((doc) => Pesanan.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
          
      // Ambil data Pengeluaran
      final pengeluaranSnapshot = await pengeluaranCollection.get();
      final List<Pengeluaran> loadedPengeluaran = pengeluaranSnapshot.docs
          .map((doc) => Pengeluaran.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Update state setelah semua data ter-load
      setState(() {
        sewaList = loadedSewa;
        pesananList = loadedPesanan;
        pengeluaranList = loadedPengeluaran;
        _rebuildTransactionList(); // Hitung ulang saldo
        _isLoading = false; // Selesai loading
      });
    } catch (e) {
      // Handle error
      print("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _rebuildTransactionList() {
    // (Fungsi ini tidak berubah, tapi sekarang ia menggunakan data dari Firestore)
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
        _transaksiList.fold(0.0, (sum, item) => sum + item.jumlah);
  }

  // --- 7. MODIFIKASI SEMUA FUNGSI (ADD, EDIT, DELETE) ---

  void _addSewa(Sewa data) async {
    try {
      // Kirim ke Firestore (gunakan ID dari model)
      await sewaCollection.doc(data.id).set(data.toMap());
      // Jika berhasil, baru update state lokal
      setState(() {
        sewaList.add(data);
        _rebuildTransactionList();
      });
    } catch (e) {
      print("Error adding sewa: $e");
      // Tampilkan error ke user jika perlu
    }
  }

  void _deleteSewa(Sewa data) {
    // (Dialog konfirmasi tidak berubah)
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
            onPressed: () async { // <-- JADIKAN ASYNC
              Navigator.of(ctx).pop();
              try {
                // Hapus dari Firestore
                await sewaCollection.doc(data.id).delete();
                // Jika berhasil, baru update state lokal
                setState(() {
                  sewaList.removeWhere((item) => item.id == data.id);
                  _rebuildTransactionList();
                });
              } catch (e) {
                print("Error deleting sewa: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  void _editSewa(Sewa oldData, Sewa newData) async {
    try {
      // Update ke Firestore
      await sewaCollection.doc(newData.id).update(newData.toMap());
      // Jika berhasil, baru update state lokal
      setState(() {
        final index = sewaList.indexWhere((item) => item.id == oldData.id);
        if (index != -1) {
          sewaList[index] = newData;
        }
        _rebuildTransactionList();
      });
    } catch (e) {
      print("Error editing sewa: $e");
    }
  }

  void _addPesanan(Pesanan data) async {
    try {
      // Kirim ke Firestore
      await pesananCollection.doc(data.id).set(data.toMap());
      // Jika berhasil, baru update state lokal
      setState(() {
        pesananList.add(data);
        _rebuildTransactionList();
      });
    } catch (e) {
      print("Error adding pesanan: $e");
    }
  }

  void _deletePesanan(Pesanan data) {
    // (Dialog konfirmasi)
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
            onPressed: () async { // <-- JADIKAN ASYNC
              Navigator.of(ctx).pop();
              try {
                // Hapus dari Firestore
                await pesananCollection.doc(data.id).delete();
                // Jika berhasil, baru update state lokal
                setState(() {
                  pesananList.removeWhere((item) => item.id == data.id);
                  _rebuildTransactionList();
                });
              } catch (e) {
                print("Error deleting pesanan: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  void _editPesanan(Pesanan oldData, Pesanan newData) async {
    try {
      // Update ke Firestore
      await pesananCollection.doc(newData.id).update(newData.toMap());
      // Jika berhasil, baru update state lokal
      setState(() {
        final index = pesananList.indexWhere((item) => item.id == oldData.id);
        if (index != -1) {
          pesananList[index] = newData;
        }
        _rebuildTransactionList();
      });
    } catch (e) {
      print("Error editing pesanan: $e");
    }
  }
  
  // (Lakukan hal yang sama untuk _addPengeluaran, _deletePengeluaran, _editPengeluaran)
  
  void _addPengeluaran(Pengeluaran data) async {
    try {
      await pengeluaranCollection.doc(data.id).set(data.toMap());
      setState(() {
        pengeluaranList.add(data);
        _rebuildTransactionList();
      });
    } catch (e) {
      print("Error adding pengeluaran: $e");
    }
  }

  void _deletePengeluaran(Pengeluaran data) async {
    try {
      await pengeluaranCollection.doc(data.id).delete();
      setState(() {
        pengeluaranList.removeWhere((item) => item.id == data.id);
        _rebuildTransactionList();
      });
    } catch (e) {
      print("Error deleting pengeluaran: $e");
    }
  }

  void _editPengeluaran(Pengeluaran oldData, Pengeluaran newData) async {
     try {
      await pengeluaranCollection.doc(newData.id).update(newData.toMap());
      setState(() {
        final index =
            pengeluaranList.indexWhere((item) => item.id == oldData.id);
        if (index != -1) {
          pengeluaranList[index] = newData;
        }
        _rebuildTransactionList();
      });
     } catch (e) {
       print("Error editing pengeluaran: $e");
     }
  }


  // --- Sisa fungsi navigasi tidak berubah ---
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
  

  @override
  Widget build(BuildContext context) {
    
    final bool isAdmin = widget.currentUser.role == Role.admin;
    final List<Widget> pages = [];
    final List<BottomNavigationBarItem> navItems = [];

    // --- 8. TAMPILKAN LOADING INDICATOR ---
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // --- (Sisa logika build() Anda sudah benar) ---
    pages.add(
      DashboardScreen(
        sewaCount: sewaList.length,
        pesananCount: pesananList.length,
        stokCount: stokList.length,
        totalSaldo: _totalSaldo,
        onNavigateToSewa: () => _onItemTapped(2), 
        onNavigateToPesanan: () => _onItemTapped(3),
        onNavigateToStok: () => _onItemTapped(1), 
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
      pages.addAll([
        LaporanScreen(
          sewaList: sewaList,
          pesananList: pesananList,
        ),
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
      pages.addAll([
        PencatatanScreen(
          onConfirmSewa: _addSewa,
          onConfirmPesanan: _addPesanan,
          onNavigateAfterSubmit: (int pageIndex) => _onItemTapped(pageIndex),
        ),
        SewaScreen(
          sewaList: sewaList,
          onDelete: _deleteSewa,
          onEdit: _navigateToEditSewa,
        ),
        PemesananScreen(
          pesananList: pesananList,
          onDelete: _deletePesanan,
          onEdit: _navigateToEditPesanan,
        ),
      ]);
      navItems.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.edit_note_rounded),
          label: "Pencatatan",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_rounded),
          label: "Sewa",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_rounded),
          label: "Pesanan",
        ),
      ]);
    }
    
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
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