import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class PemesananScreen extends StatelessWidget {
  final List<Pesanan> pesananList;
  final Function(int) onDelete;
  const PemesananScreen({super.key, required this.pesananList, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Pemesanan')),
      body: pesananList.isEmpty
          ? const EmptyStateWidget(message: 'Belum ada data pesanan', icon: Icons.list_alt_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final item = pesananList[index];
                return PesananListTile(item: item, onDelete: () => onDelete(index));
              },
            ),
    );
  }
}
