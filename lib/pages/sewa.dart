import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
// Import tambahan untuk AppTextStyles dan AppColors jika diperlukan
import '../theme/app_theme.dart';

class SewaScreen extends StatelessWidget {
  final List<Sewa> sewaList;
  final Function(Sewa) onDelete;
  final Function(Sewa) onEdit;

  const SewaScreen({
    super.key,
    required this.sewaList,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Sewa')),
      // --- MODIFIKASI TAMPILAN DIMULAI DI SINI ---
      body: sewaList.isEmpty
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
                          color: Colors.black.withAlpha((255 * 0.05).round()), // Bayangan halus
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Agar kartu tidak memanjang
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined, // Ikon yang relevan
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Data Sewa',
                        style: AppTextStyles.subtitle, // Teks lebih tebal
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data sewa baru yang ditambahkan di Pencatatan akan muncul di sini.',
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
              itemCount: sewaList.length,
              itemBuilder: (context, index) {
                final item = sewaList[index];
                return SewaListTile(
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