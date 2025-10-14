import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class SewaScreen extends StatelessWidget {
  final List<Sewa> sewaList;
  final Function(int) onDelete;
  const SewaScreen({super.key, required this.sewaList, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Sewa')),
      body: sewaList.isEmpty
          ? const EmptyStateWidget(message: 'Belum ada data sewa', icon: Icons.shopping_cart_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sewaList.length,
              itemBuilder: (context, index) {
                final item = sewaList[index];
                return SewaListTile(item: item, onDelete: () => onDelete(index));
              },
            ),
    );
  }
}
