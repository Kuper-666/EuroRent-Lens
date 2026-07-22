import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/update_checker.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/auth_provider.dart';
import 'main_shell.dart';

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Remote Config with defaults
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults({
    'groq_api_key': '',
    'latest_version': '',
    'update_url': '',
    'update_message': '',
  });

  runApp(const ProviderScope(child: EuroRentLensApp()));
}

class EuroRentLensApp extends ConsumerStatefulWidget {
  const EuroRentLensApp({super.key});

  @override
  ConsumerState<EuroRentLensApp> createState() => _EuroRentLensAppState();
}

class _EuroRentLensAppState extends ConsumerState<EuroRentLensApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.startPeriodicCheck(context);
    });
  }

  @override
  void dispose() {
    UpdateChecker.stopPeriodicCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'EuroRent Lens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.themeMode,
      home: authState.isAuthenticated
          ? const MainShell()
          : const LoginScreen(),
    );
  }
}
