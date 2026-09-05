import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/features/home/view/default_view.dart';

class MainContent extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: navigationState.currentItem?.page ?? DefaultView(),
      ),
    );
  }
}
