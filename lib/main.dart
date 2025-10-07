import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const AnnibaGiftApp());
}

class AnnibaGiftApp extends StatelessWidget {
  const AnnibaGiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anniba Gift',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ================= HALAMAN DASHBOARD =================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> sewaList = [];
  final List<Map<String, dynamic>> pesananList = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // CRUD for Sewa
  void _addSewa(Map<String, dynamic> data) {
    setState(() {
      sewaList.add(data);
    });
  }

  void _updateSewa(int index, Map<String, dynamic> updated) {
    if (index >= 0 && index < sewaList.length) {
      setState(() {
        sewaList[index] = updated;
      });
    }
  }

  void _deleteSewa(int index) {
    if (index >= 0 && index < sewaList.length) {
      setState(() {
        sewaList.removeAt(index);
      });
    }
  }

  // CRUD for Pesanan
  void _addPesanan(Map<String, dynamic> data) {
    setState(() {
      pesananList.add(data);
    });
  }

  void _updatePesanan(int index, Map<String, dynamic> updated) {
    if (index >= 0 && index < pesananList.length) {
      setState(() {
        pesananList[index] = updated;
      });
    }
  }

  void _deletePesanan(int index) {
    if (index >= 0 && index < pesananList.length) {
      setState(() {
        pesananList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardHome(
        onAddPencatatan: () => setState(() => _selectedIndex = 1),
        onAddSewa: () => setState(() => _selectedIndex = 2),
      ),
      PencatatanPage(
        onConfirmSewa: (data) {
          _addSewa(data);
          setState(() => _selectedIndex = 2);
        },
        onConfirmPesanan: (data) {
          _addPesanan(data);
          setState(() => _selectedIndex = 3);
        },
      ),
      SewaPage(
        sewaList: sewaList,
        onEdit: _updateSewa,
        onDelete: _deleteSewa,
      ),
      PemesananPage(
        pesananList: pesananList,
        onEdit: _updatePesanan,
        onDelete: _deletePesanan,
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
            BottomNavigationBarItem(
                icon: Icon(Icons.edit_note), label: "Pencatatan"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Sewa"),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: "Pemesanan"),
          ],
        ),
      ),
    );
  }
}

// =================== WIDGET SHARED ===================
PreferredSizeWidget _buildGradientAppBar(String title, IconData icon) {
  return AppBar(
    title: Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 8),
        Text(title),
      ],
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
  );
}

Widget _buildGradientButton(String text, IconData icon, VoidCallback onPressed,
    {List<Color>? gradientColors}) {
  gradientColors ??= [Colors.pinkAccent, Colors.purpleAccent];
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: gradientColors),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      onPressed: onPressed,
    ),
  );
}

Widget _buildEmptyState(String text, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Text(text, style: TextStyle(color: Colors.grey.shade600)),
      ],
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label, IconData icon,
    {TextInputType? keyboardType}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    keyboardType: keyboardType,
    validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
  );
}

Widget _buildDataCard(
    IconData icon, Color color, String title, String description) {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading:
          CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
    ),
  );
}

// =================== DASHBOARD HOME ===================
class DashboardHome extends StatelessWidget {
  final VoidCallback onAddPencatatan;
  final VoidCallback onAddSewa;
  const DashboardHome({
    super.key,
    required this.onAddPencatatan,
    required this.onAddSewa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("dashboard"),
      appBar: _buildGradientAppBar("Dashboard", Icons.dashboard_rounded),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailKeuanganPage()),
              ),
              child: Card(
                elevation: 8,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Informasi Keuangan",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 2),
                                  FlSpot(1, 2.5),
                                  FlSpot(2, 1.8),
                                  FlSpot(3, 3.5),
                                  FlSpot(4, 2.8),
                                  FlSpot(5, 4),
                                ],
                                isCurved: true,
                                color: Colors.white,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                dotData: FlDotData(show: false),
                                barWidth: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Saldo saat ini",
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text("Rp 12.500.000",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dashboardMenuCard(
                    icon: Icons.edit_note,
                    color: Colors.pinkAccent,
                    title: "Tambah\nPencatatan",
                    onTap: onAddPencatatan),
                _dashboardMenuCard(
                    icon: Icons.shopping_cart,
                    color: Colors.purpleAccent,
                    title: "Tambah\nSewa",
                    onTap: onAddSewa),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardMenuCard(
      {required IconData icon,
      required Color color,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DETAIL KEUANGAN PAGE =================
class DetailKeuanganPage extends StatelessWidget {
  const DetailKeuanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGradientAppBar("Detail Keuangan", Icons.pie_chart),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Rincian Keuangan Bulanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDataCard(Icons.trending_up, Colors.green,
                      "Pemasukan", "Rp 25.000.000 bulan ini"),
                  _buildDataCard(Icons.trending_down, Colors.red,
                      "Pengeluaran", "Rp 12.500.000 bulan ini"),
                  _buildDataCard(Icons.account_balance_wallet, Colors.purple,
                      "Saldo Akhir", "Rp 12.500.000"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ================= HALAMAN PENCATATAN =================
class PencatatanPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onConfirmSewa;
  final Function(Map<String, dynamic>) onConfirmPesanan;
  const PencatatanPage(
      {super.key, required this.onConfirmSewa, required this.onConfirmPesanan});

  @override
  State<PencatatanPage> createState() => _PencatatanPageState();
}

class _PencatatanPageState extends State<PencatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _pesananController = TextEditingController();
  final _durasiController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedJaminan;

  final List<String> _jaminanOptions = [
    "KTP",
    "SIM",
    "Kartu Pelajar",
    "Uang Tunai Rp300.000"
  ];

  void _submitSewa() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedJaminan != null) {
      widget.onConfirmSewa({
        "nama": _namaController.text,
        "alamat": _alamatController.text,
        "tanggal": _selectedDate,
        "pesanan": _pesananController.text,
        "durasi": _durasiController.text,
        "jaminan": _selectedJaminan,
      });
      _clearForm();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Sewa berhasil ditambahkan")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lengkapi tanggal & jaminan")));
    }
  }

  void _submitPesanan() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      widget.onConfirmPesanan({
        "nama": _namaController.text,
        "alamat": _alamatController.text,
        "tanggal": _selectedDate,
        "pesanan": _pesananController.text,
      });
      _clearForm();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pesanan berhasil ditambahkan")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pilih tanggal pesanan")));
    }
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _pesananController.clear();
    _durasiController.clear();
    setState(() {
      _selectedDate = null;
      _selectedJaminan = null;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _pesananController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("pencatatan"),
      appBar: _buildGradientAppBar("Pencatatan", Icons.edit_note),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField(_namaController, "Nama Pelanggan", Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(_alamatController, "Alamat", Icons.home),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _pesananController, "Pesanan", Icons.card_giftcard),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_selectedDate == null
                            ? "Pilih Tanggal"
                            : "Tanggal: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text("Pilih"),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),
                  const Text("Form Sewa",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  // --- durasi sewa field (fixed) ---
                  _buildTextField(
                    _durasiController,
                    "Durasi Sewa (hari)",
                    Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedJaminan,
                    items: _jaminanOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedJaminan = v),
                    decoration: InputDecoration(
                      labelText: "Jaminan",
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) =>
                        v == null ? "Pilih salah satu jaminan" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildGradientButton(
                    "Simpan Sewa",
                    Icons.save,
                    _submitSewa,
                    gradientColors: [Colors.pinkAccent, Colors.purpleAccent],
                  ),
                  const SizedBox(height: 10),
                  _buildGradientButton(
                    "Simpan Pesanan",
                    Icons.shopping_bag,
                    _submitPesanan,
                    gradientColors: [Colors.orangeAccent, Colors.deepOrange],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HALAMAN SEWA =================
class SewaPage extends StatelessWidget {
  final List<Map<String, dynamic>> sewaList;
  final Function(int, Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const SewaPage({
    super.key,
    required this.sewaList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("sewa"),
      appBar: _buildGradientAppBar("Data Sewa", Icons.shopping_cart),
      body: sewaList.isEmpty
          ? _buildEmptyState("Belum ada data sewa", Icons.shopping_cart_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sewaList.length,
              itemBuilder: (context, index) {
                final item = sewaList[index];
                return Dismissible(
                  key: ValueKey(item['nama'] ?? index),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => onDelete(index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.shopping_cart, color: Colors.pinkAccent),
                      title: Text(item['nama'] ?? '-'),
                      subtitle: Text(
                          "Pesanan: ${item['pesanan'] ?? '-'}\nDurasi: ${item['durasi'] ?? '-'} hari\nJaminan: ${item['jaminan'] ?? '-'}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => onDelete(index),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ================= HALAMAN PEMESANAN =================
class PemesananPage extends StatelessWidget {
  final List<Map<String, dynamic>> pesananList;
  final Function(int, Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const PemesananPage({
    super.key,
    required this.pesananList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("pemesanan"),
      appBar: _buildGradientAppBar("Data Pemesanan", Icons.list_alt),
      body: pesananList.isEmpty
          ? _buildEmptyState("Belum ada data pesanan", Icons.list_alt_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final item = pesananList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.card_giftcard, color: Colors.purpleAccent),
                    title: Text(item['nama'] ?? '-'),
                    subtitle: Text("Pesanan: ${item['pesanan'] ?? '-'}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => onDelete(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
