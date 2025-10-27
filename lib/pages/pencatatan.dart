// lib/pages/pencatatan.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class PencatatanScreen extends StatefulWidget {
  final Function(Sewa) onConfirmSewa;
  final Function(Pesanan) onConfirmPesanan;
  final Function(int) onNavigateAfterSubmit;
  final User currentUser; // <-- 1. TAMBAHKAN CURRENT USER

  const PencatatanScreen({
    super.key,
    required this.onConfirmSewa,
    required this.onConfirmPesanan,
    required this.onNavigateAfterSubmit,
    required this.currentUser, // <-- 2. TAMBAHKAN DI KONSTRUKTOR
  });

  @override
  State<PencatatanScreen> createState() => _PencatatanScreenState();
}

class _PencatatanScreenState extends State<PencatatanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _sewaFormKey = GlobalKey<FormState>();
  final _pesananFormKey = GlobalKey<FormState>();

  // ... (controller dan state lainnya tidak berubah) ...
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _durasiController = TextEditingController();
  final _noHpController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _hargaController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _selectedPickupDate;
  String? _selectedJaminan;
  SewaStatus? _selectedSewaStatus;

  final List<String> _jaminanOptions = [
    "KTP",
    "SIM",
"Kartu Pelajar",
    "Uang Tunai Rp300.000",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _durasiController.dispose();
    _noHpController.dispose();
    _keteranganController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _pickPickupDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedPickupDate = picked);
    }
  }


  void _submitForm() {
    final isSewaTab = _tabController.index == 0;
    final formKey = isSewaTab ? _sewaFormKey : _pesananFormKey;

    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap lengkapi semua data"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (_keteranganController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi Keterangan Barang."),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final String noHp = _noHpController.text;
    
    // Hapus titik '.' sebelum melakukan parsing
    final double totalHarga = 
        double.tryParse(_hargaController.text.replaceAll('.', '')) ?? 0.0;

    final String keterangan = _keteranganController.text;
    
    // --- 3. AMBIL DATA USER ---
    final String currentUserId = widget.currentUser.id;
    final String currentUserName = widget.currentUser.username;

    if (isSewaTab) {
      // ... (validasi tanggal dan jaminan tidak berubah) ...
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harap pilih tanggal pengembalian."),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }
      if (_selectedJaminan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harap pilih jaminan."),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }

      if (_selectedPickupDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harap pilih tanggal pengambilan."),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }


      final sewaData = Sewa(
        nama: _namaController.text,
        alamat: _alamatController.text,
        noHp: noHp,
        tanggal: _selectedDate!,
        totalHarga: totalHarga, 
        keterangan: keterangan,
        durasi: int.tryParse(_durasiController.text) ?? 0,
        jaminan: _selectedJaminan!,
        status: _selectedSewaStatus ?? SewaStatus.proses,
        // --- 4. MASUKKAN DATA USER KE MODEL ---
        createdById: currentUserId,
        createdByName: currentUserName,
      );
      widget.onConfirmSewa(sewaData);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data sewa berhasil ditambahkan."),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      widget.onNavigateAfterSubmit(2);
    } else {
      if (_selectedPickupDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harap pilih tanggal pengambilan."),
            backgroundColor: AppColors.accentRed,
          ),
        );
        return;
      }
      final pesananData = Pesanan(
        nama: _namaController.text,
        alamat: _alamatController.text,
        noHp: noHp,
        totalHarga: totalHarga, 
        keterangan: keterangan,
        status: PesananStatus.proses,
        // --- 4. MASUKKAN DATA USER KE MODEL ---
        createdById: currentUserId,
        createdByName: currentUserName,
      );
      widget.onConfirmPesanan(pesananData);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data beli berhasil ditambahkan."),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      widget.onNavigateAfterSubmit(3);
    }
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _durasiController.clear();
    _noHpController.clear();
    _keteranganController.clear();
    _hargaController.clear();
    setState(() {
      _selectedDate = null;
      _selectedPickupDate = null;
      _selectedJaminan = null;
      _selectedSewaStatus = null;
    });
  }
  
  // --- (Sisa build method tidak berubah) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pencatatan Baru"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: "Sewa"),
            Tab(text: "Beli"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSewaForm(), _buildPesananForm()],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).round()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: buildGradientButton(
          'Simpan Data',
          Icons.save_rounded,
          _submitForm,
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildSewaForm() {
    return Form(
      key: _sewaFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFormSection(
            title: 'Data Pelanggan',
            child: _buildCommonFields(),
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            title: 'Detail Sewa',
            child: Column(
              children: [
                _buildPickupDatePicker("Tanggal Pengambilan"),
                const SizedBox(height: 16),
                _buildDatePicker("Tanggal Pengembalian Barang"),
                const SizedBox(height: 16),
                _buildJaminanDropdown(),
                const SizedBox(height: 16),
                buildTextField(
                  _keteranganController,
                  'Keterangan Barang',
                  Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  _hargaController,
                  'Total Harga',
                  Icons.price_check_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildSewaStatusDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPesananForm() {
    return Form(
      key: _pesananFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFormSection(
            title: 'Data Pelanggan',
            child: _buildCommonFields(),
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            title: 'Detail Pesanan',
            child: Column(
              children: [
                _buildPickupDatePicker("Tanggal Pengambilan"),
                const SizedBox(height: 16),
                buildTextField(
                  _keteranganController,
                  'Keterangan Barang',
                  Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  _hargaController,
                  'Total Harga',
                  Icons.price_check_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.sync_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  child: const Text(
                    'Proses',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        buildTextField(
          _namaController,
          'Nama Pelanggan',
          Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        buildTextField(_alamatController, 'Alamat', Icons.home_outlined),
        const SizedBox(height: 16),
        buildTextField(
          _noHpController,
          'No. HP',
          Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildJaminanDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedJaminan,
      items: _jaminanOptions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => _selectedJaminan = v),
      decoration: InputDecoration(
        labelText: 'Jaminan',
        prefixIcon: const Icon(Icons.security_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) => v == null ? 'Pilih salah satu jaminan' : null,
    );
  }

  Widget _buildDatePicker(String label) {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedDate == null
              ? 'Pilih Tanggal'
              : DateFormat('d MMMM yyyy').format(_selectedDate!),
          style: TextStyle(
            color: _selectedDate == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPickupDatePicker(String label) {
    return InkWell(
      onTap: _pickPickupDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedPickupDate == null
              ? 'Pilih Tanggal'
              : DateFormat('d MMMM yyyy').format(_selectedPickupDate!),
          style: TextStyle(
            color: _selectedPickupDate == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSewaStatusDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: const Icon(Icons.sync_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      child: const Text(
        'Proses',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}