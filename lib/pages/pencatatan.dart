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

  // --- LOGIKA (TIDAK BERUBAH) ---
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _durasiController = TextEditingController();
  final _noHpController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _hargaController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _selectedPickupDate;
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
    final double totalHarga = double.tryParse(_hargaController.text) ?? 0.0;
    final String keterangan = _keteranganController.text;

    if (isSewaTab) {
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
      _selectedPickupDate = null;
      _selectedJaminan = null;
    });
  }
  // --- AKHIR LOGIKA (TIDAK BERUBAH) ---

  // --- MODIFIKASI TAMPILAN DIMULAI DI SINI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pencatatan Baru"),
        // TabBar tetap di AppBar, ini sudah modern
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
      // --- PERUBAHAN PADA BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        // Memberi padding, termasuk untuk area aman di bawah (notch iPhone)
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        // Dekorasi untuk "mengangkat" tombol
        decoration: BoxDecoration(
          color: AppColors.card, // Latar belakang putih
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).round()),
              blurRadius: 10,
              offset: const Offset(0, -5), // Bayangan di atas
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

  // Widget helper baru untuk membuat 'kartu' form
  Widget _buildFormSection({required String title, required Widget child}) {
    return Container(
      // Dekorasi kartu
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Latar belakang kartu
        borderRadius: BorderRadius.circular(16), // Sudut membulat
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()), // Bayangan halus
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul untuk setiap grup
          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24), // Garis pemisah
          child, // Konten form (field-field)
        ],
      ),
    );
  }

  // --- MERAPIKAN FORM DENGAN KARTU ---
  Widget _buildSewaForm() {
    return Form(
      key: _sewaFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu 1: Data Pelanggan
          _buildFormSection(
            title: 'Data Pelanggan',
            child: _buildCommonFields(),
          ),
          const SizedBox(height: 24), // Jarak antar kartu

          // Kartu 2: Detail Sewa
          _buildFormSection(
            title: 'Detail Sewa',
            child: Column(
              children: [
                // Tanggal Pengambilan
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
                // Harga di bagian bawah detail sewa
                buildTextField(
                  _hargaController,
                  'Total Harga',
                  Icons.price_check_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), // Jarak di bawah
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
          // Kartu 1: Data Pelanggan
          _buildFormSection(
            title: 'Data Pelanggan',
            child: _buildCommonFields(),
          ),
          const SizedBox(height: 24), // Jarak antar kartu

          // Kartu 2: Detail Pesanan
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
                // Harga dipindahkan ke bawah detail pesanan
                buildTextField(
                  _hargaController,
                  'Total Harga',
                  Icons.price_check_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), // Jarak di bawah
        ],
      ),
    );
  }

  // Field yang sama (tidak perlu diubah)
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

  // Widget Jaminan (tidak perlu diubah)
  Widget _buildJaminanDropdown() {
    return DropdownButtonFormField<String>(
      // --- PERBAIKAN LINTER: gunakan initialValue (value is deprecated) ---
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

  // Widget Date Picker (tidak perlu diubah)
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

  // Widget Date Picker untuk tanggal pengambilan
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
}