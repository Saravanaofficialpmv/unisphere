import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/core/constants/app_colors.dart';
import 'package:clg_application/services/auth_service.dart';
import 'package:clg_application/navigation/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    final name = user?.name ?? 'Demo Student';
    final email = user?.email ?? 'student@unisphere.edu';
    final roleName = user?.role.name.toUpperCase() ?? 'STUDENT';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: onBack != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: onBack,
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$email • $roleName',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  _buildProfileTile(Icons.email_outlined, 'Email', email),
                  _buildProfileTile(Icons.phone_outlined, 'Phone', '+91 98765 43210'),
                  _buildProfileTile(Icons.school_outlined, 'Department', user?.metadata?['department'] ?? 'Computer Science & Eng'),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Settings'),
                  _buildProfileTile(Icons.notifications_none, 'Notifications', 'On', isAction: true),
                  _buildProfileTile(Icons.lock_outline, 'Privacy Policy', '', isAction: true),
                  _buildProfileTile(Icons.help_outline, 'Help & Support', '', isAction: true),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ref.read(authServiceProvider).signOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.error, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value, {bool isAction = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        subtitle: value.isNotEmpty
            ? Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold))
            : null,
        trailing: isAction ? const Icon(Icons.chevron_right, color: AppColors.textTertiary) : null,
      ),
    );
  }
}
