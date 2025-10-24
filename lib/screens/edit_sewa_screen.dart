// lib/screens/edit_sewa_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Naik satu level saja
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class EditSewaScreen extends StatefulWidget {
  final Sewa sewa;
  final Function(Sewa, Sewa) onConfirmEdit;

  const EditSewaScreen(
      {super.key, required this.sewa, required this.onConfirmEdit});

  @override
  State<EditSewaScreen> createState() => _EditSewaScreenState();
}

class _EditSewaScreenState extends State<EditSewaScreen> {
  final _sewaFormKey = GlobalKey<FormState>();

  // Controller
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _durasiController = TextEditingController();
  final _noHpController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _hargaController = TextEditingController();

  DateTime? _selectedDate;
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
    _namaController.text = widget.sewa.nama;
    _alamatController.text = widget.sewa.alamat;
    _durasiController.text = widget.sewa.durasi.toString();
    _noHpController.text = widget.sewa.noHp;
    _keteranganController.text = widget.sewa.keterangan;
    _hargaController.text = widget.sewa.totalHarga.toStringAsFixed(0);
    _selectedDate = widget.sewa.tanggal;
    _selectedJaminan = widget.sewa.jaminan;
    _selectedSewaStatus = widget.sewa.status;
  }

  @override
  void dispose() {
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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm() {
    if (!_sewaFormKey.currentState!.validate()) {
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

    final updatedSewa = Sewa(
      id: widget.sewa.id,
      nama: _namaController.text,
      alamat: _alamatController.text,
      noHp: _noHpController.text,
      tanggal: _selectedDate!,
      tanggalDibuat: widget.sewa.tanggalDibuat,
      totalHarga: double.tryParse(_hargaController.text) ?? 0.0,
      keterangan: _keteranganController.text,
      durasi: int.tryParse(_durasiController.text) ?? 0,
      jaminan: _selectedJaminan!,
      status: _selectedSewaStatus ?? SewaStatus.proses,
    );

    widget.onConfirmEdit(widget.sewa, updatedSewa);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Data Sewa"),
      ),
      body: Form(
        key: _sewaFormKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildTextField(
                _namaController, 'Nama Pelanggan', Icons.person_outline_rounded),
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
            buildTextField(
              _keteranganController,
              'Keterangan Barang',
              Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildSewaStatusDropdown(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildGradientButton(
          'Simpan Perubahan',
          Icons.save_rounded,
          _submitForm,
        ),
      ),
    );
  }

  Widget _buildJaminanDropdown() {
    return DropdownButtonFormField<String>(
      // --- PERBAIKAN LINTER: use 'initialValue' instead of deprecated 'value' ---
      initialValue: _selectedJaminan,
      // --- AKHIR PERBAIKAN ---
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

  Widget _buildSewaStatusDropdown() {
    return DropdownButtonFormField<SewaStatus>(
      initialValue: _selectedSewaStatus,
      items: SewaStatus.values
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status == SewaStatus.proses
                    ? 'Proses'
                    : status == SewaStatus.selesai
                        ? 'Selesai'
                        : 'Dibatalkan'),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedSewaStatus = v),
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: const Icon(Icons.sync_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
