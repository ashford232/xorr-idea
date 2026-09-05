import 'package:flutter/material.dart';

class DesktopDialogs {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (cancelText != null)
              TextButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(cancelText),
              ),
            FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(20)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return show(context, title: title, message: message, confirmText: 'OK');
  }

  static Future<void> error(
    BuildContext context, {
    String title = 'Opps',
    required String message,
  }) {
    return show(context, title: title, message: message, confirmText: 'OK');
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(20)),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(20)),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
