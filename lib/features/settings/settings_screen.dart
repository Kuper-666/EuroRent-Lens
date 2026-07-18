import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLang = 'ru';
  String _selectedCity = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          // Profile section
          if (authState.user != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: authState.user!.photoURL != null
                          ? NetworkImage(authState.user!.photoURL!)
                          : null,
                      child: authState.user!.photoURL == null
                          ? Text(
                              (authState.user!.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 20),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user!.displayName ?? 'Пользователь',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            authState.user!.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(),

          // Language selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Язык анализа',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...AppConstants.supportedLanguages.entries.map(
            (entry) => RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedLang,
              onChanged: (val) => setState(() => _selectedLang = val!),
            ),
          ),

          const Divider(),

          // City filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Фильтр по городу',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioListTile<String>(
            title: const Text('Все города'),
            value: '',
            groupValue: _selectedCity,
            onChanged: (val) => setState(() => _selectedCity = val!),
          ),
          ...AppConstants.popularCities.entries.map(
            (entry) => RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedCity,
              onChanged: (val) => setState(() => _selectedCity = val!),
            ),
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            subtitle: const Text('EuroRent Lens v1.0.0'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'EuroRent Lens',
              applicationVersion: '1.0.0',
              applicationIcon: Icon(
                Icons.home_work,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              children: const [
                Text('AI-анализ объявлений об аренде в Европе.\n\n'
                    'Использует ML Kit для распознавания текста '
                    'и Groq AI для анализа.'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Выйти из аккаунта',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти?'),
        content: const Text('Вы выйдете из аккаунта Google.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
