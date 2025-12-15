// lib/pages/laporan_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class LaporanScreen extends StatefulWidget {
  final List<Sewa> sewaList;
  final List<Pesanan> pesananList;
  final List<Pengeluaran> pengeluaranList;
  final List<User> employees;
  final User currentUser;
  final Function(Pengeluaran) onApprovePengeluaran;
  final Function(Pengeluaran) onDisapprovePengeluaran;
  final Function(Pengeluaran) onAddPengeluaran;

  const LaporanScreen({
    super.key,
    required this.sewaList,
    required this.pesananList,
    required this.pengeluaranList,
    required this.employees,
    required this.currentUser,
    required this.onApprovePengeluaran,
    required this.onDisapprovePengeluaran,
    required this.onAddPengeluaran,
  });

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedMonth;
  int? _selectedYear;
  String? _selectedEmployeeId;
  List<int> _availableYears = [];

  List<Sewa> _filteredSewaList = [];
  List<Pesanan> _filteredPesananList = [];
  List<Pengeluaran> _filteredPengeluaranList = [];
  double _totalOmset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _runFilter();
    final isAdmin = widget.currentUser.role == Role.admin;
    final tabCount = isAdmin ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(LaporanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild when employees list changes
    if (oldWidget.employees != widget.employees ||
        oldWidget.sewaList != widget.sewaList ||
        oldWidget.pesananList != widget.pesananList ||
        oldWidget.pengeluaranList != widget.pengeluaranList) {
      _runFilter();
    }
    // If admin status changed, recreate controller with new length
    final oldTabCount = oldWidget.currentUser.role == Role.admin ? 3 : 2;
    final newTabCount = widget.currentUser.role == Role.admin ? 3 : 2;
    if (oldTabCount != newTabCount) {
      _tabController.removeListener(() {});
      _tabController.dispose();
      _tabController = TabController(length: newTabCount, vsync: this);
      _tabController.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      final bool employeeMatch = _selectedEmployeeId == null ||
          sewa.createdById == _selectedEmployeeId;
      
      return yearMatch && monthMatch && employeeMatch;
    }).toList();

    // Filter Pesanan
    List<Pesanan> tempPesanan = widget.pesananList.where((pesanan) {
      final bool yearMatch = _selectedYear == null ||
          pesanan.tanggalDibuat.year == _selectedYear;
      final bool monthMatch = _selectedMonth == null ||
          pesanan.tanggalDibuat.month == _selectedMonth;
      final bool employeeMatch = _selectedEmployeeId == null ||
          pesanan.createdById == _selectedEmployeeId;

      return yearMatch && monthMatch && employeeMatch;
    }).toList();

    // Filter Pengeluaran
    List<Pengeluaran> tempPengeluaran = widget.pengeluaranList.where((pengeluaran) {
      final bool yearMatch = _selectedYear == null ||
          pengeluaran.tanggal.year == _selectedYear;
      final bool monthMatch = _selectedMonth == null ||
          pengeluaran.tanggal.month == _selectedMonth;
      final bool employeeMatch = _selectedEmployeeId == null ||
          pengeluaran.createdById == _selectedEmployeeId;

      return yearMatch && monthMatch && employeeMatch;
    }).toList();

    // Hitung total omset: semua sewa + pesanan - pengeluaran (hanya yang disetujui)
    double omsetSewa =
      tempSewa.fold(0.0, (sum, item) => sum + item.totalHarga);
    double omsetPesanan =
      tempPesanan.fold(0.0, (sum, item) => sum + item.totalHarga);
    // Hanya kurangi pengeluaran yang sudah disetujui
    double approvedPengeluaran = tempPengeluaran
      .where((p) => p.isApproved)
      .fold(0.0, (sum, p) => sum + p.harga);

    setState(() {
      _filteredSewaList = tempSewa;
      _filteredPesananList = tempPesanan;
      _filteredPengeluaranList = tempPengeluaran;
      _totalOmset = omsetSewa + omsetPesanan - approvedPengeluaran;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser.role == Role.admin;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: "Data Sewa"),
            const Tab(text: "Data Pesanan"),
            if (isAdmin) const Tab(text: "Pengeluaran"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildSummarySection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSewaList(),
                _buildPesananList(),
                if (isAdmin) _buildPengeluaranList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin && _tabController.index == 2
          ? FloatingActionButton(
              onPressed: _showAddPengeluaranDialog,
              tooltip: 'Tambah Pengeluaran (Auto-approve)',
              child: const Icon(Icons.add),
            )
          : null,
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
    return RefreshWrapper(
      child: ListView.builder(
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
      ),
    );
  }

  Widget _buildPesananList() {
    if (_filteredPesananList.isEmpty) {
      return const EmptyStateWidget(
        message: "Tidak ada data pesanan pada periode ini.",
        icon: Icons.search_off_rounded,
      );
    }
    return RefreshWrapper(
      child: ListView.builder(
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
      ),
    );
  }

  Widget _buildPengeluaranList() {
    if (_filteredPengeluaranList.isEmpty) {
      return const EmptyStateWidget(
        message: "Tidak ada data pengeluaran pada periode ini.",
        icon: Icons.search_off_rounded,
      );
    }
    return RefreshWrapper(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPengeluaranList.length,
        itemBuilder: (context, index) {
          final item = _filteredPengeluaranList[index];
          return _buildPengeluaranListTile(item);
        },
      ),
    );
  }

  Widget _buildPengeluaranListTile(Pengeluaran pengeluaran) {
    final bool isAdmin = widget.currentUser.role == Role.admin;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pengeluaran.deskripsi,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp ${NumberFormat.decimalPattern('id_ID').format(pengeluaran.harga)}",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin && !pengeluaran.isApproved) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 24, color: Colors.green),
                    onPressed: () => _showApproveConfirmationDialog(pengeluaran),
                    tooltip: 'Setujui',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, size: 24, color: Colors.red),
                    onPressed: () => _showDisapproveConfirmationDialog(pengeluaran),
                    tooltip: 'Tolak',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('d MMM yyyy, HH:mm').format(pengeluaran.tanggal),
              style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              "Dibuat oleh: ${pengeluaran.createdByName}",
              style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textSecondary),
            ),
            if (pengeluaran.isApproved) ...[
              const SizedBox(height: 4),
              Text(
                "Disetujui oleh: ${pengeluaran.approvedByName ?? pengeluaran.approvedById} pada ${DateFormat('d MMM yyyy, HH:mm').format(pengeluaran.approvedAt ?? pengeluaran.tanggal)}",
                style: AppTextStyles.body.copyWith(fontSize: 12, color: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddPengeluaranDialog() {
    final formKey = GlobalKey<FormState>();
    final deskripsiController = TextEditingController();
    final hargaController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Pengeluaran (Auto-approve)'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTextField(deskripsiController, 'Deskripsi', Icons.description_outlined, maxLines: 3),
                  const SizedBox(height: 12),
                  buildTextField(hargaController, 'Harga', Icons.price_check_rounded, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      child: Text(DateFormat('d MMMM yyyy').format(selectedDate)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Batal')),
              ElevatedButton(onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final double hargaParsed = double.tryParse(hargaController.text.replaceAll('.', '')) ?? 0.0;
                final pengeluaran = Pengeluaran(
                  deskripsi: deskripsiController.text,
                  harga: hargaParsed,
                  tanggal: selectedDate,
                  createdById: widget.currentUser.id,
                  createdByName: widget.currentUser.username,
                  isApproved: true,
                  approvedById: widget.currentUser.id,
                  approvedByName: widget.currentUser.username,
                  approvedAt: DateTime.now().toUtc(),
                );
                widget.onAddPengeluaran(pengeluaran);
                Navigator.of(dialogCtx).pop();
              }, child: const Text('Tambah')),
            ],
          );
        });
      },
    );
  }

  void _showApproveConfirmationDialog(Pengeluaran pengeluaran) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Approve'),
          content: Text('Apakah Anda yakin ingin menyetujui pengeluaran "${pengeluaran.deskripsi}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Approve', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onApprovePengeluaran(pengeluaran);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDisapproveConfirmationDialog(Pengeluaran pengeluaran) {
    final isApproved = pengeluaran.isApproved;
    final title = isApproved ? 'Konfirmasi Disapprove' : 'Konfirmasi Reject';
    final message = isApproved 
      ? 'Apakah Anda yakin ingin membatalkan persetujuan pengeluaran "${pengeluaran.deskripsi}"?'
      : 'Apakah Anda yakin ingin menolak pengeluaran "${pengeluaran.deskripsi}"?';
    final buttonText = isApproved ? 'Disapprove' : 'Reject';
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(buttonText, style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onDisapprovePengeluaran(pengeluaran);
              },
            ),
          ],
        );
      },
    );
  }
}