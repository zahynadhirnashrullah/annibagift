// lib/widgets/shared_widgets.dart

import 'package:flutter/material.dart'; // <--- PASTIKAN INI ADA
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

Widget buildGradientButton(String text, IconData icon, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withAlpha((0.3 * 255).round()),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: AppTextStyles.button),
      onPressed: onPressed,
    ),
  );
}

Widget buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  bool isObscure = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  bool readOnly = false,
  int maxLines = 1,
}) {
  // For price formatting
  List<TextInputFormatter>? formatters;

  // Pastikan label 'Harga' (dari detail_saldo) juga mendapatkan formatting
  if (label == 'Total Harga' || label == 'Harga') {
    formatters = [
      FilteringTextInputFormatter.digitsOnly,
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text.isEmpty) {
          return newValue;
        }
        // newValue.text sudah dijamin hanya angka (digitsOnly)
        final int? value = int.tryParse(newValue.text);
        if (value != null) {
          final formatter = NumberFormat('#,###', 'id_ID');
          final String formatted = formatter.format(value);
          return TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
        return oldValue;
      }),
    ];
  }

  return TextFormField(
    controller: controller,
    obscureText: isObscure,
    keyboardType: keyboardType,
    readOnly: readOnly,
    maxLines: maxLines,
    inputFormatters: formatters,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
    validator:
        validator ??
        (value) {
          if (value == null || value.isEmpty) {
            // Validasi khusus untuk harga dan durasi agar bisa 0
            // Tambahkan 'Harga' ke validasi khusus
            if (label == 'Total Harga' || label.contains('Durasi') || label == 'Harga') {
              if (value != null &&
                  value.isNotEmpty &&
                  double.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              return null; // Boleh kosong atau 0
            }
            return '$label tidak boleh kosong';
          }
          return null;
        },
  );
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.body.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

// === PERUBAHAN PENTING DI SINI ===

class SewaListTile extends StatelessWidget {
  final Sewa item;
  final VoidCallback? onDelete; // <-- DIBUAT NULLABLE
  final VoidCallback? onEdit; // <-- DIBUAT NULLABLE

  const SewaListTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.grey.withAlpha((0.1 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.nama, style: AppTextStyles.subtitle),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (BuildContext context) => [
                    if (onEdit != null)
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
                    if (onDelete != null)
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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.keterangan,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            InfoRow(icon: Icons.phone_outlined, text: item.noHp),
            InfoRow(
              icon: Icons.receipt_long_outlined,
              text:
                  "Rp ${NumberFormat.decimalPattern('id_ID').format(item.totalHarga)}",
            ),
            InfoRow(
              icon: Icons.calendar_today_outlined,
              text: "Kembali: ${DateFormat('d MMM yyyy').format(item.tanggal)}",
            ),
            InfoRow(
              icon: Icons.security_outlined,
              text: "Jaminan: ${item.jaminan}",
            ),
          ],
        ),
      ),
    );
  }
}

class PesananListTile extends StatelessWidget {
  final Pesanan item;
  final VoidCallback? onDelete; // <-- DIBUAT NULLABLE
  final VoidCallback? onEdit; // <-- DIBUAT NULLABLE

  const PesananListTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.grey.withAlpha((0.1 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.nama, style: AppTextStyles.subtitle),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (BuildContext context) => [
                    if (onEdit != null)
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
                    if (onDelete != null)
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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.keterangan,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            InfoRow(icon: Icons.phone_outlined, text: item.noHp),
            InfoRow(icon: Icons.location_on_outlined, text: item.alamat),
            InfoRow(
              icon: Icons.receipt_long_outlined,
              text:
                  "Rp ${NumberFormat.decimalPattern('id_ID').format(item.totalHarga)}",
            ),
          ],
        ),
      ),
    );
  }
}

// (StokListTile dan StatCard tidak berubah)

// StokListTile has been removed

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isFullWidth
            ? Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(value, style: AppTextStyles.heading2),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.heading2),
                ],
              ),
      ),
    );
  }
}

/// A small helper that wraps a scrollable child with a [RefreshIndicator].
///
/// If [onRefresh] is null the indicator will perform a short noop delay so
/// the pull-to-refresh gesture still provides feedback even if no remote
/// reload logic is supplied by the page.
class RefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;

  const RefreshWrapper({super.key, required this.child, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? (() async => await Future.delayed(const Duration(milliseconds: 500))),
      child: child,
    );
  }
}