// lib/screens/details/edit_pesanan_screen.dart

import 'package:flutter/material.dart';
// --- PERBAIKAN DI SINI ---
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import '../../theme/app_theme.dart';
// --- AKHIR PERBAIKAN ---

class EditPesananScreen extends StatefulWidget {
  final Pesanan pesanan;
  final Function(Pesanan, Pesanan) onConfirmEdit;

  const EditPesananScreen(
      {super.key, required this.pesanan, required this.onConfirmEdit});

  @override
  State<EditPesananScreen> createState() => _EditPesananScreenState();
}

class _EditPesananScreenState extends State<EditPesananScreen> {
  final _pesananFormKey = GlobalKey<FormState>();

  // Controller
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _hargaController = TextEditingController();

  PesananStatus? _selectedPesananStatus;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.pesanan.nama;
    _alamatController.text = widget.pesanan.alamat;
    _noHpController.text = widget.pesanan.noHp;
    _keteranganController.text = widget.pesanan.keterangan;
    _hargaController.text = widget.pesanan.totalHarga.toStringAsFixed(0);
    _selectedPesananStatus = widget.pesanan.status;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _keteranganController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_pesananFormKey.currentState!.validate()) {
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

    final updatedPesanan = Pesanan(
      id: widget.pesanan.id,
      nama: _namaController.text,
      alamat: _alamatController.text,
      noHp: _noHpController.text,
      totalHarga: double.tryParse(_hargaController.text) ?? 0.0,
      keterangan: _keteranganController.text,
      tanggalDibuat: widget.pesanan.tanggalDibuat,
      status: _selectedPesananStatus ?? PesananStatus.proses,
    );

    widget.onConfirmEdit(widget.pesanan, updatedPesanan);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Data Pesanan"),
      ),
      body: Form(
        key: _pesananFormKey,
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
              _keteranganController,
              'Keterangan Barang',
              Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildPesananStatusDropdown(),
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

  Widget _buildPesananStatusDropdown() {
    return DropdownButtonFormField<PesananStatus>(
      initialValue: _selectedPesananStatus,
      items: PesananStatus.values
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status == PesananStatus.proses
                    ? 'Proses'
                    : status == PesananStatus.selesai
                        ? 'Selesai'
                        : 'Dibatalkan'),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedPesananStatus = v),
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
