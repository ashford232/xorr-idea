import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/auth/views/login_view.dart';
import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/shared/consts/app_consts.dart';
import 'package:xorr/shared/extensions/app_router.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final theme = Theme.of(context);

    final defaultNavs = navigationState.defaultItems;
    final currentNavId = navigationState.currentItem?.id;
    final bool toggled = navigationState.toggled;
    final userSync = ref.watch(getUserProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      width: toggled ? 57.0 : 220.0,
      height: double.infinity,
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Column(
            crossAxisAlignment: .start,
            children: [
              if (!toggled)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Text(
                    AppConsts.appName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: .bold,
                    ),
                  ),
                ),

              userSync.when(
                data: (user) {
                  final workspace = DefaultNavigationData.workspace;
                  final localWorkspace = DefaultNavigationData.localWorkspace;

                  return Column(
                    children: [
                      if (user.user != null) ...[
                        SidebarCard(
                          text: workspace.name,
                          icon: workspace.icon!,
                          toggled: toggled,
                          isSelected: currentNavId == workspace.id,

                          onPressed: () {
                            ref
                                .read(navigationStateProvider.notifier)
                                .chnageNav(workspace);
                          },
                        ),
                      ],

                      //
                      buildLocalWorkspage(
                        localWorkspace,
                        toggled,
                        currentNavId,
                        ref,
                        theme,
                      ),
                    ],
                  );
                },
                error: (_, _) {
                  final localWorkspace = DefaultNavigationData.localWorkspace;
                  return buildLocalWorkspage(
                    localWorkspace,
                    toggled,
                    currentNavId,
                    ref,
                    theme,
                  );
                },
                loading: () => SidebarCard(
                  text: "Loading",
                  icon: Icons.local_activity,
                  toggled: toggled,
                ),
              ),
            ],
          ),

          Expanded(
            child: ListView.separated(
              itemCount: defaultNavs.length,
              separatorBuilder: (context, index) {
                if (index == 2 || index == 5) {
                  return const Divider(height: 1);
                }
                return const SizedBox(height: 1);
              },
              itemBuilder: (context, index) {
                final nav = defaultNavs[index];
                final isSelected = nav.id == currentNavId;

                return SidebarCard(
                  text: nav.name,
                  icon: nav.icon ?? Icons.circle_outlined,
                  toggled: toggled,
                  isSelected: isSelected,

                  onPressed: isSelected
                      ? null
                      : () {
                          ref
                              .read(navigationStateProvider.notifier)
                              .chnageNav(nav);
                        },
                );
              },
            ),
          ),
          userSync.when(
            data: (user) {
              if (user.user == null) {
                return SidebarCard(
                  text: 'Login',
                  icon: CupertinoIcons.person,
                  toggled: toggled,
                  onPressed: () {
                    AppRouter.push(LoginView());
                  },
                );
              }
              return Column(
                children: [
                  Column(
                    children: [
                      SidebarCard(
                        text: 'Logout',
                        icon: Icons.logout,
                        toggled: toggled,
                        onPressed: () {
                          ref.invalidate(getUserProvider);
                          ref.read(authRepositoryProvider).logout();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
            error: (_, _) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          Align(
            alignment: toggled ? Alignment.center : Alignment.centerRight,
            child: IconButton(
              tooltip: toggled ? 'Expand' : 'Collapse',
              onPressed: () {
                ref.read(navigationStateProvider.notifier).toggle();
              },
              icon: Icon(
                toggled
                    ? CupertinoIcons.sidebar_left
                    : CupertinoIcons.sidebar_right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SidebarCard buildLocalWorkspage(
    NavigationItem localWorkspace,
    bool toggled,
    int? currentNavId,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return SidebarCard(
      text: localWorkspace.name,
      icon: localWorkspace.icon!,
      toggled: toggled,
      isSelected: localWorkspace.id == currentNavId,
      onPressed: () {
        ref.read(navigationStateProvider.notifier).chnageNav(localWorkspace);
      },
    );
  }
}

class SidebarCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool toggled;
  final bool isSelected;
  final VoidCallback? onPressed;

  const SidebarCard({
    super.key,
    required this.text,
    required this.icon,
    required this.toggled,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.surfaceContainerHighest;
    final activeTextColor = theme.colorScheme.onPrimaryContainer;

    return Tooltip(
      message: toggled ? text : '',
      child: Material(
        color: isSelected ? activeColor : Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            child: Row(
              mainAxisAlignment: toggled
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: toggled ? 25 : 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                if (!toggled) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? activeTextColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
