// lib/pages/dashboard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final int sewaCount;
  final int pesananCount;
  final int stokCount;
  final double totalSaldo;
  // Optional debug counts to compare Firestore vs RTDB
  final int? sewaCountRTDB;
  final int? pesananCountRTDB;
  final VoidCallback onNavigateToSewa;
  final VoidCallback onNavigateToPesanan;
  final VoidCallback onNavigateToStok;
  final VoidCallback onNavigateToDetailSaldo;
  final User currentUser;
  final VoidCallback onLogout;
  final List<Transaksi> transactions;
  final List<User> employees;

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
    required this.transactions,
    required this.employees,
    this.sewaCountRTDB,
    this.pesananCountRTDB,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _selectedMonth;
  int? _selectedYear;
  String? _selectedEmployeeId;
  List<Transaksi> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedEmployeeId = null;
    _runFilter();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.employees != widget.employees) {
      _runFilter();
    }
  }

  void _runFilter() {
    final List<Transaksi> temp = widget.transactions.where((t) {
      final bool yearMatch =
          _selectedYear == null || t.tanggal.year == _selectedYear;
      final bool monthMatch =
          _selectedMonth == null || t.tanggal.month == _selectedMonth;
      // For now, we don't have direct employee id on Transaksi; keep employeeMatch true
      final bool employeeMatch = _selectedEmployeeId == null || true;
      return yearMatch && monthMatch && employeeMatch;
    }).toList();
    temp.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    setState(() {
      _filteredTransactions = temp;
    });
  }

  String timeGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 4 && hour <= 10) return 'Selamat Pagi';
    if (hour >= 11 && hour <= 14) return 'Selamat Siang';
    if (hour >= 15 && hour <= 17) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.currentUser.role == Role.admin;

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
                          widget.onLogout();
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
      body: RefreshWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "${timeGreeting()}, ${widget.currentUser.username}!",
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            const Text(
              "Berikut ringkasan bisnis Anda hari ini.",
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: widget.onNavigateToDetailSaldo,
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
                    ),
                  ],
                ),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${NumberFormat.decimalPattern('id_ID').format(widget.totalSaldo)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ketuk untuk melihat detail  >',
                      style: TextStyle(
                        color: Colors.white.withAlpha((255 * 0.7).round()),
                        fontSize: 12,
                      ),
                    ),
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
                    value: widget.sewaCount.toString(),
                    color: AppColors.accentPink,
                    // Keduanya akan menggunakan callback yang di-pass dari main_screen
                    // Di main_screen, keduanya sudah kita arahkan ke index halaman Data (Index 2)
                    onTap: isAdmin
                        ? widget.onNavigateToStok
                        : widget.onNavigateToSewa,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    icon: Icons.list_alt_rounded,
                    label: 'Total Pesanan',
                    value: widget.pesananCount.toString(),
                    color: AppColors.accentGreen,
                    onTap: isAdmin
                        ? widget.onNavigateToStok
                        : widget.onNavigateToPesanan,
                  ),
                ),
              ],
            ),
            // Debug row: show RTDB counts if provided (visible only in debug builds)
            if (widget.sewaCountRTDB != null ||
                widget.pesananCountRTDB != null) ...[
              const SizedBox(height: 8),
              // Row(
              //   children: [
              //     if (widget.sewaCountRTDB != null)
              //       Expanded(child: Text('Sewa RTDB: ${widget.sewaCountRTDB}', style: AppTextStyles.body.copyWith(fontSize: 12))),
              //     if (widget.pesananCountRTDB != null)
              //       Expanded(child: Text('Pesanan RTDB: ${widget.pesananCountRTDB}', style: AppTextStyles.body.copyWith(fontSize: 12))),
              //   ],
              // ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 24),
            const Text('Aktivitas Terbaru', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1.0),
              ),
              child: _filteredTransactions.isEmpty
                  ? Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Belum ada aktivitas terbaru.',
                          style: AppTextStyles.body,
                        ),
                      ],
                    )
                  : Column(
                      children: _filteredTransactions.take(6).map((t) {
                        final bool isIncome = t.jumlah > 0;
                        final amountColor = isIncome
                            ? AppColors.accentGreen
                            : AppColors.accentRed;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: amountColor.withAlpha(
                              (255 * 0.1).round(),
                            ),
                            child: Icon(
                              isIncome
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: amountColor,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            t.deskripsi,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('d MMM yyyy, HH:mm').format(t.tanggal),
                            style: AppTextStyles.body.copyWith(fontSize: 12),
                          ),
                          trailing: Text(
                            '${isIncome ? '+' : '-'}Rp ${NumberFormat.decimalPattern('id_ID').format(t.jumlah.abs())}',
                            style: AppTextStyles.subtitle.copyWith(
                              color: amountColor,
                            ),
                          ),
                          onTap: widget.onNavigateToDetailSaldo,
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
