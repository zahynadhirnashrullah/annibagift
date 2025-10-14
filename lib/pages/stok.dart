import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class StokScreen extends StatefulWidget {
  final List<StokItem> stokList;
  final Function(String nama, int jumlah) onAdd;
  final Function(String id, String newName, int newJumlah) onUpdate;
  final Function(String id, int additionalJumlah) onRestock;

  const StokScreen({super.key, required this.stokList, required this.onAdd, required this.onUpdate, required this.onRestock});

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
                buildTextField(namaController, 'Nama Barang', Icons.label_important_outline_rounded),
                const SizedBox(height: 16),
                buildTextField(jumlahController, 'Jumlah Stok', Icons.format_list_numbered_rounded, keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                buildGradientButton(
                  isEditing ? 'Simpan Perubahan' : 'Tambahkan',
                  Icons.save_rounded,
                  () {
                    // Use null-aware access to avoid a redundant '!' if analyzer flags it
                    final valid = formKey.currentState?.validate() ?? false;
                    if (valid) {
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
          child: buildTextField(jumlahController, 'Jumlah Tambahan', Icons.add_shopping_cart_rounded, keyboardType: TextInputType.number),
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
      appBar: AppBar(title: const Text('Manajemen Stok')),
      body: widget.stokList.isEmpty
          ? const EmptyStateWidget(message: 'Belum ada barang di stok', icon: Icons.inventory_2_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: widget.stokList.length,
              itemBuilder: (context, index) {
                final item = widget.stokList[index];
                return StokListTile(
                  item: item,
                  onEdit: () => _showStokFormDialog(item: item),
                  onRestock: () => _showRestockDialog(item),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStokFormDialog(),
        label: const Text('Tambah Barang'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
