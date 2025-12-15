// lib/pages/sewa.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class SewaListContent extends StatelessWidget { // Ganti nama class agar lebih sesuai
  final List<Sewa> sewaList;
  final Function(Sewa) onDelete;
  final Function(Sewa) onEdit;

  const SewaListContent({
    super.key,
    required this.sewaList,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // LANGSUNG RETURN KONTEN UTAMA (TANPA SCAFFOLD/APPBAR)
    if (sewaList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.05).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Data Sewa',
                  style: AppTextStyles.subtitle,
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
      );
    }

    return RefreshWrapper(
      child: ListView.builder(
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
    );
  }
}