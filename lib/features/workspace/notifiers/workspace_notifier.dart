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
    _folder = workspace.path;

    return WorkspaceState(
      workspace: workspace,
      entities: entities,
      selectedEntity: state.value?.selectedEntity ?? workspace.path,
    );
  }

  String? _folder;

  String? get folder => _folder ?? state.value?.workspace.path;

  void setFolder(String path) {
    _folder = path;
  }

  void changePath(String path) {
    state = AsyncValue.data(state.value?.copyWith(selectedEntity: path));
  }

  void changeFolder(String path) {
    state = AsyncValue.data(state.value?.copyWith(selectedEntity: path));
    _folder = path;
  }
}

class WorkspaceState {
  final Workspace workspace;
  final List<FileSystemEntity> entities;
  final String? selectedEntity;
  WorkspaceState({
    required this.workspace,
    required this.entities,
    this.selectedEntity,
  });

  WorkspaceState copyWith({
    Workspace? workspace,
    List<FileSystemEntity>? entities,
    String? selectedEntity,
  }) {
    return WorkspaceState(
      workspace: workspace ?? this.workspace,
      entities: entities ?? this.entities,
      selectedEntity: selectedEntity ?? this.selectedEntity,
    );
  }
}
