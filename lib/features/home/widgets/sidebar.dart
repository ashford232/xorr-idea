import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/models/user_model.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/home/models/navigation_item.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/shared/extensions/cached_image.dart';

class Sidebar extends ConsumerWidget {
  final UserModel userModel;
  const Sidebar({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationStateNotifier = ref.watch(navigationStateProvider.notifier);
    final theme = Theme.of(context);
    final defaultNavs = navigationState.defaultItems;
    final currentNavId = navigationState.currentItem?.id;

    void changeNav(NavigationItem nav) {
      navigationStateNotifier.chnageNav(nav);
    }

    return Container(
      width: 320,
      height: .infinity,
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Column(
        children: [
          // user
          Material(
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (userModel.photoUrl != null)
                      cachedImage(
                        imageUrl: userModel.photoUrl!,
                        borderRadius: 25,
                        size: Size(50, 50),
                      ),
                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          userModel.username ?? "XorrUser",
                          style: TextStyle(fontWeight: .bold),
                        ),
                        Text(userModel.email, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          ListView.separated(
            separatorBuilder: (context, index) =>
                index == 2 || index == 5 ? Divider() : const SizedBox.shrink(),
            padding: const EdgeInsets.all(5),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: defaultNavs.length,
            itemBuilder: (context, index) {
              final nav = defaultNavs[index];
              final navIcon = nav.icon;
              final navName = nav.name;
              final navId = nav.id;
              final navColor = nav.color;

              final isSelected = navId == currentNavId;
              return sidebarCard(
                onPressed: currentNavId == navId
                    ? null
                    : () {
                        changeNav(nav);
                      },
                text: navName,
                icon: navIcon!,
                color: isSelected ? theme.colorScheme.outline : null,
                iconColor:
                    navColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.75),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(5),

            child: Column(
              children: [
                sidebarCard(
                  text: 'Logout',
                  icon: Icons.logout,
                  onPressed: () {
                    ref.read(authRepositoryProvider).logout();
                    ref.invalidate(getUserProvider);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget sidebarCard({
  VoidCallback? onPressed,
  Color? color,
  Color? iconColor,
  required String text,
  required IconData icon,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),

            color: color,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Text(text),
            ],
          ),
        ),
      ),
    ),
  );
}
