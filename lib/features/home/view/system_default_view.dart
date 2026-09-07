import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xorr/features/home/view/default_view.dart';
import 'package:xorr/shared/theme/app_fonts.dart';

class SystemDefaultView extends StatelessWidget {
  const SystemDefaultView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(
                    CupertinoIcons.lightbulb,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Xorr IDEA',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: AppFonts.inter,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 28),
                const SizedBox(height: 32),

                const SizedBox(height: 12),

                Align(
                  alignment: .bottomCenter,
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      const Shortcut(
                        keys: ['Ctrl', 'N'],
                        description: 'New idea',
                      ),
                      const Shortcut(
                        keys: ['Ctrl', 'O'],
                        description: 'Open file',
                      ),
                      const Shortcut(
                        keys: ["Ctrl", " F"],
                        description: 'Find ideas',
                      ),
                      const Shortcut(keys: ['Ctrl', 'S'], description: 'Save'),
                      const Shortcut(
                        keys: ["Ctrl", "Alt", " S"],
                        description: 'Open Settings',
                      ),
                      const Shortcut(
                        keys: ["Ctrl", "Alt", " T"],
                        description: 'Open Trash',
                      ),
                      const Shortcut(
                        keys: ['Ctrl', 'Alt', 'F'],
                        description: 'Open Starred',
                      ),
                      const Shortcut(
                        keys: ['Ctrl', 'Alt', 'A'],
                        description: 'Open Archive',
                      ),
                    ],
                  ),
                ),

                Text(
                  'Open a tab to get started',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
