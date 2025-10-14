import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

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
    _selectedItems = {for (var item in widget.initialSelection) item.stokItemId: item};
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
        title: const Text('Pilih Barang dari Stok'),
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
                        Text('Sisa: ${stokItem.jumlah}', style: AppTextStyles.body),
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
        label: Text('Selesai (${_selectedItems.length})'),
        icon: const Icon(Icons.check),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }
}
