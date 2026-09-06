import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xorr/features/auth/provider/auth_provider.dart';
import 'package:xorr/features/auth/views/setup_user.dart';
import 'package:xorr/features/auth/wrappers/sync_wrapper.dart';
import 'package:xorr/features/home/view/home.dart';
import 'package:xorr/shared/ui/loaders.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(getUserProvider);

    return Scaffold(
      body: userAsync.when(
        data: (user) {
          if (user.user == null) {
            return Home();
          }

          if (user.user!.username == null || user.user!.username == "") {
            return SetupView(user: user.user!);
          }
          return SyncWrapper();
        },
        error: (err, st) => Center(child: Text(err.toString())),
        loading: () => Center(
          child: appLoader(
            size: 40,
            color: Theme.of(context).colorScheme.onSurface,
            strokeWidth: 5,
          ),
        ),
      ),
    );
  }
}
