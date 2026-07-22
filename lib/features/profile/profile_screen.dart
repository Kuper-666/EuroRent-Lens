import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _linkedTelegramId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTelegramLink();
  }

  Future<void> _loadTelegramLink() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _linkedTelegramId = prefs.getString('linked_telegram_id');
      _isLoading = false;
    });
  }

  Future<void> _linkTelegram() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Привязать Telegram'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите ваш Telegram user ID.\n\n'
              'Чтобы узнать ID:\n'
              '1. Откройте @userinfobot в Telegram\n'
              '2. Нажмите Start\n'
              '3. Скопируйте числовой ID',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '123456789',
                labelText: 'Telegram User ID',
                prefixIcon: Icon(Icons.tag),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = controller.text.trim();
              if (id.isNotEmpty && int.tryParse(id) != null) {
                Navigator.pop(context, id);
              }
            },
            child: const Text('Привязать'),
          ),
        ],
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('linked_telegram_id', result);
      setState(() => _linkedTelegramId = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telegram привязан!')),
        );
      }
    }
  }

  Future<void> _unlinkTelegram() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отвязать Telegram?'),
        content: const Text('Баланс и лимиты будут отвязаны от этого аккаунта.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Отвязать'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('linked_telegram_id');
      setState(() => _linkedTelegramId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telegram отвязан')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User avatar and name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF2196F3),
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Auth method
                _SectionHeader(title: 'Способ входа'),
                Card(
                  child: ListTile(
                    leading: Icon(
                      user?.uid.startsWith('demo') ?? true
                          ? Icons.science_outlined
                          : Icons.g_mobiledata,
                      color: const Color(0xFF2196F3),
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

                // Telegram linking
                _SectionHeader(title: 'Привязка Telegram'),
                Card(
                  child: _linkedTelegramId != null
                      ? ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: const Text('Telegram привязан'),
                          subtitle: Text('ID: $_linkedTelegramId'),
                          trailing: TextButton(
                            onPressed: _unlinkTelegram,
                            child: const Text('Отвязать', style: TextStyle(color: Colors.red)),
                          ),
                        )
                      : ListTile(
                          leading: const Icon(Icons.telegram, color: Color(0xFF2196F3)),
                          title: const Text('Привязать Telegram'),
                          subtitle: const Text('Для синхронизации баланса с ботом'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _linkTelegram,
                        ),
                ),

                const SizedBox(height: 24),

                // App settings
                _SectionHeader(title: 'Настройки'),

                // Theme toggle
                Card(
                  child: SwitchListTile(
                    secondary: Icon(
                      ref.watch(themeProvider).themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    title: const Text('Тёмная тема'),
                    subtitle: Text(
                      ref.watch(themeProvider).themeMode == ThemeMode.system
                          ? 'Следовать за системой'
                          : ref.watch(themeProvider).themeMode == ThemeMode.dark
                              ? 'Включена'
                              : 'Выключена',
                    ),
                    value: ref.watch(themeProvider).themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ),

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

                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Уведомления'),
                    subtitle: const Text('Push-уведомления о новых анализах'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ),

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
                        applicationIcon: const Icon(
                          Icons.home_work,
                          size: 48,
                          color: Color(0xFF2196F3),
                        ),
                        children: const [
                          Text(
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
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF2196F3),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
