import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User avatar and name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'Гость',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Auth method info
          _SectionHeader(title: 'Способ входа'),
          Card(
            child: ListTile(
              leading: Icon(
                user?.uid.startsWith('demo') ?? true
                    ? Icons.science_outlined
                    : Icons.g_mobiledata,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                user?.uid.startsWith('demo') ?? true
                    ? 'Демо-режим'
                    : 'Google-аккаунт',
              ),
              subtitle: Text(
                user?.uid.startsWith('demo') ?? true
                    ? 'Вход выполнен без привязки к аккаунту'
                    : 'Привязан к Google: ${user?.email ?? ""}',
              ),
            ),
          ),

          const SizedBox(height: 24),

          // App settings
          _SectionHeader(title: 'Настройки'),

          // Theme
          Card(
            child: SwitchListTile(
              secondary: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Тёмная тема'),
              subtitle: const Text('Автоматически по системе'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                // TODO: implement theme switching
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Тема переключается автоматически')),
                );
              },
            ),
          ),

          // Language
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Язык'),
              subtitle: const Text('Русский'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Выбор языка — в разработке')),
                );
              },
            ),
          ),

          // Notifications
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Уведомления'),
              subtitle: const Text('Push-уведомления о новых анализах'),
              value: true,
              onChanged: (value) {
                // TODO: implement notifications toggle
              },
            ),
          ),

          // About
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('О приложении'),
              subtitle: const Text('EuroRent Lens v1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'EuroRent Lens',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(
                    Icons.home_work,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  children: [
                    const Text(
                      'AI-анализ объявлений об аренде жилья в Европе.\n\n'
                      'Распознавание текста с фото, проверка цен, '
                      'скрытых платежей и рисков.',
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выйти из аккаунта?'),
                    content: const Text('Вы вернётесь на экран входа.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Выйти'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  ref.read(authProvider.notifier).signOut();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
