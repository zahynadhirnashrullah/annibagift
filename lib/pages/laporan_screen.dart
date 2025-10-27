// lib/pages/laporan_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class LaporanScreen extends StatefulWidget {
  final List<Sewa> sewaList;
  final List<Pesanan> pesananList;
  final List<User> employees; // <-- 1. TERIMA DAFTAR KARYAWAN

  const LaporanScreen({
    super.key,
    required this.sewaList,
    required this.pesananList,
    required this.employees, // <-- 2. TAMBAHKAN DI KONSTRUKTOR
  });

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  int? _selectedMonth;
  int? _selectedYear;
  String? _selectedEmployeeId; // <-- 3. STATE UNTUK FILTER KARYAWAN
  List<int> _availableYears = [];

  List<Sewa> _filteredSewaList = [];
  List<Pesanan> _filteredPesananList = [];
  double _totalOmset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _runFilter();
  }

  void _initializeFilters() {
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedEmployeeId = null; // Default: Tampilkan semua

    final int currentYear = now.year;
    _availableYears =
        List<int>.generate(currentYear - 2022, (index) => 2023 + index);
  }

  void _runFilter() {
    // Filter Sewa
    List<Sewa> tempSewa = widget.sewaList.where((sewa) {
      final bool yearMatch =
          _selectedYear == null || sewa.tanggalDibuat.year == _selectedYear;
      final bool monthMatch = _selectedMonth == null ||
          sewa.tanggalDibuat.month == _selectedMonth;
      // --- 4. LOGIKA FILTER KARYAWAN ---
      final bool employeeMatch = _selectedEmployeeId == null ||
          sewa.createdById == _selectedEmployeeId;
      
      return yearMatch && monthMatch && employeeMatch; // <-- 5. TAMBAHKAN
    }).toList();

    // Filter Pesanan
    List<Pesanan> tempPesanan = widget.pesananList.where((pesanan) {
      final bool yearMatch = _selectedYear == null ||
          pesanan.tanggalDibuat.year == _selectedYear;
      final bool monthMatch = _selectedMonth == null ||
          pesanan.tanggalDibuat.month == _selectedMonth;
      // --- 4. LOGIKA FILTER KARYAWAN ---
      final bool employeeMatch = _selectedEmployeeId == null ||
          pesanan.createdById == _selectedEmployeeId;

      return yearMatch && monthMatch && employeeMatch; // <-- 5. TAMBAHKAN
    }).toList();

    // Hitung total omset
    double omsetSewa =
        tempSewa.fold(0.0, (sum, item) => sum + item.totalHarga);
    double omsetPesanan =
        tempPesanan.fold(0.0, (sum, item) => sum + item.totalHarga);

    setState(() {
      _filteredSewaList = tempSewa;
      _filteredPesananList = tempPesanan;
      _totalOmset = omsetSewa + omsetPesanan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Laporan Penjualan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Data Sewa"),
              Tab(text: "Data Pesanan"),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            _buildSummarySection(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSewaList(),
                  _buildPesananList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColors.background,
      child: Column(
        children: [
          Row(
            children: [
              // Filter Bulan
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Bulan',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Semua Bulan")),
                    ...List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(DateFormat('MMMM', 'id_ID').format(DateTime(0, index + 1))),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedMonth = value);
                    _runFilter();
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Filter Tahun
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Tahun',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Semua")),
                    ..._availableYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedYear = value);
                    _runFilter();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Jarak
          // --- 6. TAMBAHKAN DROPDOWN KARYAWAN ---
          DropdownButtonFormField<String>(
            initialValue: _selectedEmployeeId,
            decoration: const InputDecoration(
              labelText: 'Filter per Karyawan',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text("Semua Karyawan")),
              ...widget.employees.map((User user) {
                return DropdownMenuItem(
                  value: user.id,
                  child: Text(user.username),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedEmployeeId = value);
              _runFilter();
            },
          ),
        ],
      ),
    );
  }
  
  // ... (Sisa LaporanScreen tidak berubah) ...

  Widget _buildSummarySection() {
    final formatCurrency = NumberFormat.decimalPattern('id_ID');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.receipt_long_rounded,
              label: 'Total Omset',
              value: "Rp ${formatCurrency.format(_totalOmset)}",
              color: AppColors.primary,
              onTap: () {}, // Tidak perlu aksi
              isFullWidth: true,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                _filteredSewaList.length.toString(),
                style: AppTextStyles.heading2.copyWith(color: AppColors.accentPink),
              ),
              const Text("Sewa", style: AppTextStyles.body),
              const SizedBox(height: 8),
              Text(
                _filteredPesananList.length.toString(),
                style: AppTextStyles.heading2.copyWith(color: AppColors.accentGreen),
              ),
              const Text("Pesanan", style: AppTextStyles.body),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSewaList() {
    if (_filteredSewaList.isEmpty) {
      return const EmptyStateWidget(
        message: "Tidak ada data sewa pada periode ini.",
        icon: Icons.search_off_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSewaList.length,
      itemBuilder: (context, index) {
        final item = _filteredSewaList[index];
        return SewaListTile(
          item: item,
          onDelete: null,
          onEdit: null, 
        );
      },
    );
  }

  Widget _buildPesananList() {
    if (_filteredPesananList.isEmpty) {
      return const EmptyStateWidget(
        message: "Tidak ada data pesanan pada periode ini.",
        icon: Icons.search_off_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPesananList.length,
      itemBuilder: (context, index) {
        final item = _filteredPesananList[index];
        return PesananListTile(
          item: item,
          onDelete: null,
          onEdit: null,
        );
      },
    );
  }
}