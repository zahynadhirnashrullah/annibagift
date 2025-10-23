// pencatatan.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class PencatatanScreen extends StatefulWidget {
  final Function(Sewa) onConfirmSewa;
  final Function(Pesanan) onConfirmPesanan;
  final Function(int) onNavigateAfterSubmit;

  const PencatatanScreen({
    super.key,
    required this.onConfirmSewa,
    required this.onConfirmPesanan,
    required this.onNavigateAfterSubmit,
  });

  @override
  State<PencatatanScreen> createState() => _PencatatanScreenState();
}

class _PencatatanScreenState extends State<PencatatanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _sewaFormKey = GlobalKey<FormState>();
  final _pesananFormKey = GlobalKey<FormState>();

  // Controller
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _durasiController = TextEditingController();
  final _noHpController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _hargaController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedJaminan;

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

  void _submitForm() {
    final isSewaTab = _tabController.index == 0;
    final formKey = isSewaTab ? _sewaFormKey : _pesananFormKey;

    // --- Validasi ---
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap lengkapi semua data"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    // --- PERUBAHAN: Validasi field Keterangan ---
    if (_keteranganController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi Keterangan Barang."),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }
    // --- End Validasi ---

    // Ambil data umum
    final String noHp = _noHpController.text;
    final double totalHarga = double.tryParse(_hargaController.text) ?? 0.0;
    final String keterangan =
        _keteranganController.text; // <-- Data diambil dari sini

    if (isSewaTab) {
      // --- Validasi Khusus Sewa ---
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
      // --- End Validasi Sewa ---

      final sewaData = Sewa(
        nama: _namaController.text,
        alamat: _alamatController.text,
        noHp: noHp,
        tanggal: _selectedDate!,
        totalHarga: totalHarga,
        keterangan: keterangan, // <-- PERUBAHAN: Mengisi data keterangan
        // 'namaBarang' sudah dihapus dari model
        durasi: int.tryParse(_durasiController.text) ?? 0,
        jaminan: _selectedJaminan!,
      );
      widget.onConfirmSewa(sewaData);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data sewa berhasil ditambahkan."),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      widget.onNavigateAfterSubmit(3);
    } else {
      // --- Tab Beli ---
      final pesananData = Pesanan(
        nama: _namaController.text,
        alamat: _alamatController.text,
        noHp: noHp,
        totalHarga: totalHarga,
        keterangan: keterangan,
      );
      widget.onConfirmPesanan(pesananData);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data beli berhasil ditambahkan."),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      widget.onNavigateAfterSubmit(4);
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
      _selectedJaminan = null;
    });
  }

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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildGradientButton(
          'Simpan Data',
          Icons.save_rounded,
          _submitForm,
        ),
      ),
    );
  }

  Widget _buildSewaForm() {
    return Form(
      key: _sewaFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCommonFields(),
          const SizedBox(height: 16),
          buildTextField(
            _durasiController,
            'Durasi Sewa (hari)',
            Icons.timer_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildJaminanDropdown(),
          const SizedBox(height: 16),
          _buildDatePicker("Tanggal Pengembalian Barang"),
          const SizedBox(height: 16),
          // --- PERUBAHAN: Label diubah ---
          buildTextField(
            _keteranganController,
            'Keterangan Barang',
            Icons.notes_rounded,
            maxLines: 3,
          ),
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
          _buildCommonFields(),
          const SizedBox(height: 16),
          // --- PERUBAHAN: Label diubah ---
          buildTextField(
            _keteranganController,
            'Keterangan Barang',
            Icons.notes_rounded,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // --- Field yang sama untuk kedua tab ---
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
        buildTextField(
          _hargaController,
          'Total Harga',
          Icons.price_check_rounded,
          keyboardType: TextInputType.number,
        ),
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
}
