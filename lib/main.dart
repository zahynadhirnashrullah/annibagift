import 'package:flutter/material.dart';

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
      ),
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ProdukPage(),
      PencatatanPage(
        onConfirmSewa: (data) {
          setState(() {
            sewaList.add(data);
            _selectedIndex = 2;
          });
        },
        onConfirmPesanan: (data) {
          setState(() {
            pesananList.add(data);
            _selectedIndex = 3;
          });
        },
      ),
      SewaPage(sewaList: sewaList),
      PemesananPage(pesananList: pesananList),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.2, 0), // slide dari kanan
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard), label: "Produk"),
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

// ================= HALAMAN PRODUK =================
class ProdukPage extends StatelessWidget {
  const ProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("produk"),
      appBar: _buildGradientAppBar("Daftar Produk"),
      body: const Center(
        child: Text(
          "Daftar Produk Anniba Gift",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ================= HALAMAN PENCATATAN =================
class PencatatanPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onConfirmSewa;
  final Function(Map<String, dynamic>) onConfirmPesanan;

  const PencatatanPage({
    super.key,
    required this.onConfirmSewa,
    required this.onConfirmPesanan,
  });

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
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("pencatatan"),
      appBar: _buildGradientAppBar("Pencatatan"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_namaController, "Nama Pelanggan", Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_alamatController, "Alamat", Icons.home),
              const SizedBox(height: 12),
              _buildTextField(_pesananController, "Pesanan", Icons.card_giftcard),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? "Pilih Tanggal"
                        : "Tanggal: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
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
              _buildTextField(_durasiController, "Durasi Sewa (hari)", Icons.timer,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedJaminan,
                decoration: const InputDecoration(labelText: "Jaminan"),
                items: _jaminanOptions.map((String item) {
                  return DropdownMenuItem<String>(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJaminan = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitSewa,
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Confirm Sewa"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _submitPesanan,
                icon: const Icon(Icons.check_circle),
                label: const Text("Confirm Pesanan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= HALAMAN SEWA =================
class SewaPage extends StatelessWidget {
  final List<Map<String, dynamic>> sewaList;

  const SewaPage({super.key, required this.sewaList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("sewa"),
      appBar: _buildGradientAppBar("Daftar Sewa"),
      body: sewaList.isEmpty
          ? const Center(child: Text("Belum ada data sewa"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sewaList.length,
              itemBuilder: (context, index) {
                final item = sewaList[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.pinkAccent),
                    title: Text("${item['nama']} - ${item['pesanan']}"),
                    subtitle: Text(
                        "Durasi: ${item['durasi']} hari\nJaminan: ${item['jaminan']}"),
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

  const PemesananPage({super.key, required this.pesananList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey("pemesanan"),
      appBar: _buildGradientAppBar("Daftar Pemesanan"),
      body: pesananList.isEmpty
          ? const Center(child: Text("Belum ada data pemesanan"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final item = pesananList[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.list_alt, color: Colors.green),
                    title: Text("${item['nama']} - ${item['pesanan']}"),
                    subtitle: Text("Alamat: ${item['alamat']}"),
                  ),
                );
              },
            ),
    );
  }
}

// ================= WIDGET CUSTOM =================
PreferredSizeWidget _buildGradientAppBar(String title) {
  return AppBar(
    title: Text(title),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    centerTitle: true,
    titleTextStyle:
        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  );
}

Widget _buildTextField(TextEditingController controller, String label, IconData icon,
    {TextInputType keyboardType = TextInputType.text}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.pinkAccent),
    ),
    keyboardType: keyboardType,
    validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
  );
}
