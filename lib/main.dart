import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/config/startup_config.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/auth/wrappers/auth_wrapper.dart';
import 'package:xorr/shared/extensions/app_router.dart';
import 'package:xorr/shared/theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StartupConfig.setWindow();
  runApp(const ProviderScope(child: Xorr()));
}

class Xorr extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(getUserProvider);
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: .light,
      title: "Xorr IDEA",
    );
  }
}
