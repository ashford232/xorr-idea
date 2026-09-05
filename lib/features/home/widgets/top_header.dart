import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/shared/consts/app_consts.dart';

class TopHeader extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${AppConsts.appName} ${AppConsts.appVersionName} ~ ${navigationState.currentItem?.name ?? "Getting Started"}',
        style: theme.textTheme.labelMedium?.copyWith(),
      ),
    );
  }
}
