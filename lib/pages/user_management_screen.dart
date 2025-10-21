// lib/pages/user_management_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_admin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  final User currentUser;

  const UserManagementScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _adminService = FirebaseAdminService.instance;
  late Stream<List<User>> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = _adminService.getUsersStreamRTDB();
  }

  void _showUserFormDialog({User? user}) {
    final bool isEditing = user != null;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    Role selectedRole = user?.role ?? Role.karyawan;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        final sheetContext = modalContext;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
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
                  if (!isEditing) ...[
                    buildTextField(
                      emailController,
                      'Email',
                      Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  buildTextField(usernameController, 'Username', Icons.person_add_alt_1_rounded),
                  const SizedBox(height: 16),
                  if (!isEditing) ...[
                    buildTextField(passwordController, 'Password', Icons.lock_person_rounded, isObscure: true),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<Role>(
                    initialValue: selectedRole,
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
                    () async {
                      if (formKey.currentState!.validate()) {
                      if (isEditing) {
                        await _adminService.updateUser(user.id, username: usernameController.text, role: selectedRole);
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengguna berhasil diperbarui')));
                      } else {
                        final created = await _adminService.createUser(emailController.text, passwordController.text, usernameController.text, selectedRole);
                        if (created != null) {
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengguna berhasil dibuat')));
                          // Navigate to detail screen to show created data
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => UserDetailScreen(userId: created.id)),
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat pengguna')));
                        }
                      }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // _confirmDelete removed (no longer used)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pengguna')),
      body: StreamBuilder<List<User>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada pengguna.'));
          }
          final userList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              final isCurrentUser = user.id == widget.currentUser.id;
              return Opacity(
                opacity: user.isActive ? 1.0 : 0.5,
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      user.role == Role.admin ? Icons.shield_rounded : Icons.person_rounded,
                      color: user.isActive ? AppColors.primary : Colors.grey,
                      size: 40,
                    ),
                    title: Text(user.username, style: AppTextStyles.subtitle),
                    subtitle: Text(
                      '${user.role.name[0].toUpperCase()}${user.role.name.substring(1)} - ${user.isActive ? "Aktif" : "Nonaktif"}',
                      style: AppTextStyles.body,
                    ),
                    trailing: isCurrentUser
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'view') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetailScreen(userId: user.id),
                                  ),
                                );
                              } else if (value == 'edit') {
                                _showUserFormDialog(user: user);
                              } else if (value == 'toggle') {
                                await _adminService.toggleUserStatus(user.id);
                              } else if (value == 'delete') {
                                await _adminService.softDeleteUser(user.id);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(value: 'view', child: Text('Lihat Detail')),
                              const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                              PopupMenuItem<String>(value: 'toggle', child: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan')),
                              const PopupMenuItem<String>(value: 'delete', child: Text('Hapus', style: TextStyle(color: AppColors.accentRed))),
                            ],
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'user-management-fab',
        onPressed: () => _showUserFormDialog(),
        label: const Text('Tambah Pengguna'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}