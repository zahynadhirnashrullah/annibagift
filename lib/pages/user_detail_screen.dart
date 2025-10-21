import 'package:flutter/material.dart';
import '../services/firebase_admin_service.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: FirebaseAdminService.instance.getUserDocument(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Pengguna tidak ditemukan'));
          }

          final userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: userData.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${entry.key}:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value?.toString() ?? 'null',
                            style: const TextStyle(
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}