// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'dashboard.dart';
import 'pencatatan.dart';
import 'sewa.dart';
import 'pemesanan.dart';
import 'user_management_screen.dart';
import 'login_screen.dart';
// Import service yang relevan
import '../services/auth_service.dart';
import '../services/firebase_admin_service.dart';

class MainScreen extends StatefulWidget {
  final User currentUser;

  const MainScreen({super.key, required this.currentUser});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Data state
  final List<Sewa> sewaList = [];
  final List<Pesanan> pesananList = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  // Stock-related functions have been removed

  void _addSewa(Sewa data) {
    setState(() {
      sewaList.add(data);
      // --- PERBAIKAN: _kurangiStok(data.items) dihapus ---
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
      // --- PERBAIKAN: _kurangiStok(data.items) dihapus ---
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        sewaCount: sewaList.length,
        pesananCount: pesananList.length,
        onNavigateToSewa: () => _onItemTapped(2),
        onNavigateToPesanan: () => _onItemTapped(3),
        currentUser: widget.currentUser,
        onLogout: _logout,
      ),
      PencatatanScreen(
        onConfirmSewa: _addSewa,
        onConfirmPesanan: _addPesanan,
        onNavigateAfterSubmit: (int pageIndex) => _onItemTapped(pageIndex),
      ),
      SewaScreen(sewaList: sewaList, onDelete: _deleteSewa),
      PemesananScreen(pesananList: pesananList, onDelete: _deletePesanan),
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
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: navItems,
          ),
        ),
      ),
    );
  }
}
