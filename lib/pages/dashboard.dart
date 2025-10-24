import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final int sewaCount;
  final int pesananCount;
  final VoidCallback onNavigateToSewa;
  final VoidCallback onNavigateToPesanan;
  final User currentUser;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.sewaCount,
    required this.pesananCount,
    required this.onNavigateToSewa,
    required this.onNavigateToPesanan,
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
            // <-- MODIFIKASI DIMULAI DI SINI
            onPressed: () {
              // Menampilkan dialog konfirmasi
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
                      // Tombol "Tidak"
                      TextButton(
                        child: const Text(
                          'Tidak',
                          style: TextStyle(color: AppColors.primary), // Sesuaikan dengan theme Anda
                        ),
                        onPressed: () {
                          // Tutup dialog
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      // Tombol "Ya"
                      TextButton(
                        child: const Text(
                          'Ya, Logout',
                          style: TextStyle(color: AppColors.accentRed), // Memberi warna merah untuk aksi
                        ),
                        onPressed: () {
                          // 1. Tutup dialog
                          Navigator.of(dialogContext).pop();
                          // 2. Jalankan fungsi logout asli
                          onLogout();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            // <-- MODIFIKASI SELESAI DI SINI
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

          // --- KODE UI LAMA ANDA ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha((0.3 * 255).round()),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Saldo",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                const Text("Rp 12.500.000",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 2), FlSpot(1, 2.5), FlSpot(2, 1.8),
                            FlSpot(3, 3.5), FlSpot(4, 2.8), FlSpot(5, 4),
                          ],
                          isCurved: true,
                          color: Colors.white,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
          const Text('Aktivitas Terbaru', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          const Center(
            child:
                Text('Belum ada aktivitas terbaru.', style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}