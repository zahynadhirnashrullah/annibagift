// lib/pages/main_screen.dart

import 'package:flutter/material.dart';
// Naik satu level ('../') untuk keluar dari 'pages'
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firebase_admin_service.dart';

// Impor ini sekarang relatif (berada di folder 'pages' yang sama)
import 'dashboard.dart';
import 'pencatatan.dart';
import 'stok.dart';
import 'sewa.dart';
import 'pemesanan.dart';
import 'user_management_screen.dart';
import 'login_screen.dart';

// Naik satu level, lalu masuk ke 'screens'
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
  // --- SEMUA LOGIKA STATE ANDA TETAP SAMA ---
  int _selectedIndex = 0;

  double _totalSaldo = 0.0;
  final List<Sewa> sewaList = [];
  final List<Pesanan> pesananList = [];
  final List<Pengeluaran> pengeluaranList = [];
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _rebuildTransactionList();
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
        _transaksiList.fold(0.0, (sum, item) => sum + item.jumlah);
  }

  void _addStok(String nama, int jumlah) {
    setState(() {
      stokList.add(
        StokItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: nama,
          jumlah: jumlah,
        ),
      );
    });
  }

  void _updateStok(String id, String newName, int newJumlah) {
    setState(() {
      final index = stokList.indexWhere((item) => item.id == id);
      if (index != -1) {
        stokList[index].nama = newName;
        stokList[index].jumlah = newJumlah;
      }
    });
  }

  void _restockStok(String id, int additionalJumlah) {
    setState(() {
      final index = stokList.indexWhere((item) => item.id == id);
      if (index != -1) {
        stokList[index].jumlah += additionalJumlah;
      }
    });
  }

  void _addSewa(Sewa data) {
    setState(() {
      sewaList.add(data);
      _rebuildTransactionList();
    });
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
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                sewaList.removeWhere((item) => item.id == data.id);
                _rebuildTransactionList();
              });
            },
          ),
        ],
      ),
    );
  }

  void _editSewa(Sewa oldData, Sewa newData) {
    setState(() {
      final index = sewaList.indexWhere((item) => item.id == oldData.id);
      if (index != -1) {
        sewaList[index] = newData;
      }
      _rebuildTransactionList();
    });
  }

  void _addPesanan(Pesanan data) {
    setState(() {
      pesananList.add(data);
      _rebuildTransactionList();
    });
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
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                pesananList.removeWhere((item) => item.id == data.id);
                _rebuildTransactionList();
              });
            },
          ),
        ],
      ),
    );
  }

  void _editPesanan(Pesanan oldData, Pesanan newData) {
    setState(() {
      final index = pesananList.indexWhere((item) => item.id == oldData.id);
      if (index != -1) {
        pesananList[index] = newData;
      }
      _rebuildTransactionList();
    });
  }

  void _addPengeluaran(Pengeluaran data) {
    setState(() {
      pengeluaranList.add(data);
      _rebuildTransactionList();
    });
  }

  void _deletePengeluaran(Pengeluaran data) {
    setState(() {
      pengeluaranList.removeWhere((item) => item.id == data.id);
      _rebuildTransactionList();
    });
  }

  void _editPengeluaran(Pengeluaran oldData, Pengeluaran newData) {
    setState(() {
      final index =
          pengeluaranList.indexWhere((item) => item.id == oldData.id);
      if (index != -1) {
        pengeluaranList[index] = newData;
      }
      _rebuildTransactionList();
    });
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
              pengeluaranList, // <-- Mengirim list asli
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
  // --- SEMUA LOGIKA STATE ANDA BERAKHIR DI SINI ---

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        sewaCount: sewaList.length,
        pesananCount: pesananList.length,
        stokCount: stokList.length,
        totalSaldo: _totalSaldo,
        onNavigateToSewa: () => _onItemTapped(3),
        onNavigateToPesanan: () => _onItemTapped(4),
        onNavigateToStok: () => _onItemTapped(2),
        onNavigateToDetailSaldo: _navigateToDetailSaldo,
        currentUser: widget.currentUser,
        onLogout: _logout,
      ),
      PencatatanScreen(
        onConfirmSewa: _addSewa,
        onConfirmPesanan: _addPesanan,
        onNavigateAfterSubmit: (int pageIndex) => _onItemTapped(pageIndex),
      ),
      StokScreen(
        stokList: stokList,
        onAdd: _addStok,
        onUpdate: _updateStok,
        onRestock: _restockStok,
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
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_rounded),
        label: "Dashboard",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.edit_note_rounded),
        label: "Pencatatan",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_rounded),
        label: "Stok",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart_rounded),
        label: "Sewa",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.list_alt_rounded),
        label: "Pesanan",
      ),
    ];

    if (widget.currentUser.role == Role.admin) {
      pages.add(UserManagementScreen(currentUser: widget.currentUser));
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts_rounded),
          label: "Users",
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      // --- MODIFIKASI TAMPILAN NAVBAR DIMULAI DI SINI ---
      bottomNavigationBar: SafeArea(
        bottom: true, // Pastikan ada padding di bawah untuk home indicator
        top: false,
        child: Padding(
          // 1. Memberi margin horizontal dan bawah agar "mengambang"
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // 2. Memberi radius di SEMUA sudut
              borderRadius: BorderRadius.circular(24),
              // 3. Memberi bayangan yang lebih halus
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // Bayangan lebih tipis
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              // 4. Klip untuk memastikan radius di-apply ke child
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: Colors.grey.shade400,
                backgroundColor: Colors.white,
                // 5. PENTING: Hapus elevasi bawaan agar tidak bentrok
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
      // --- MODIFIKASI TAMPILAN NAVBAR SELESAI DI SINI ---
    );
  }
}