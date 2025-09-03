import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class ProfilePage extends StatelessWidget {
  final UserModel? currentUser;

  const ProfilePage({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    // Colors derive from theme directly where needed
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: primary.withOpacity(0.15),
                        child: Text(
                          (currentUser?.fullName?.substring(0, 1) ?? 'U').toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser?.fullName ?? 'User',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentUser?.email ?? 'user@example.com',
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Pengaturan Akun', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _ProfileTile(
                icon: Icons.person_outline,
                color: primary,
                title: 'Edit Profil',
                subtitle: 'Ubah informasi profil',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.lock_outline,
                color: Colors.orange,
                title: 'Keamanan',
                subtitle: 'Ubah password dan keamanan',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              Text('Bantuan', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _ProfileTile(
                icon: Icons.help_outline,
                color: Colors.blue,
                title: 'Pusat Bantuan',
                subtitle: 'Panduan penggunaan aplikasi',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.info_outline,
                color: Colors.teal,
                title: 'Tentang Aplikasi',
                subtitle: 'Versi dan informasi aplikasi',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
      ),
    );
  }
}


