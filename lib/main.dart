import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/config/startup_config.dart';
import 'package:xorr/features/auth/wrappers/auth_wrapper.dart';
import 'package:xorr/shared/theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StartupConfig.setWindow();
  runApp(const ProviderScope(child: Xorr()));
}

class Xorr extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: .system,
      title: "Xorr Desktop",
    );
  }
}
