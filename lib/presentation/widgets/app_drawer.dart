import 'package:flutter/material.dart';
import '../../state/theme_state.dart';
import 'package:flutter/services.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const AppDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(height: 0),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('General', style: Theme.of(context).textTheme.titleLarge),
            ),
            _DrawerTile(
              icon: Icons.info_outline_rounded,
              label: 'About',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Money Tracker',
                  applicationVersion: '1.0.0',
                  applicationIcon: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                  children: [
                    const SizedBox(height: 8),
                    const Text('Aplikasi pencatat keuangan sederhana.'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.open_in_new, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText('https://github.com/Ahmadr127/',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            _DrawerTile(
              icon: Icons.link_rounded,
              label: 'GitHub',
              onTap: () async {
                // Salin URL ke clipboard (tanpa dependency tambahan)
                await Clipboard.setData(const ClipboardData(text: 'https://github.com/Ahmadr127/'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link GitHub disalin ke clipboard')),
                  );
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              value: appThemeState.isDarkMode,
              onChanged: (_) => appThemeState.toggleTheme(),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        surfaceTintColor: Colors.transparent,
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                  if (shouldLogout == true) {
                    // Tutup drawer lebih dulu
                    Navigator.of(context).maybePop();
                    onLogout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.account_balance_wallet, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Money Tracker', style: Theme.of(context).textTheme.titleLarge),
              Text('v1.0.0', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}


