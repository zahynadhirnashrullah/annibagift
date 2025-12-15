// lib/pages/user_management_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_admin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  final User currentUser;

  const UserManagementScreen({super.key, required this.currentUser});

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

  // --- LOGIKA FORM INPUT (TIDAK BERUBAH) ---
  void _showUserFormDialog({User? user}) {
    final bool isEditing = user != null;
    final formKey = GlobalKey<FormState>();

    final emailController = TextEditingController(text: user?.email ?? '');
    final usernameController = TextEditingController(
      text: user?.username ?? '',
    );
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Role selectedRole = user?.role ?? Role.karyawan;
    bool isPasswordVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: StatefulBuilder(
              builder: (BuildContext dialogContext, StateSetter dialogSetState) {
                return SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Pengguna' : 'Tambah Pengguna Baru',
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 24),

                        if (!isEditing) ...[
                          buildTextField(
                            emailController,
                            'Email',
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
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

                        if (isEditing)
                          buildTextField(
                            emailController,
                            'Email (tidak dapat diubah)',
                            Icons.email_outlined,
                            readOnly: true,
                          ),
                        if (isEditing) const SizedBox(height: 16),

                        buildTextField(
                          usernameController,
                          'Username',
                          Icons.person_add_alt_1_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(80),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isEditing
                                      ? "Jika ingin mengubah password, gunakan kombinasi huruf besar, kecil, angka, dan simbol (!@#\$) agar lebih aman."
                                      : "Gunakan kombinasi huruf besar, kecil, angka, dan simbol (!@#\$) untuk password yang kuat.",
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (isEditing) ...[
                          TextFormField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                            onChanged: (text) {
                              dialogSetState(() {});
                            },
                            decoration: InputDecoration(
                              labelText:
                                  'Reset Password (kosongkan jika tidak diubah)',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: passwordController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: Icon(
                                        isPasswordVisible
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        dialogSetState(() {
                                          isPasswordVisible =
                                              !isPasswordVisible;
                                        });
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (!isEditing) ...[
                          buildTextField(
                            passwordController,
                            'Password',
                            Icons.lock_person_rounded,
                            isObscure: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          buildTextField(
                            confirmPasswordController,
                            'Konfirmasi Password',
                            Icons.check_circle_outline_rounded,
                            isObscure: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password harus diisi';
                              }
                              if (value != passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        DropdownButtonFormField<Role>(
                          initialValue: selectedRole,
                          items: Role.values
                              .map(
                                (role) => DropdownMenuItem<Role>(
                                  value: role,
                                  child: Text(
                                    role.name[0].toUpperCase() +
                                        role.name.substring(1),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              dialogSetState(() => selectedRole = value);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: const Icon(Icons.security_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        buildGradientButton(
                          isEditing ? 'Simpan Perubahan' : 'Tambahkan Pengguna',
                          Icons.save_rounded,
                          () async {
                            final isValid =
                                formKey.currentState?.validate() ?? false;
                            if (!isValid) return;

                            try {
                              if (isEditing) {
                                final User editingUser = user;
                                await _adminService.updateUser(
                                  editingUser.id,
                                  username: usernameController.text,
                                  role: selectedRole,
                                );

                                if (passwordController.text.isNotEmpty) {
                                  final ok = await _adminService
                                      .updateUserPasswordHash(
                                        editingUser.id,
                                        passwordController.text,
                                      );
                                  if (!mounted) return;
                                  if (ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password pengguna diperbarui',
                                        ),
                                        backgroundColor: AppColors.accentGreen,
                                      ),
                                    );
                                  }
                                }

                                if (!mounted) return;
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pengguna berhasil diperbarui',
                                    ),
                                    backgroundColor: AppColors.accentGreen,
                                  ),
                                );
                              } else {
                                final created = await _adminService.createUser(
                                  emailController.text,
                                  passwordController.text,
                                  usernameController.text,
                                  selectedRole,
                                );

                                if (!mounted) return;

                                if (created != null) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pengguna berhasil dibuat'),
                                      backgroundColor: AppColors.accentGreen,
                                    ),
                                  );

                                  if (!mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          UserDetailScreen(userId: created.id),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: AppColors.accentRed,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER: MEMBUAT CARD USER (DIPISAH SUPAYA RAPI) ---
  Widget _buildUserCard(User user) {
    if (user.isDeleted == true) return const SizedBox.shrink();

    final isCurrentUser = user.id == widget.currentUser.id;

    return Opacity(
      opacity: user.isActive ? 1.0 : 0.5,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          leading: Icon(
            user.role == Role.admin
                ? Icons.shield_rounded
                : Icons.person_rounded,
            color: user.isActive ? AppColors.primary : Colors.grey,
            size: 40,
          ),
          title: Text(user.username, style: AppTextStyles.subtitle),
          subtitle: Text(
            '${user.role.name[0].toUpperCase()}${user.role.name.substring(1)} - ${user.isActive ? "Aktif" : "Nonaktif"}',
            style: AppTextStyles.body,
          ),
          trailing: isCurrentUser
              ? const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Chip(
                    label: Text('Anda'),
                    backgroundColor: AppColors.secondary,
                  ),
                )
              : PopupMenuButton<String>(
                  onSelected: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      if (value == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailScreen(userId: user.id),
                          ),
                        );
                      } else if (value == 'edit') {
                        _showUserFormDialog(user: user);
                      } else if (value == 'toggle') {
                        await _adminService.toggleUserStatus(user.id);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Status ${user.username} diubah'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Konfirmasi Hapus'),
                            content: Text(
                              'Anda yakin ingin menghapus ${user.username}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: AppColors.accentRed),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _adminService.softDeleteUser(user.id);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('${user.username} dihapus'),
                              backgroundColor: AppColors.accentGreen,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('Lihat Detail'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(
                          user.isActive ? Icons.toggle_off : Icons.toggle_on,
                        ),
                        title: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppColors.accentRed),
                        title: Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.accentRed),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: HEADER SECTION ---
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Expanded(child: Divider(indent: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pengguna')),
      // Menggunakan SingleChildScrollView agar bisa menampung 2 list di dalam Column
      body: StreamBuilder<List<User>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              message: 'Belum ada pengguna',
              icon: Icons.people_outline,
            );
          }

          final allUsers = snapshot.data!;

          // MEMISAHKAN LIST MENJADI 2 GRUP
          // Filter Admin
          final adminList = allUsers
              .where((u) => u.role == Role.admin && (u.isDeleted != true))
              .toList();

          // Filter Karyawan (Role selain admin)
          final employeeList = allUsers
              .where((u) => u.role != Role.admin && (u.isDeleted != true))
              .toList();

          return SingleChildScrollView(
            // Tambahkan padding bawah agar list paling bawah tidak tertutup FAB
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN 1: ADMIN ---
                if (adminList.isNotEmpty) ...[
                  _buildSectionHeader('Administrator', Icons.shield_rounded),
                  // Render list admin
                  ...adminList.map((user) => _buildUserCard(user)),
                ],

                // --- BAGIAN 2: KARYAWAN ---
                if (employeeList.isNotEmpty) ...[
                  _buildSectionHeader('Karyawan', Icons.group_rounded),
                  // Render list karyawan
                  ...employeeList.map((user) => _buildUserCard(user)),
                ],

                // State jika salah satu kosong tapi tidak dua-duanya
                if (adminList.isEmpty && employeeList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: EmptyStateWidget(
                      message: 'Tidak ada data aktif',
                      icon: Icons.search_off,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'user-management-fab',
        onPressed: () => _showUserFormDialog(),
        label: const Text('Tambah Pengguna'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
