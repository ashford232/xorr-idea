import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/home/data/navigation/default_navigation_data.dart';
import 'package:xorr/features/home/providers/navigation_provider.dart';
import 'package:xorr/features/home/widgets/sidebar.dart';
import 'package:xorr/features/home/widgets/bottom_content.dart';

class Home extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigation = ref.watch(navigationStateProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: .antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: .only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: IndexedStack(
                      index: getPageIndex(
                        navigation.currentItem?.id ??
                            DefaultNavigationData.getDefaultItems[0].id,
                      ),
                      children: [
                        ...DefaultNavigationData.getDefaultItems.map(
                          (i) => i.page!,
                        ),
                      ],
                    ),
                  ),
                ),
                //   Divider(height: 1),
                BottomContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
