// lib/pages/transaksi_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
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

  // Data Pengeluaran
  final List<Pengeluaran> pengeluaranList;
  final Function(Pengeluaran) onDeletePengeluaran;
  final Function(Pengeluaran, Pengeluaran) onEditPengeluaran;
  final Function(Pengeluaran) onApprovePengeluaran;
  final Function(Pengeluaran) onDisapprovePengeluaran;

  // Current User
  final User currentUser;

  const TransaksiListScreen({
    super.key,
    required this.sewaList,
    required this.onDeleteSewa,
    required this.onEditSewa,
    required this.pesananList,
    required this.onDeletePesanan,
    required this.onEditPesanan,
    required this.pengeluaranList,
    required this.onDeletePengeluaran,
    required this.onEditPengeluaran,
    required this.onApprovePengeluaran,
    required this.onDisapprovePengeluaran,
    required this.currentUser,
  });

  @override
  State<TransaksiListScreen> createState() => _TransaksiListScreenState();
}

class _TransaksiListScreenState extends State<TransaksiListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: "Data Pengeluaran"),
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
          // Tab 3: Konten Pengeluaran
          _PengeluaranListContent(
            pengeluaranList: widget.pengeluaranList,
            onDelete: widget.onDeletePengeluaran,
            onEdit: widget.onEditPengeluaran,
            onApprove: widget.onApprovePengeluaran,
            onDisapprove: widget.onDisapprovePengeluaran,
            currentUser: widget.currentUser,
          ),
        ],
      ),
    );
  }

}

class _PengeluaranListContent extends StatelessWidget {
  final List<Pengeluaran> pengeluaranList;
  final Function(Pengeluaran) onDelete;
  final Function(Pengeluaran, Pengeluaran) onEdit;
  final Function(Pengeluaran) onApprove;
  final Function(Pengeluaran) onDisapprove;
  final User currentUser;

  const _PengeluaranListContent({
    required this.pengeluaranList,
    required this.onDelete,
    required this.onEdit,
    required this.onApprove,
    required this.onDisapprove,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (pengeluaranList.isEmpty) {
      return const Center(child: Text('Tidak ada pengeluaran'));
    }
    return RefreshWrapper(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pengeluaranList.length,
        itemBuilder: (context, index) {
        final p = pengeluaranList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.deskripsi, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'approve') {
                          _showApproveConfirmationDialog(context, p, onApprove);
                        }
                        if (value == 'disapprove') {
                          _showDisapproveConfirmationDialog(context, p, onDisapprove);
                        }
                        if (value == 'edit') {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) {
                              final deskripsiCtl = TextEditingController(text: p.deskripsi);
                              final hargaCtl = TextEditingController(text: p.harga.toStringAsFixed(0));
                              DateTime selected = p.tanggal;
                              return AlertDialog(
                                title: const Text('Edit Pengeluaran'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buildTextField(deskripsiCtl, 'Deskripsi', Icons.description_outlined, maxLines: 3),
                                    const SizedBox(height: 8),
                                    buildTextField(hargaCtl, 'Harga', Icons.price_check_rounded, keyboardType: TextInputType.number),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: selected,
                                          firstDate: DateTime(2023),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null) selected = picked;
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Tanggal',
                                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        child: Text(DateFormat('d MMMM yyyy').format(selected)),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Batal')),
                                  ElevatedButton(onPressed: () {
                                    final updated = Pengeluaran(
                                      id: p.id,
                                      deskripsi: deskripsiCtl.text,
                                      harga: double.tryParse(hargaCtl.text.replaceAll('.', '')) ?? p.harga,
                                      tanggal: selected,
                                      createdById: p.createdById,
                                      createdByName: p.createdByName,
                                      isApproved: p.isApproved,
                                      approvedById: p.approvedById,
                                      approvedByName: p.approvedByName,
                                      approvedAt: p.approvedAt,
                                    );
                                    onEdit(p, updated);
                                    Navigator.of(dialogCtx).pop();
                                  }, child: const Text('Simpan')),
                                ],
                              );
                            },
                          );
                        }
                        if (value == 'delete') onDelete(p);
                      },
                      itemBuilder: (BuildContext context) => [
                        if (!p.isApproved && currentUser.role == Role.admin) ...[
                          const PopupMenuItem<String>(
                            value: 'approve',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20),
                                SizedBox(width: 12),
                                Text('Approve'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'disapprove',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: AppColors.accentRed, size: 20),
                                SizedBox(width: 12),
                                Text('Reject'),
                              ],
                            ),
                          ),
                        ],
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: AppColors.accentBlue, size: 20),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppColors.accentRed, size: 20),
                              SizedBox(width: 12),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text('Rp ${NumberFormat.decimalPattern('id_ID').format(p.harga)}', style: AppTextStyles.body.copyWith(color: AppColors.accentRed)),
                const SizedBox(height: 6),
                Text('Dibuat oleh: ${p.createdByName}', style: AppTextStyles.body),
                const SizedBox(height: 6),
                Text('Tanggal: ${DateFormat('d MMM yyyy, HH:mm').format(p.tanggal)}', style: AppTextStyles.body),
                if (p.isApproved) ...[
                  const SizedBox(height: 6),
                  Text('Disetujui oleh: ${p.approvedByName ?? p.approvedById}', style: AppTextStyles.body),
                ]
              ],
            ),
          ),
        );
      },
      ),
    );
  }

  void _showApproveConfirmationDialog(BuildContext context, Pengeluaran pengeluaran, Function(Pengeluaran) onApprove) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Approve'),
          content: Text('Apakah Anda yakin ingin menyetujui pengeluaran "${pengeluaran.deskripsi}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Approve', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onApprove(pengeluaran);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDisapproveConfirmationDialog(BuildContext context, Pengeluaran pengeluaran, Function(Pengeluaran) onDisapprove) {
    final isApproved = pengeluaran.isApproved;
    final title = isApproved ? 'Konfirmasi Disapprove' : 'Konfirmasi Reject';
    final message = isApproved 
      ? 'Apakah Anda yakin ingin membatalkan persetujuan pengeluaran "${pengeluaran.deskripsi}"?'
      : 'Apakah Anda yakin ingin menolak pengeluaran "${pengeluaran.deskripsi}"?';
    final buttonText = isApproved ? 'Disapprove' : 'Reject';
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(buttonText, style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDisapprove(pengeluaran);
              },
            ),
          ],
        );
      },
    );
  }
}