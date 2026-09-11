import 'package:flutter/material.dart';
import 'package:xorr/shared/theme/app_fonts.dart';

class DefaultView extends StatelessWidget {
  const DefaultView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color onSurface(double? a) {
      return theme.colorScheme.onSurface.withValues(alpha: a ?? 0.7);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A simple workspace for your ideas, notes, projects, and files',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFamily: AppFonts.inter,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Your workspace for notes, ideas, and files.',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: onSurface(0.8),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Get started',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Write down your ideas and thoughts\n'
                'Organize everything in your workspace\n'
                'Add files and keep everything together',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: onSurface(0.8),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Quick shortcuts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Shortcut(keys: ['Ctrl', 'N'], description: 'New idea'),
              const Shortcut(keys: ['Ctrl', 'O'], description: 'Open file'),
              const Shortcut(keys: ["Ctrl", " F"], description: 'Search'),
              const Shortcut(keys: ['Ctrl', 'S'], description: 'Save'),
              const Shortcut(
                keys: ["Ctrl", "Alt", " S"],
                description: 'Open Settings',
              ),

              const Shortcut(
                keys: ['Ctrl', 'Alt', 'F'],
                description: 'Open Starred',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Shortcut extends StatelessWidget {
  final List<String> keys;
  final String description;

  const Shortcut({super.key, required this.keys, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color onSurface(double? a) {
      return theme.colorScheme.onSurface.withValues(alpha: a ?? 0.7);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),

      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: .center,
            mainAxisAlignment: .spaceBetween,

            children: [
              SizedBox(
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      Align(child: Text(' + ')),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: .horizontal,
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    return Container(
                      alignment: .center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: .circular(4),
                        color: theme.colorScheme.surfaceContainerHigh,
                      ),
                      child: Text(
                        key,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: onSurface(0.8),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),

              Flexible(
                child: Text(description, overflow: .ellipsis, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
