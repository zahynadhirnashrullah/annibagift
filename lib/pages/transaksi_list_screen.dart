// lib/pages/transaksi_list_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
// Import kedua file konten yang sudah dimodifikasi di atas
import 'sewa.dart';
import 'pemesanan.dart';

class TransaksiListScreen extends StatefulWidget {
  // Data Sewa
  final List<Sewa> sewaList;
  final Function(Sewa) onDeleteSewa;
  final Function(Sewa) onEditSewa;

  // Data Pesanan
  final List<Pesanan> pesananList;
  final Function(Pesanan) onDeletePesanan;
  final Function(Pesanan) onEditPesanan;

  const TransaksiListScreen({
    super.key,
    required this.sewaList,
    required this.onDeleteSewa,
    required this.onEditSewa,
    required this.pesananList,
    required this.onDeletePesanan,
    required this.onEditPesanan,
  });

  @override
  State<TransaksiListScreen> createState() => _TransaksiListScreenState();
}

class _TransaksiListScreenState extends State<TransaksiListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Transaksi"),
        // MENU TAB SEPERTI DI PENCATATAN
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Data Sewa"),
            Tab(text: "Data Pesanan"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Konten Sewa
          SewaListContent(
            sewaList: widget.sewaList,
            onDelete: widget.onDeleteSewa,
            onEdit: widget.onEditSewa,
          ),
          // Tab 2: Konten Pesanan
          PemesananListContent(
            pesananList: widget.pesananList,
            onDelete: widget.onDeletePesanan,
            onEdit: widget.onEditPesanan,
          ),
        ],
      ),
    );
  }
}