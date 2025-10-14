import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Pastikan package intl: ^0.18.1 sudah ditambahkan di pubspec.yaml

void main() {
  runApp(const AnnibaGiftApp());
}

// ====================================================================
// --- THEME & CONSTANTS ---
// ====================================================================

class AppColors {
  static const Color primary = Color(0xFF6A5AE0);
  static const Color secondary = Color(0xFF9E94FF);
  static const Color background = Color(0xFFF5F6FA);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF828282);
  static const Color card = Colors.white;
  static const Color accentPink = Color(0xFFFF7B9A);
  static const Color accentGreen = Color(0xFF00C49A);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color accentBlue = Color(0xFF4D8EFF);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

// ====================================================================
// --- DATA MODELS ---
// ====================================================================

// NEW: Model untuk item dalam pesanan
class OrderItem {
  final String stokItemId;
  final String namaBarang;
  int jumlah;

  OrderItem({
    required this.stokItemId,
    required this.namaBarang,
    required this.jumlah,
  });
}

class StokItem {
  String id;
  String nama;
  int jumlah;

  StokItem({required this.id, required this.nama, required this.jumlah});
}

class Sewa {
  final String nama;
  final String alamat;
  final DateTime tanggal;
  final List<OrderItem> items; // UPDATED
  final int durasi;
  final String jaminan;

  Sewa({
    required this.nama,
    required this.alamat,
    required this.tanggal,
    required this.items, // UPDATED
    required this.durasi,
    required this.jaminan,
  });
}

class Pesanan {
  final String nama;
  final String alamat;
  final DateTime tanggal;
  final List<OrderItem> items; // UPDATED

  Pesanan({
    required this.nama,
    required this.alamat,
    required this.tanggal,
    required this.items, // UPDATED
  });
}

// ====================================================================
// --- MAIN APP ---
// ====================================================================

class AnnibaGiftApp extends StatelessWidget {
  const AnnibaGiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anniba Gift',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: "Poppins",
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins"
          ),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ====================================================================
// --- MAIN SCREEN (Manajemen State & Navigasi) ---
// ====================================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // State aplikasi sekarang dikelola di sini
  final List<Sewa> sewaList = [];
  final List<Pesanan> pesananList = [];
  final List<StokItem> stokList = [
    StokItem(id: '1', nama: 'Kotak Kado Besar', jumlah: 15),
    StokItem(id: '2', nama: 'Pita Satin Merah (rol)', jumlah: 30),
    StokItem(id: '3', nama: 'Snack Bouquet', jumlah: 12),
    StokItem(id: '4', nama: 'Papan Bunga', jumlah: 8),
    StokItem(id: '5', nama: 'Wrapping Paper Emas', jumlah: 20),
    StokItem(id: '6', nama: 'Kartu Ucapan', jumlah: 50),
    StokItem(id: '7', nama: 'Bunga Segar (ikat)', jumlah: 9),
    StokItem(id: '8', nama: 'Kotak Kado Kecil', jumlah: 25),
    StokItem(id: '9', nama: 'Pita Satin Biru (rol)', jumlah: 18),
    StokItem(id: '10', nama: 'Snack Box', jumlah: 14),
    StokItem(id: '11', nama: 'Balon Helium (pak)', jumlah: 22),
    StokItem(id: '12', nama: 'Kertas Kado Polkadot', jumlah: 17),
    StokItem(id: '13', nama: 'Bunga Plastik (ikat)', jumlah: 11),
    StokItem(id: '14', nama: 'Kartu Ucapan Spesial', jumlah: 35),
    StokItem(id: '15', nama: 'Papan Bunga Mini', jumlah: 5),
    StokItem(id: '16', nama: 'Bouquet Hijab', jumlah: 19),
    StokItem(id: '17', nama: 'Money Bouquet', jumlah: 13),
    StokItem(id: '18', nama: 'Bloom Box', jumlah: 7),
  ];

  // NEW: Fungsi untuk mengurangi stok
  void _kurangiStok(List<OrderItem> items) {
    setState(() {
      for (var orderItem in items) {
        final index = stokList.indexWhere((stok) => stok.id == orderItem.stokItemId);
        if (index != -1) {
          stokList[index].jumlah -= orderItem.jumlah;
        }
      }
    });
  }

  // CRUD for Stok
  void _addStok(String nama, int jumlah) {
    setState(() {
      stokList.add(StokItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        jumlah: jumlah,
      ));
    });
  }

  void _updateStok(String id, String newName, int newJumlah) {
    setState(() {
      final index = stokList.indexWhere((item) => item.id == id);
      if (index != -1) {
        stokList[index].nama = newName;
        stokList[index].jumlah = newJumlah;
      }
    });
  }

  void _restockStok(String id, int additionalJumlah) {
     setState(() {
      final index = stokList.indexWhere((item) => item.id == id);
      if (index != -1) {
        stokList[index].jumlah += additionalJumlah;
      }
    });
  }

  // CRUD for Sewa
  void _addSewa(Sewa data) {
    setState(() {
      sewaList.add(data);
      _kurangiStok(data.items); // Kurangi stok saat sewa ditambahkan
    });
  }

  void _deleteSewa(int index) {
    setState(() {
      sewaList.removeAt(index);
    });
  }

  // CRUD for Pesanan
  void _addPesanan(Pesanan data) {
    setState(() {
      pesananList.add(data);
      _kurangiStok(data.items); // Kurangi stok saat pesanan ditambahkan
    });
  }

  void _deletePesanan(int index) {
    setState(() {
      pesananList.removeAt(index);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> currentPages = [
      DashboardScreen(
        sewaCount: sewaList.length,
        pesananCount: pesananList.length,
        stokCount: stokList.length,
        onNavigateToSewa: () => _onItemTapped(3),
        onNavigateToPesanan: () => _onItemTapped(4),
        onNavigateToStok: () => _onItemTapped(2),
      ),
      PencatatanScreen(
        stokList: stokList, // Pass stok list to pencatatan
        onConfirmSewa: _addSewa,
        onConfirmPesanan: _addPesanan,
        onNavigateAfterSubmit: (int pageIndex) => _onItemTapped(pageIndex),
      ),
      StokScreen(
        stokList: stokList,
        onAdd: _addStok,
        onUpdate: _updateStok,
        onRestock: _restockStok,
      ),
      SewaScreen(sewaList: sewaList, onDelete: _deleteSewa),
      PemesananScreen(pesananList: pesananList, onDelete: _deletePesanan),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: currentPages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: "Pencatatan"),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: "Stok"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: "Sewa"),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: "Pesanan"),
            ],
          ),
        ),
      ),
    );
  }
}


// ====================================================================
// --- SCREEN: Dashboard ---
// ====================================================================
class DashboardScreen extends StatelessWidget {
  final int sewaCount;
  final int pesananCount;
  final int stokCount;
  final VoidCallback onNavigateToSewa;
  final VoidCallback onNavigateToPesanan;
  final VoidCallback onNavigateToStok;
  
  const DashboardScreen({
    super.key, 
    required this.sewaCount, 
    required this.pesananCount,
    required this.stokCount,
    required this.onNavigateToSewa,
    required this.onNavigateToPesanan,
    required this.onNavigateToStok,
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Selamat Datang, Anniba!", style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          const Text("Berikut ringkasan bisnis Anda hari ini.", style: AppTextStyles.body),
          const SizedBox(height: 24),

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
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Saldo", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                const Text("Rp 12.500.000", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
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
                            color: Colors.white.withOpacity(0.2),
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
              Expanded(child: _StatCard(
                icon: Icons.shopping_cart_checkout_rounded, 
                label: "Sewa Aktif", 
                value: sewaCount.toString(), 
                color: AppColors.accentPink,
                onTap: onNavigateToSewa,
              )),
              const SizedBox(width: 16),
               Expanded(child: _StatCard(
                icon: Icons.list_alt_rounded, 
                label: "Total Pesanan", 
                value: pesananCount.toString(), 
                color: AppColors.accentGreen,
                onTap: onNavigateToPesanan,
              )),
            ],
          ),
          const SizedBox(height: 16),
          _StatCard(
            icon: Icons.inventory_2_outlined,
            label: "Jenis Barang di Stok",
            value: stokCount.toString(),
            color: AppColors.accentBlue,
            onTap: onNavigateToStok,
            isFullWidth: true,
          ),
          const SizedBox(height: 24),
          const Text("Aktivitas Terbaru", style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          const Center(
            child: Text("Belum ada aktivitas terbaru.", style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _StatCard({
    required this.icon, 
    required this.label, 
    required this.value, 
    required this.color,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isFullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                       const SizedBox(height: 4),
                       Text(value, style: AppTextStyles.heading2),
                    ],
                  ),
                )
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.heading2),
              ],
            ),
      ),
    );
  }
}

// ====================================================================
// --- SCREEN: Pencatatan ---
// ====================================================================

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
          widget.onNavigateAfterSubmit(3); // Navigate to Sewa page
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
        widget.onNavigateAfterSubmit(4); // Navigate to Pesanan page
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
        child: _buildGradientButton("Simpan Data", Icons.save_rounded, _submitForm),
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
          _buildTextField(_durasiController, "Durasi Sewa (hari)", Icons.timer_rounded, keyboardType: TextInputType.number),
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
        _buildTextField(_namaController, "Nama Pelanggan", Icons.person_outline_rounded),
        const SizedBox(height: 16),
        _buildTextField(_alamatController, "Alamat", Icons.home_outlined),
        const SizedBox(height: 16),
        _buildItemSelectionField(), // UPDATED
        const SizedBox(height: 16),
        _buildDatePicker(),
      ],
    );
  }
  
  Widget _buildItemSelectionField() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<List<OrderItem>>(
          context,
          MaterialPageRoute(
            builder: (context) => PilihStokScreen(
              stokList: widget.stokList,
              initialSelection: _selectedItems,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _selectedItems = result;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Barang Pesanan/Sewa",
          prefixIcon: const Icon(Icons.card_giftcard_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: _selectedItems.isEmpty
            ? const Text("Pilih barang...")
            : Text("${_selectedItems.length} barang dipilih"),
      ),
    );
  }

  Widget _buildJaminanDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedJaminan,
      items: _jaminanOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => _selectedJaminan = v),
      decoration: InputDecoration(
        labelText: "Jaminan",
        prefixIcon: const Icon(Icons.security_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) => v == null ? "Pilih salah satu jaminan" : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Tanggal",
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
           filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedDate == null 
            ? "Pilih Tanggal" 
            : DateFormat('d MMMM yyyy').format(_selectedDate!),
          style: TextStyle(
            color: _selectedDate == null ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// --- SCREEN: Stok ---
// ====================================================================

class StokScreen extends StatefulWidget {
  final List<StokItem> stokList;
  final Function(String nama, int jumlah) onAdd;
  final Function(String id, String newName, int newJumlah) onUpdate;
  final Function(String id, int additionalJumlah) onRestock;

  const StokScreen({
    super.key,
    required this.stokList,
    required this.onAdd,
    required this.onUpdate,
    required this.onRestock,
  });

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  void _showStokFormDialog({StokItem? item}) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: item?.nama);
    final jumlahController = TextEditingController(text: item?.jumlah.toString());
    final bool isEditing = item != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEditing ? 'Edit Barang' : 'Tambah Barang Baru', style: AppTextStyles.heading2),
                const SizedBox(height: 24),
                _buildTextField(namaController, "Nama Barang", Icons.label_important_outline_rounded),
                const SizedBox(height: 16),
                _buildTextField(jumlahController, "Jumlah Stok", Icons.format_list_numbered_rounded, keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                _buildGradientButton(
                  isEditing ? 'Simpan Perubahan' : 'Tambahkan',
                  Icons.save_rounded,
                  () {
                    if (formKey.currentState!.validate()) {
                      final nama = namaController.text;
                      final jumlah = int.tryParse(jumlahController.text) ?? 0;
                      if (isEditing) {
                        widget.onUpdate(item.id, nama, jumlah);
                      } else {
                        widget.onAdd(nama, jumlah);
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRestockDialog(StokItem item) {
    final formKey = GlobalKey<FormState>();
    final jumlahController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restock Barang', style: AppTextStyles.subtitle),
        content: Form(
          key: formKey,
          child: _buildTextField(jumlahController, "Jumlah Tambahan", Icons.add_shopping_cart_rounded, keyboardType: TextInputType.number),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final jumlah = int.tryParse(jumlahController.text) ?? 0;
                widget.onRestock(item.id, jumlah);
                Navigator.pop(context);
              }
            },
            child: const Text('Tambahkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Stok")),
      body: widget.stokList.isEmpty
          ? const EmptyStateWidget(message: "Belum ada barang di stok", icon: Icons.inventory_2_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding for FAB
              itemCount: widget.stokList.length,
              itemBuilder: (context, index) {
                final item = widget.stokList[index];
                return _StokListTile(
                  item: item,
                  onEdit: () => _showStokFormDialog(item: item),
                  onRestock: () => _showRestockDialog(item),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStokFormDialog(),
        label: const Text("Tambah Barang"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// ====================================================================
// --- NEW SCREEN: Pilih Stok ---
// ====================================================================

class PilihStokScreen extends StatefulWidget {
  final List<StokItem> stokList;
  final List<OrderItem> initialSelection;
  const PilihStokScreen({super.key, required this.stokList, required this.initialSelection});

  @override
  State<PilihStokScreen> createState() => _PilihStokScreenState();
}

class _PilihStokScreenState extends State<PilihStokScreen> {
  late Map<String, OrderItem> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = {
      for (var item in widget.initialSelection) item.stokItemId: item
    };
  }

  void _updateQuantity(StokItem stokItem, int change) {
    setState(() {
      final existing = _selectedItems[stokItem.id];
      final currentQty = existing?.jumlah ?? 0;
      final newQty = currentQty + change;

      if (newQty > 0) {
        if (newQty > stokItem.jumlah) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Stok ${stokItem.nama} tidak mencukupi.'),
            backgroundColor: AppColors.accentRed,
          ));
          return;
        }
        if (existing != null) {
          existing.jumlah = newQty;
        } else {
          _selectedItems[stokItem.id] = OrderItem(
            stokItemId: stokItem.id,
            namaBarang: stokItem.nama,
            jumlah: newQty,
          );
        }
      } else {
        _selectedItems.remove(stokItem.id);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Barang dari Stok"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        itemCount: widget.stokList.length,
        itemBuilder: (context, index) {
          final stokItem = widget.stokList[index];
          final selectedQty = _selectedItems[stokItem.id]?.jumlah ?? 0;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stokItem.nama, style: AppTextStyles.subtitle),
                        Text("Sisa: ${stokItem.jumlah}", style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: selectedQty > 0 ? () => _updateQuantity(stokItem, -1) : null,
                      ),
                      Text(selectedQty.toString(), style: AppTextStyles.subtitle),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        onPressed: selectedQty < stokItem.jumlah ? () => _updateQuantity(stokItem, 1) : null,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _selectedItems.values.toList());
        },
        label: Text("Selesai (${_selectedItems.length})"),
        icon: const Icon(Icons.check),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }
}

// ====================================================================
// --- SCREEN: Sewa & Pemesanan ---
// ====================================================================

class SewaScreen extends StatelessWidget {
  final List<Sewa> sewaList;
  final Function(int) onDelete;
  const SewaScreen({super.key, required this.sewaList, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Sewa")),
      body: sewaList.isEmpty
          ? const EmptyStateWidget(message: "Belum ada data sewa", icon: Icons.shopping_cart_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sewaList.length,
              itemBuilder: (context, index) {
                final item = sewaList[index];
                return _SewaListTile(item: item, onDelete: () => onDelete(index));
              },
            ),
    );
  }
}

class PemesananScreen extends StatelessWidget {
  final List<Pesanan> pesananList;
  final Function(int) onDelete;
  const PemesananScreen({super.key, required this.pesananList, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Pemesanan")),
      body: pesananList.isEmpty
          ? const EmptyStateWidget(message: "Belum ada data pesanan", icon: Icons.list_alt_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final item = pesananList[index];
                return _PesananListTile(item: item, onDelete: () => onDelete(index));
              },
            ),
    );
  }
}

// ====================================================================
// --- SHARED WIDGETS ---
// ====================================================================

Widget _buildGradientButton(String text, IconData icon, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ]
    ),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: AppTextStyles.button),
      onPressed: onPressed,
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label, IconData icon,
    {TextInputType? keyboardType}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    keyboardType: keyboardType,
    validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
  );
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyStateWidget({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.body.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

class _SewaListTile extends StatelessWidget {
  final Sewa item;
  final VoidCallback onDelete;

  const _SewaListTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.nama, style: AppTextStyles.subtitle),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // UPDATED: Display list of items
            ...item.items.map((orderItem) => Text('• ${orderItem.namaBarang} (x${orderItem.jumlah})', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary))),
            const Divider(height: 24),
             _InfoRow(icon: Icons.calendar_today_outlined, text: DateFormat('d MMM yyyy').format(item.tanggal)),
             _InfoRow(icon: Icons.timer_outlined, text: "${item.durasi} hari"),
             _InfoRow(icon: Icons.security_outlined, text: "Jaminan: ${item.jaminan}"),
          ],
        ),
      ),
    );
  }
}

class _PesananListTile extends StatelessWidget {
  final Pesanan item;
  final VoidCallback onDelete;
  
  const _PesananListTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
     return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.nama, style: AppTextStyles.subtitle),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // UPDATED: Display list of items
            ...item.items.map((orderItem) => Text('• ${orderItem.namaBarang} (x${orderItem.jumlah})', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary))),
            const Divider(height: 24),
            _InfoRow(icon: Icons.calendar_today_outlined, text: DateFormat('d MMM yyyy').format(item.tanggal)),
            _InfoRow(icon: Icons.location_on_outlined, text: item.alamat),
          ],
        ),
      ),
    );
  }
}

class _StokListTile extends StatelessWidget {
  final StokItem item;
  final VoidCallback onEdit;
  final VoidCallback onRestock;

  const _StokListTile({required this.item, required this.onEdit, required this.onRestock});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama, style: AppTextStyles.subtitle),
                  Text("Sisa: ${item.jumlah} unit", style: AppTextStyles.body),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'restock') {
                  onRestock();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit')),
                ),
                const PopupMenuItem<String>(
                  value: 'restock',
                  child: ListTile(leading: Icon(Icons.add_shopping_cart_rounded), title: Text('Restock')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

