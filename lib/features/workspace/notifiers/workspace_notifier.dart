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

    return WorkspaceState(
      workspace: workspace,
      entities: entities,
      selectedEntity: state.value?.selectedEntity ?? workspace.path,
      openEntities: state.value?.openEntities ?? [],
      file: state.value?.file,
      folder: state.value?.folder,
    );
  }

  String? get folderPath => state.value?.folder ?? state.value?.workspace.path;
  String? get filePath => state.value?.file;

  void setFolder(String path) {
    state = AsyncValue.data(state.value?.copyWith(folder: path));
  }

  void setFile(String? path) {
    state = AsyncValue.data(state.value?.copyWith(file: path));
  }

  void changePath({required String path, bool file = false}) {
    final tabs = state.value?.openEntities ?? [];
    if (file) {
      setFile(path);
    }
    if (!tabs.contains(path)) {
      state = AsyncValue.data(
        state.value?.copyWith(
          selectedEntity: path,
          openEntities: [...tabs, path],
        ),
      );
    } else {
      state = AsyncValue.data(state.value?.copyWith(selectedEntity: path));
    }
  }

  void closeTab(String path) {
    final tabs = state.value?.openEntities ?? [];
    if (tabs.contains(path)) {
      tabs.remove(path);
      final rTab = tabs.isEmpty ? null : tabs.first;
      setFile(rTab);
      state = AsyncValue.data(
        state.value?.copyWith(
          selectedEntity: rTab ?? state.value?.workspace.path,
          openEntities: [...tabs],
        ),
      );
    }
  }

  void changeFolder(String path) {
    state = AsyncValue.data(state.value?.copyWith(selectedEntity: path));
    setFolder(path);
  }

  void toggleWorkspaceStatus({bool? status, bool? error}) {
    state = AsyncValue.data(
      state.value?.copyWith(
        workspace: state.value?.workspace.copyWith(
          saved: status,
          dirty: status == null ? null : !status,
          updatedAt: DateTime.now(),
          error: error,
        ),
      ),
    );
  }
}

class WorkspaceState {
  final Workspace workspace;
  final List<FileSystemEntity> entities;
  final String? selectedEntity;
  final List<String> openEntities;
  final String? file;
  final String? folder;
  WorkspaceState({
    required this.workspace,
    required this.entities,
    this.selectedEntity,
    required this.openEntities,
    this.file,
    this.folder,
  });

  WorkspaceState copyWith({
    Workspace? workspace,
    List<FileSystemEntity>? entities,
    String? selectedEntity,
    String? folder,
    String? file,
    List<String>? openEntities,
  }) {
    return WorkspaceState(
      workspace: workspace ?? this.workspace,
      entities: entities ?? this.entities,
      selectedEntity: selectedEntity ?? this.selectedEntity,
      openEntities: openEntities ?? this.openEntities,
      file: file ?? this.file,
      folder: folder ?? this.folder,
    );
  }
}
