import 'package:flutter/material.dart';
import 'package:xorr/shared/theme/app_fonts.dart';

class DesktopSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 22,
                  color: Theme.of(context).colorScheme.surface,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 16,
                    fontFamily: AppFonts.inter,
                  ),
                ),
              ),
            ],
          ),
          action: action,
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, icon: Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, icon: Icons.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, icon: Icons.info);
  }
}
