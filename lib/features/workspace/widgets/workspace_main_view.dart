import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/workspace/notifiers/workspace_notifier.dart';
import 'package:xorr/features/workspace/provider/workspace_provider.dart';
import 'package:xorr/features/workspace/widgets/file_icon.dart';
import 'package:xorr/shared/ui/loaders.dart';
import 'package:path/path.dart' as p;

class WorkspaceMainView extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<WorkspaceMainView> createState() => _WorkspaceMainViewState();
}

class _WorkspaceMainViewState extends ConsumerState<WorkspaceMainView> {
  final Map<String, GlobalKey> tabKeys = {};

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(workspaceProvider);
    final wn = ref.watch(workspaceProvider.notifier);

    final theme = Theme.of(context);

    ref.listen(workspaceProvider.select((state) => state.value?.file), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = tabKeys[next]?.currentContext;

        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: 0.5,
          );
        }
      });
    });
    return workspaceState.when(
      data: (ws) {
        if (ws == null) {
          return SizedBox();
        }
        final openedTabs = ws.openEntities;
        final currentTab = wn.filePath;

        return Column(
          children: [
            // tabs

            if (openedTabs.isNotEmpty)
              SizedBox(
                height: 45,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 5),
                    scrollDirection: .horizontal,
                    itemBuilder: (context, index) {
                      final tab = openedTabs[index];
                      final key = tabKeys.putIfAbsent(tab, () => GlobalKey());

                      final bool isCurrent = tab == currentTab;
                      return KeyedSubtree(
                        key: key,
                        child: tabCard(
                          isCurrent,
                          theme,
                          ref,
                          tab,
                          ws.workspace.path,
                          wn,
                        ),
                      );
                    },
                    itemCount: openedTabs.length,
                  ),
                ),
              ),
            Divider(height: 1),

            //tabs view
            if (openedTabs.isNotEmpty)
              Expanded(child: Center(child: Text(currentTab ?? ""))),
          ],
        );
      },
      error: (err, st) => Center(child: Text(err.toString())),
      loading: () => Center(child: appLoader()),
    );
  }

  Row tabCard(
    bool isCurrent,
    ThemeData theme,
    WidgetRef ref,
    String tab,
    String base,
    WorkspaceNotifier wn,
  ) {
    return Row(
      mainAxisSize: .min,
      children: [
        Material(
          child: InkWell(
            borderRadius: .circular(8),
            onTap: () {
              if (!isCurrent) {
                wn.changePath(path: tab, file: true);
              }
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: .circular(8),
                color: isCurrent ? theme.colorScheme.outline : null,
              ),
              child: Row(
                children: [
                  FileSystemIcon(extension: p.extension(tab)),
                  const SizedBox(width: 5),
                  Text(
                    p.relative(tab, from: base),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14,
                      color: isCurrent
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 5),
                  iconAction(
                    icon: Icons.close,
                    name: 'close',
                    onPressed: () {
                      wn.closeTab(tab);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget iconAction({
  String? name,
  required IconData icon,
  VoidCallback? onPressed,
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,

    child: Tooltip(
      message: name ?? "",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: .circular(25),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Icon(icon, size: 16),
          ),
        ),
      ),
    ),
  );
}
