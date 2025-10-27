// lib/screens/detail_saldo_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Naik satu level saja
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DetailSaldoScreen extends StatefulWidget {
  final List<Transaksi> transactions;
  final List<Pengeluaran>
      pengeluaranListAsli; 
  final Function(Pengeluaran) onAddPengeluaran;
  final Function(Pengeluaran, Pengeluaran) onEditPengeluaran;
  final Function(Pengeluaran) onDeletePengeluaran;
  // --- 1. TAMBAHKAN CURRENT USER ---
  final User currentUser;
  // --- AKHIR TAMBAHAN ---

  const DetailSaldoScreen({
    super.key,
    required this.transactions,
    required this.pengeluaranListAsli,
    required this.onAddPengeluaran,
    required this.onEditPengeluaran,
    required this.onDeletePengeluaran,
    // --- 2. TAMBAHKAN DI KONSTRUKTOR ---
    required this.currentUser,
    // --- AKHIR TAMBAHAN ---
  });

  @override
  State<DetailSaldoScreen> createState() => _DetailSaldoScreenState();
}

class _DetailSaldoScreenState extends State<DetailSaldoScreen> {
  String _filterType = 'Semua'; 
  List<Transaksi> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filterTransactions();
  }

  @override
  void didUpdateWidget(DetailSaldoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactions != oldWidget.transactions) {
      _filterTransactions();
    }
  }

  void _filterTransactions() {
    // ... (Logika filter tidak berubah) ...
    final now = DateTime.now();
    setState(() {
      switch (_filterType) {
        case 'Bulan Ini':
          _filteredTransactions = widget.transactions
              .where((t) =>
                  t.tanggal.month == now.month && t.tanggal.year == now.year)
              .toList();
          break;
        case 'Tahun Ini':
          _filteredTransactions =
              widget.transactions.where((t) => t.tanggal.year == now.year).toList();
          break;
        case 'Semua':
        default:
          _filteredTransactions = List.from(widget.transactions);
          break;
      }
      _filteredTransactions.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    });
  }

  double _calculateFilteredTotal() {
    if (_filteredTransactions.isEmpty) return 0;
    return _filteredTransactions.fold(
        0.0, (sum, item) => sum + item.jumlah);
  }

  Pengeluaran? _findPengeluaranById(String id) {
    try {
      return widget.pengeluaranListAsli.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void _showPengeluaranDialog({Pengeluaran? pengeluaran}) {
    final formKey = GlobalKey<FormState>();
    final deskripsiController =
        TextEditingController(text: pengeluaran?.deskripsi);
    
    final String hargaAwal = pengeluaran?.harga != null
        ? NumberFormat('#,###', 'id_ID').format(pengeluaran!.harga)
        : '';
    final hargaController = TextEditingController(text: hargaAwal);
    
    DateTime selectedDate = pengeluaran?.tanggal ?? DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) { 
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                  pengeluaran == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextField(
                      deskripsiController,
                      'Deskripsi',
                      Icons.description_outlined,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      hargaController,
                      'Harga', 
                      Icons.price_change_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tanggal',
                          prefixIcon:
                              const Icon(Icons.calendar_today_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Text(
                          DateFormat('d MMMM yyyy').format(selectedDate),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      
                      final double hargaParsed = 
                          double.tryParse(hargaController.text.replaceAll('.', '')) ?? 0.0;
                      
                      // --- 3. PERUBAHAN PENTING DI SINI ---
                      final newPengeluaran = Pengeluaran(
                        id: pengeluaran?.id, // Null jika baru, ada nilai jika edit
                        deskripsi: deskripsiController.text,
                        harga: hargaParsed,
                        tanggal: selectedDate,
                        
                        // Jika 'pengeluaran' ada (edit), gunakan ID & nama lamanya
                        // Jika 'pengeluaran' null (baru), gunakan ID & nama user saat ini
                        createdById: pengeluaran?.createdById ?? widget.currentUser.id,
                        createdByName: pengeluaran?.createdByName ?? widget.currentUser.username,
                      );
                      // --- AKHIR PERUBAHAN ---

                      if (pengeluaran == null) {
                        widget.onAddPengeluaran(newPengeluaran);
                      } else {
                        widget.onEditPengeluaran(pengeluaran, newPengeluaran);
                      }
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(Pengeluaran pengeluaran) {
    // --- 4. PENGECEKAN HAK AKSES (OPSIONAL TAPI DISARANKAN) ---
    // Hanya Admin atau pemilik data yang boleh menghapus
    bool canDelete = widget.currentUser.role == Role.admin ||
                     pengeluaran.createdById == widget.currentUser.id;

    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anda tidak memiliki izin untuk menghapus data ini."),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }
    // --- AKHIR PENGECEKAN ---
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
      content:
                    Text('Anda yakin ingin menghapus "${pengeluaran.deskripsi}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.accentRed)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onDeletePengeluaran(pengeluaran);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Sisa build method tidak berubah) ...
    final filteredTotal = _calculateFilteredTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Saldo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total ($_filterType)",
                      style: AppTextStyles.heading2,
                    ),
                    DropdownButton<String>(
                      value: _filterType,
                      items: ['Semua', 'Bulan Ini', 'Tahun Ini']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _filterType = newValue);
                          _filterTransactions();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp ${NumberFormat.decimalPattern('id_ID').format(filteredTotal)}",
                  style: AppTextStyles.heading1.copyWith(
                    color: filteredTotal >= 0
                        ? AppColors.accentGreen
                        : AppColors.accentRed,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const EmptyStateWidget(
                    message: 'Tidak ada transaksi',
                    icon: Icons.receipt_long_outlined,
                  )
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = _filteredTransactions[index];
                      // --- 5. PENGECEKAN HAK AKSES EDIT (OPSIONAL) ---
                      // Cek data pengeluaran asli
                      Pengeluaran? p = (tx.tipe == TipeTransaksi.pengeluaran) 
                                       ? _findPengeluaranById(tx.referensiId) 
                                       : null;
                      
                      // Hanya tampilkan tombol jika data pengeluaran ada
                      // Dan user adalah Admin ATAU pemilik data
                      bool showButtons = p != null && 
                                        (widget.currentUser.role == Role.admin || 
                                         p.createdById == widget.currentUser.id);
                                         
                      return TransaksiListTile(
                        transaksi: tx,
                        onEdit: showButtons
                            ? () => _showPengeluaranDialog(pengeluaran: p)
                            : null,
                        onDelete: showButtons
                            ? () => _showDeleteConfirmDialog(p)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPengeluaranDialog(),
        icon: const Icon(Icons.remove_rounded),
        label: const Text('Pengeluaran'),
        backgroundColor: AppColors.accentRed,
      ),
    );
  }
}

// ... (Widget TransaksiListTile tidak berubah) ...
class TransaksiListTile extends StatelessWidget {
  final Transaksi transaksi;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransaksiListTile({
    super.key,
    required this.transaksi,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaksi.jumlah > 0;
    final Color amountColor =
        isIncome ? AppColors.accentGreen : AppColors.accentRed;
    final IconData iconData = isIncome
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    final formattedAmount =
        "Rp ${NumberFormat.decimalPattern('id_ID').format(transaksi.jumlah.abs())}";
    final prefix = isIncome ? '+' : '-';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: amountColor.withAlpha((255 * 0.1).round()),
        child: Icon(iconData, color: amountColor, size: 20),
      ),
      title: Text(
        transaksi.deskripsi,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat('d MMM yyyy, HH:mm').format(transaksi.tanggal),
        style: AppTextStyles.body.copyWith(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$prefix$formattedAmount", 
            style: AppTextStyles.subtitle.copyWith(color: amountColor),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.accentRed, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}