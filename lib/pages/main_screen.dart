import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'dashboard.dart';
import 'pencatatan.dart';
import 'stok.dart';
import 'sewa.dart';
import 'pemesanan.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Sewa> sewaList = [];
  final List<Pesanan> pesananList = [];
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

  void _kurangiStok(List<OrderItem> items) {
    setState(() {
      for (var orderItem in items) {
        final index = stokList.indexWhere((stok) => stok.id == orderItem.stokItemId);
        if (index != -1) {
          stokList[index].jumlah -= orderItem.jumlah;
        }
      }
    });
  }

  void _addStok(String nama, int jumlah) {
    setState(() {
      stokList.add(StokItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        jumlah: jumlah,
      ));
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
      _kurangiStok(data.items);
    });
  }

  void _deleteSewa(int index) {
    setState(() {
      sewaList.removeAt(index);
    });
  }

  void _addPesanan(Pesanan data) {
    setState(() {
      pesananList.add(data);
      _kurangiStok(data.items);
    });
  }

  void _deletePesanan(int index) {
    setState(() {
      pesananList.removeAt(index);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> currentPages = [
      DashboardScreen(
        sewaCount: sewaList.length,
        pesananCount: pesananList.length,
        stokCount: stokList.length,
        onNavigateToSewa: () => _onItemTapped(3),
        onNavigateToPesanan: () => _onItemTapped(4),
        onNavigateToStok: () => _onItemTapped(2),
      ),
      PencatatanScreen(
        stokList: stokList,
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
      SewaScreen(sewaList: sewaList, onDelete: _deleteSewa),
      PemesananScreen(pesananList: pesananList, onDelete: _deletePesanan),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: currentPages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.2 * 255).round()),
              spreadRadius: 5,
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: "Pencatatan"),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: "Stok"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: "Sewa"),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: "Pesanan"),
            ],
          ),
        ),
      ),
    );
  }
}
