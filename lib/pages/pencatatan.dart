import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import 'pilih_stok.dart';

class PencatatanScreen extends StatefulWidget {
  final List<StokItem> stokList;
  final Function(Sewa) onConfirmSewa;
  final Function(Pesanan) onConfirmPesanan;
  final Function(int) onNavigateAfterSubmit;

  const PencatatanScreen({
    super.key,
    required this.stokList,
    required this.onConfirmSewa,
    required this.onConfirmPesanan,
    required this.onNavigateAfterSubmit,
  });

  @override
  State<PencatatanScreen> createState() => _PencatatanScreenState();
}

class _PencatatanScreenState extends State<PencatatanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _sewaFormKey = GlobalKey<FormState>();
  final _pesananFormKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  DateTime? _selectedDate;
  List<OrderItem> _selectedItems = [];

  final _durasiController = TextEditingController();
  String? _selectedJaminan;

  final List<String> _jaminanOptions = ["KTP", "SIM", "Kartu Pelajar", "Uang Tunai Rp300.000"];

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

    if (formKey.currentState!.validate() && _selectedDate != null && _selectedItems.isNotEmpty) {
      if (isSewaTab) {
        if (_selectedJaminan != null) {
          final sewaData = Sewa(
            nama: _namaController.text,
            alamat: _alamatController.text,
            tanggal: _selectedDate!,
            items: _selectedItems,
            durasi: int.tryParse(_durasiController.text) ?? 0,
            jaminan: _selectedJaminan!,
          );
          widget.onConfirmSewa(sewaData);
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data sewa berhasil ditambahkan."), backgroundColor: AppColors.accentGreen,));
          widget.onNavigateAfterSubmit(3);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap pilih jaminan."), backgroundColor: AppColors.accentRed,));
        }
      } else {
        final pesananData = Pesanan(
          nama: _namaController.text,
          alamat: _alamatController.text,
          tanggal: _selectedDate!,
          items: _selectedItems,
        );
        widget.onConfirmPesanan(pesananData);
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data pesanan berhasil ditambahkan."), backgroundColor: AppColors.accentGreen,));
        widget.onNavigateAfterSubmit(4);
      }
    } else {
      String errorMessage = "Harap lengkapi semua data";
      if (_selectedItems.isEmpty) {
        errorMessage = "Harap pilih minimal satu barang.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: AppColors.accentRed,));
    }
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _durasiController.clear();
    setState(() {
      _selectedDate = null;
      _selectedJaminan = null;
      _selectedItems = [];
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
            Tab(text: "Pemesanan"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSewaForm(),
          _buildPesananForm(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildGradientButton('Simpan Data', Icons.save_rounded, _submitForm),
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
          buildTextField(_durasiController, 'Durasi Sewa (hari)', Icons.timer_rounded, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildJaminanDropdown(),
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
        ],
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        buildTextField(_namaController, 'Nama Pelanggan', Icons.person_outline_rounded),
        const SizedBox(height: 16),
        buildTextField(_alamatController, 'Alamat', Icons.home_outlined),
        const SizedBox(height: 16),
        _buildItemSelectionField(),
        const SizedBox(height: 16),
        _buildDatePicker(),
      ],
    );
  }

  Widget _buildItemSelectionField() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<List<OrderItem>>(context, MaterialPageRoute(builder: (context) => PilihStokScreen(stokList: widget.stokList, initialSelection: _selectedItems)));
        if (result != null) {
          setState(() {
            _selectedItems = result;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Barang Pesanan/Sewa',
          prefixIcon: const Icon(Icons.card_giftcard_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: _selectedItems.isEmpty ? const Text('Pilih barang...') : Text('${_selectedItems.length} barang dipilih'),
      ),
    );
  }

  Widget _buildJaminanDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedJaminan,
      items: _jaminanOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal',
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedDate == null ? 'Pilih Tanggal' : DateFormat('d MMMM yyyy').format(_selectedDate!),
          style: TextStyle(
            color: _selectedDate == null ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
