// lib/pages/user_management_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  // Tambahkan callback functions untuk setiap aksi
  final Function(String id, String newUsername, String newPassword, Role newRole) onUpdateUser;
  final Function(String id) onDeleteUser;
  final Function(String id) onToggleUserStatus;
  final Function(String username, String password, Role role) onAddUser;
  final User currentUser; // Kita butuh info user yang sedang login

  const UserManagementScreen({
    super.key,
    required this.onAddUser,
    required this.onUpdateUser,
    required this.onDeleteUser,
    required this.onToggleUserStatus,
    required this.currentUser,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {

  void _showUserFormDialog({User? user}) {
    final bool isEditing = user != null;
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController(text: user?.password ?? '');
    Role selectedRole = user?.role ?? Role.karyawan;

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
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEditing ? 'Edit Pengguna' : 'Tambah Pengguna Baru', style: AppTextStyles.heading2),
                const SizedBox(height: 24),
                buildTextField(usernameController, 'Username', Icons.person_add_alt_1_rounded),
                const SizedBox(height: 16),
                buildTextField(passwordController, 'Password', Icons.lock_person_rounded),
                const SizedBox(height: 16),
                DropdownButtonFormField<Role>(
                  value: selectedRole,
                  items: Role.values.map((role) => DropdownMenuItem<Role>(
                        value: role,
                        child: Text(role.name[0].toUpperCase() + role.name.substring(1)),
                      )).toList(),
                  onChanged: (value) {
                    if (value != null) selectedRole = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.security_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                buildGradientButton(
                  isEditing ? 'Simpan Perubahan' : 'Tambahkan Pengguna',
                  Icons.save_rounded,
                  () {
                    if (formKey.currentState!.validate()) {
                      if (isEditing) {
                        widget.onUpdateUser(user!.id, usernameController.text, passwordController.text, selectedRole);
                      } else {
                        widget.onAddUser(usernameController.text, passwordController.text, selectedRole);
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

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus pengguna "${user.username}"? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              widget.onDeleteUser(user.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userList = AuthService.instance.getUsers();

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pengguna')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];
          // Mencegah user mengedit/menghapus dirinya sendiri untuk keamanan
          final isCurrentUser = user.id == widget.currentUser.id;

          return Opacity(
            opacity: user.isActive ? 1.0 : 0.5, // Efek redup untuk user nonaktif
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  user.role == Role.pemilik ? Icons.shield_rounded : Icons.person_rounded,
                  color: user.isActive ? AppColors.primary : Colors.grey,
                  size: 40,
                ),
                title: Text(user.username, style: AppTextStyles.subtitle),
                subtitle: Text(
                  '${user.role.name[0].toUpperCase()}${user.role.name.substring(1)} - ${user.isActive ? "Aktif" : "Nonaktif"}',
                  style: AppTextStyles.body,
                ),
                trailing: isCurrentUser
                    ? null // Jangan tampilkan menu untuk user yang sedang login
                    : PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showUserFormDialog(user: user);
                          } else if (value == 'toggle') {
                            widget.onToggleUserStatus(user.id);
                          } else if (value == 'delete') {
                            _confirmDelete(user);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                          PopupMenuItem<String>(value: 'toggle', child: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan')),
                          const PopupMenuItem<String>(value: 'delete', child: Text('Hapus', style: TextStyle(color: AppColors.accentRed))),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'user-management-fab',
        onPressed: () => _showUserFormDialog(), // Panggil dialog yang sama tanpa user
        label: const Text('Tambah Pengguna'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}