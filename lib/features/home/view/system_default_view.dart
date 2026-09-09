import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/features/home/view/default_view.dart';
import 'package:xorr/features/workspace/provider/workspace_provider.dart';
import 'package:xorr/shared/ui/loaders.dart';

class SystemDefaultView extends ConsumerWidget {
  const SystemDefaultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final workspacesAsync = ref.watch(getAllWorkspaceProvider);

    final dbController = ref.watch(workspaceControllerProvider);

    final navigationStateNotifier = ref.read(navigationStateProvider.notifier);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,

                    borderRadius: .circular(12),
                  ),
                  width: 100,
                  height: 100,
                  child: Icon(
                    CupertinoIcons.lightbulb_fill,
                    size: 54,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                const SizedBox(height: 32),
                workspacesAsync.when(
                  data: (ws) {
                    if (ws.isEmpty) {
                      return SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text('Recent Workspaces'),
                        const SizedBox(height: 5),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ws.length,
                          itemBuilder: (context, index) {
                            final workspace = ws[index];

                            return Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(
                                  workspace.name,
                                  style: theme.textTheme.labelLarge?.copyWith(),
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await dbController.openWorkspace(
                                        wsPath: workspace.path,
                                      );
                                      ref.invalidate(getAllWorkspaceProvider);
                                      ref.invalidate(workspaceProvider);
                                      navigationStateNotifier.chnageNav(
                                        DefaultNavigationData.localWorkspace,
                                      );
                                    },
                                    child: Text(
                                      workspace.path,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                            decoration: .underline,
                                            fontWeight: .w300,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                  error: (err, st) => Center(child: Text(err.toString())),
                  loading: () => Center(child: appLoader()),
                ),
                const SizedBox(height: 30),
                Text('Shortcuts'),

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
