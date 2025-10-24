// lib/pages/dashboard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final int sewaCount;
  final int pesananCount;
  final int stokCount;
  final double totalSaldo;
  final VoidCallback onNavigateToSewa;
  final VoidCallback onNavigateToPesanan;
  final VoidCallback onNavigateToStok;
  final VoidCallback onNavigateToDetailSaldo;
  final User currentUser;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.sewaCount,
    required this.pesananCount,
    required this.stokCount,
    required this.totalSaldo,
    required this.onNavigateToSewa,
    required this.onNavigateToPesanan,
    required this.onNavigateToStok,
    required this.onNavigateToDetailSaldo,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin logout?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'Tidak',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Ya, Logout',
                          style: TextStyle(color: AppColors.accentRed),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          onLogout();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Selamat Datang, ${currentUser.username}!",
              style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          const Text("Berikut ringkasan bisnis Anda hari ini.",
              style: AppTextStyles.body),
          const SizedBox(height: 24),
          InkWell(
            onTap: onNavigateToDetailSaldo,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha((255 * 0.3).round()),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Saldo",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white70,
                        size: 20,
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp ${NumberFormat.decimalPattern('id_ID').format(totalSaldo)}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ketuk untuk melihat detail  >',
                    style: TextStyle(
                      color: Colors.white.withAlpha((255 * 0.7).round()),
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: StatCard(
                icon: Icons.shopping_cart_checkout_rounded,
                label: 'Sewa Aktif',
                value: sewaCount.toString(),
                color: AppColors.accentPink,
                onTap: onNavigateToSewa,
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: StatCard(
                icon: Icons.list_alt_rounded,
                label: 'Total Pesanan',
                value: pesananCount.toString(),
                color: AppColors.accentGreen,
                onTap: onNavigateToPesanan,
              )),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          const Text('Aktivitas Terbaru', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada aktivitas terbaru.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Data sewa atau pesanan baru akan muncul di sini.',
                  style:
                      AppTextStyles.body.copyWith(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}