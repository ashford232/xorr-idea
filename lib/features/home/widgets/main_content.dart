import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/models/tab_model.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/features/home/view/system_default_view.dart';
import 'package:xorr/shared/extensions/cached_image.dart';

class MainContent extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<MainContent> createState() => _MainContentState();
}

class _MainContentState extends ConsumerState<MainContent> {
  final Map<int, GlobalKey> tabKeys = {};

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationStateProvider);

    final openedTabsSet = navigationState.openedTabs;

    final currentTab = navigationState.currentTab;
    final theme = Theme.of(context);
    final openedTabs = openedTabsSet.toList().reversed.toList();
    ref.listen(
      navigationStateProvider.select((state) => state.currentTab?.id),
      (previous, next) {
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
      },
    );
    return Column(
      children: [
        // tabs

        if (openedTabs.isNotEmpty)
          SizedBox(
            height: 45,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 5),
                scrollDirection: .horizontal,
                itemBuilder: (context, index) {
                  final tab = openedTabs[index];
                  final key = tabKeys.putIfAbsent(tab.id, () => GlobalKey());

                  final bool isCurrent = tab.id == currentTab?.id;
                  return KeyedSubtree(
                    key: key,
                    child: tabCard(isCurrent, theme, ref, tab),
                  );
                },
                itemCount: openedTabs.length,
              ),
            ),
          ),
        Divider(height: 1),

        //tabs view
        if (openedTabs.isNotEmpty) Expanded(child: currentTab!.item),

        if (openedTabs.isEmpty) Expanded(child: SystemDefaultView()),
      ],
    );
  }

  Row tabCard(bool isCurrent, ThemeData theme, WidgetRef ref, TabModel tab) {
    final navigationStateNotifier = ref.watch(navigationStateProvider.notifier);
    return Row(
      mainAxisSize: .min,
      children: [
        Material(
          child: InkWell(
            borderRadius: .circular(8),
            onTap: () {
              final items = [
                ...DefaultNavigationData.getDefaultItems,
                DefaultNavigationData.gettingStated,
                DefaultNavigationData.localWorkspace,
                DefaultNavigationData.workspace,
                DefaultNavigationData.account,
              ];

              final nav = items.firstWhere((n) => n.id == tab.id);
              navigationStateNotifier.chnageNav(nav);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: .circular(8),
                color: isCurrent ? theme.colorScheme.outline : null,
              ),
              child: Row(
                children: [
                  if (tab.id == DefaultNavigationData.account.id &&
                      tab.emoji != null) ...[
                    cachedImage(imageUrl: tab.emoji!, size: Size(15, 15)),
                  ] else
                    Icon(
                      tab.icon,
                      size: 15,
                      fontWeight: isCurrent ? .w600 : .w300,
                    ),
                  const SizedBox(width: 5),
                  Text(
                    tab.name,
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
                      navigationStateNotifier.closeTab(tab);
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
