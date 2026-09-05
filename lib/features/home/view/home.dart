import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/auth/wrappers/auth_wrapper.dart';
import 'package:xorr/features/home/widgets/main_content.dart';
import 'package:xorr/features/home/widgets/sidebar.dart';
import 'package:xorr/features/home/widgets/top_header.dart';
import 'package:xorr/shared/ui/loaders.dart';

class Home extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSync = ref.watch(getUserProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      body: userSync.when(
        data: (user) {
          if (user.user == null) {
            return AuthWrapper();
          }
          return Row(
            children: [
              Sidebar(userModel: user.user!),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    TopHeader(),
                    Expanded(child: MainContent()),
                  ],
                ),
              ),
            ],
          );
        },
        error: (err, st) => Center(child: Text(err.toString())),
        loading: () => Center(child: appLoader()),
      ),
    );
  }
}
