import 'package:flutter/material.dart';
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
        )
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
  // TAMBAHKAN parameter opsional di sini
  bool isObscure = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField( // Ubah dari TextField ke TextFormField agar bisa pakai validator
    controller: controller,
    obscureText: isObscure, // Gunakan parameter isObscure
    keyboardType: keyboardType, // Gunakan parameter keyboardType
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
    validator: validator ?? (value) { // Gunakan parameter validator
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
  );
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyStateWidget({super.key, required this.message, required this.icon});

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

class SewaListTile extends StatelessWidget {
  final Sewa item;
  final VoidCallback onDelete;

  const SewaListTile({super.key, required this.item, required this.onDelete});

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
                Text(item.nama, style: AppTextStyles.subtitle),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...item.items.map((orderItem) => Text('• ${orderItem.namaBarang} (x${orderItem.jumlah})', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary))),
            const Divider(height: 24),
            InfoRow(icon: Icons.calendar_today_outlined, text: DateFormat('d MMM yyyy').format(item.tanggal)),
            InfoRow(icon: Icons.timer_outlined, text: "${item.durasi} hari"),
            InfoRow(icon: Icons.security_outlined, text: "Jaminan: ${item.jaminan}"),
          ],
        ),
      ),
    );
  }
}

class PesananListTile extends StatelessWidget {
  final Pesanan item;
  final VoidCallback onDelete;

  const PesananListTile({super.key, required this.item, required this.onDelete});

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
                Text(item.nama, style: AppTextStyles.subtitle),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...item.items.map((orderItem) => Text('• ${orderItem.namaBarang} (x${orderItem.jumlah})', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary))),
            const Divider(height: 24),
            InfoRow(icon: Icons.calendar_today_outlined, text: DateFormat('d MMM yyyy').format(item.tanggal)),
            InfoRow(icon: Icons.location_on_outlined, text: item.alamat),
          ],
        ),
      ),
    );
  }
}

class StokListTile extends StatelessWidget {
  final StokItem item;
  final VoidCallback onEdit;
  final VoidCallback onRestock;

  const StokListTile({super.key, required this.item, required this.onEdit, required this.onRestock});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.grey.withAlpha((0.1 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withAlpha((0.1 * 255).round()),
              child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama, style: AppTextStyles.subtitle),
                  Text("Sisa: ${item.jumlah} unit", style: AppTextStyles.body),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'restock') {
                  onRestock();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit')),
                ),
                const PopupMenuItem<String>(
                  value: 'restock',
                  child: ListTile(leading: Icon(Icons.add_shopping_cart_rounded), title: Text('Restock')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

  Widget buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  TextInputType? keyboardType,
  bool isObscure = false,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: isObscure,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
    validator: validator ?? (value) {
      if (value == null || value.isEmpty) {
        return '$label tidak boleh kosong';
      }
      return null;
    },
  );
}

Widget buildGradientButton(String text, IconData icon, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.button),
        ],
      ),
    ),
  );
}

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
                        Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(value, style: AppTextStyles.heading2),
                      ],
                    ),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 12),
                  Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.heading2),
                ],
              ),
      ),
    );
  }
}
