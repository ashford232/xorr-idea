import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xorr/data/providers/db_provider.dart';
import 'package:xorr/features/workspace/controllers/workspace_controller.dart';
import 'package:xorr/features/workspace/services/workspace_db_service.dart';
import 'package:xorr/features/workspace/models/app_directories.dart';
import 'package:xorr/features/workspace/notifiers/workspace_notifier.dart';

final appDirectoriesProvider = FutureProvider((ref) async {
  final docsDir = await getApplicationDocumentsDirectory();
  return AppDirectories(documentsDirectory: docsDir);
});

final workspaceProvider = AsyncNotifierProvider(WorkspaceNotifier.new);

final workspaceDbProvider = Provider(
  (ref) => WorkspaceDb(ref.watch(appDbProvider)),
);

final workspaceControllerProvider = Provider((ref) => WorkspaceController(workspaceDb: ref.watch(workspaceDbProvider)));

final getAllWorkspaceProvider = FutureProvider(
  (ref) => ref.watch(workspaceDbProvider).getAll(),
);
