// lib/screens/user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan Anda menambahkan intl: ^0.18.1 (atau terbaru) di pubspec.yaml
import '../services/firebase_admin_service.dart';
import '../models/models.dart'; 
import '../theme/app_theme.dart'; 

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  // Helper untuk format tanggal
  String _formatTimestamp(String? isoString) {
    if (isoString == null) return 'Tidak diketahui';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      // Format: 17 Okt 2025, 14:30
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return isoString; // Tampilkan string asli jika format gagal
    }
  }

  // Helper untuk format Role
  String _formatRole(String? roleString) {
    if (roleString == Role.admin.toString()) return 'Admin';
    if (roleString == Role.karyawan.toString()) return 'Karyawan';
    return roleString ?? 'Tidak diketahui';
  }

  // Helper untuk format Status
  Widget _buildStatusChip(bool? isActive) {
    isActive ??= false;
    return Chip(
      label: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: isActive ? AppColors.accentGreen : AppColors.accentRed,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: FirebaseAdminService.instance.getUserDocument(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Pengguna tidak ditemukan'));
          }

          final userData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailTile(
                    context,
                    icon: Icons.person_pin_rounded,
                    title: 'Username',
                    subtitle: userData['username']?.toString() ?? 'N/A',
                  ),
                  _buildDetailTile(
                    context,
                    icon: Icons.email_rounded,
                    title: 'Email',
                    subtitle: userData['email']?.toString() ?? 'N/A',
                  ),
                  _buildDetailTile(
                    context,
                    icon: Icons.security_rounded,
                    title: 'Role',
                    subtitle: _formatRole(userData['role']?.toString()),
                  ),
                  _buildDetailTile(
                    context,
                    icon: Icons.toggle_on_rounded,
                    title: 'Status Akun',
                    customChild: _buildStatusChip(userData['isActive'] as bool?),
                  ),
                  _buildDetailTile(
                    context,
                    icon: Icons.date_range_rounded,
                    title: 'Tanggal Bergabung (createdAt)',
                    subtitle: _formatTimestamp(userData['createdAt'] as String?),
                  ),
                  _buildDetailTile(
                    context,
                    icon: Icons.login_rounded,
                    title: 'Login Terakhir (lastLogin)',
                    subtitle: _formatTimestamp(userData['lastLogin'] as String?),
                    isLast: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? customChild,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Icon(icon, color: AppColors.primary, size: 30),
          title: Text(title, style: AppTextStyles.body.copyWith(fontSize: 14)),
          subtitle: customChild ?? 
              Text(
                subtitle ?? 'N/A', 
                style: AppTextStyles.subtitle.copyWith(fontSize: 18)
              ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}