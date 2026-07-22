import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static Timer? _timer;
  static bool _dialogShown = false;
  static const _checkInterval = Duration(minutes: 30);
  static const _lastShownKey = 'update_dialog_last_shown';

  /// Start periodic update checks (call once at app startup)
  static void startPeriodicCheck(BuildContext context) {
    // Initial check after 5 seconds (let app fully load)
    Future.delayed(const Duration(seconds: 5), () {
      _checkForUpdate(context);
    });

    // Then check every 30 minutes
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) {
      _checkForUpdate(context);
    });
  }

  /// Stop periodic checks
  static void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check for updates (internal method with deduplication)
  static Future<void> _checkForUpdate(BuildContext context) async {
    if (_dialogShown) return;
    if (!context.mounted) return;

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();

      final latestVersion = remoteConfig.getString('latest_version');
      final updateUrl = remoteConfig.getString('update_url');
      final updateMessage = remoteConfig.getString('update_message');

      if (latestVersion.isEmpty) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (!_isNewerVersion(latestVersion, currentVersion)) return;

      // Check if we already showed this version's dialog recently
      final prefs = await SharedPreferences.getInstance();
      final lastShownVersion = prefs.getString(_lastShownKey);
      if (lastShownVersion == latestVersion) return;

      // Mark as shown for this version
      await prefs.setString(_lastShownKey, latestVersion);

      if (context.mounted) {
        _dialogShown = true;
        _showUpdateDialog(context, latestVersion, updateMessage, updateUrl);
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  /// One-time check (for manual refresh)
  static Future<void> checkOnce(BuildContext context) async {
    _dialogShown = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastShownKey);
    await _checkForUpdate(context);
  }

  /// Compare version strings (e.g. "1.2.3" vs "1.2.0")
  static bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.tryParse).toList();
    final currentParts = current.split('.').map(int.tryParse).toList();

    for (var i = 0; i < latestParts.length; i++) {
      final l = latestParts[i] ?? 0;
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String message,
    String url,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.system_update, size: 48, color: Color(0xFF2196F3)),
        title: const Text('Доступно обновление'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Версия $version',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty
                  ? message
                  : 'Обновите приложение для получения новых функций и исправлений.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (url.isNotEmpty) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            child: const Text('Обновить'),
          ),
        ],
      ),
    ).then((_) => _dialogShown = false);
  }
}
