import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
// Import tambahan untuk AppTextStyles dan AppColors
import '../theme/app_theme.dart';

class PemesananScreen extends StatelessWidget {
  final List<Pesanan> pesananList;
  final Function(Pesanan) onDelete;
  final Function(Pesanan) onEdit;

  const PemesananScreen({
    super.key,
    required this.pesananList,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Pemesanan')),
      // --- MODIFIKASI TAMPILAN DIMULAI DI SINI ---
      body: pesananList.isEmpty
          // JIKA KOSONG: Tampilkan "Kartu Empty State" yang didesain
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white, // Latar belakang kartu
                    borderRadius: BorderRadius.circular(16), // Sudut membulat
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), // Bayangan halus
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Agar kartu tidak memanjang
                    children: [
                      Icon(
                        Icons.list_alt_outlined, // Ikon yang relevan
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Data Pesanan',
                        style: AppTextStyles.subtitle, // Teks lebih tebal
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data pesanan (beli) baru yang ditambahkan di Pencatatan akan muncul di sini.',
                        style: AppTextStyles.body.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          // JIKA ISI: Tampilkan ListView seperti biasa
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final item = pesananList[index];
                return PesananListTile(
                  item: item,
                  onDelete: () => onDelete(item),
                  onEdit: () => onEdit(item),
                );
              },
            ),
      // --- MODIFIKASI TAMPILAN SELESAI DI SINI ---
    );
  }
}