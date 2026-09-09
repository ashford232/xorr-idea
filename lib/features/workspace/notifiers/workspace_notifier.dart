import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xorr/data/db/app_db.dart';
import 'package:xorr/features/workspace/provider/workspace_provider.dart';

class WorkspaceNotifier extends AsyncNotifier<WorkspaceState?> {
  @override
  Future<WorkspaceState?> build() async {
    final workspaceDb = ref.read(workspaceDbProvider);
    final workspaceController = ref.read(workspaceControllerProvider);
    final workspace = await workspaceDb.getLatestOpened();

    if (workspace == null) {
      return null;
    }

    final directory = Directory(workspace.path);

    if (!await directory.exists()) {
      return null;
    }

    final entities = await workspaceController.getFileSystemEntity(
      workspace.path,
    );

    return WorkspaceState(workspace: workspace, entities: entities);
  }
}

class WorkspaceState {
  final Workspace workspace;
  final List<FileSystemEntity> entities;
  WorkspaceState({required this.workspace, required this.entities});

  WorkspaceState copyWith({
    Workspace? workspace,
    List<FileSystemEntity>? entities,
  }) {
    return WorkspaceState(
      workspace: workspace ?? this.workspace,
      entities: entities ?? this.entities,
    );
  }
}
