import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/models/user_model.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/shared/consts/app_consts.dart';
import 'package:xorr/shared/extensions/cached_image.dart';
import 'package:xorr/shared/ui/loaders.dart';

class BottomContent extends ConsumerWidget {
  const BottomContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationStateNotifier = ref.watch(navigationStateProvider.notifier);
    final userAsync = ref.watch(getUserProvider);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(
            '${AppConsts.appName} ${AppConsts.appVersionName} ~ ${navigationState.currentItem?.name ?? "Getting Started"}',
            style: theme.textTheme.labelMedium?.copyWith(),
          ),

          userAsync.when(
            data: (user) {
              if (user.user == null) {
                return Text('Local');
              }
              return _UserProfileTile(
                userModel: user.user!,
                onTap: () {
                  final nav = DefaultNavigationData.account;
                  navigationStateNotifier.chnageNav(
                    nav.copyWith(emoji: () => user.user?.photoUrl),
                  );
                },
              );
            },
            error: (_, _) => const SizedBox.shrink(),
            loading: () => appLoader(size: 10),
          ),
        ],
      ),
    );
  }
}

class _UserProfileTile extends StatelessWidget {
  final UserModel userModel;
  final VoidCallback onTap;

  const _UserProfileTile({required this.userModel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Tooltip(
        message: userModel.email,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  if (userModel.photoUrl != null)
                    CircleAvatar(
                      radius: 13,
                      child: cachedImage(
                        imageUrl: userModel.photoUrl!,
                        borderRadius: 20,
                        size: const Size(20, 20),
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        (userModel.username?.isNotEmpty == true)
                            ? userModel.username![0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userModel.username ?? userModel.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
