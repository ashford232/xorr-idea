import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:xorr/data/db/app_db.dart';
import 'package:xorr/features/workspace/models/app_directories.dart';
import 'package:xorr/features/workspace/services/workspace_db_service.dart';

class WorkspaceController {
  final WorkspaceDb _workspaceDb;

  new({required this._workspaceDb});
  Future<Directory> _getDir() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<void> openWorkspace({String? wsPath}) async {
    if (wsPath == null) {
      final defaultDir = AppDirectories(documentsDirectory: await _getDir())
          .workspacesDirectory;

      wsPath = await getDirectoryPath(
        initialDirectory: defaultDir.path,
        confirmButtonText: "Select",
      );
    }

    if (wsPath == null) {
      return;
    }

    final localWorkspace = await _workspaceDb.getByPath(wsPath);

    if (localWorkspace != null) {
      final w = WorkspacesCompanion(
        id: Value(localWorkspace.id),
        name: Value(p.basename(wsPath)),
        type: Value(localWorkspace.type),
        path: Value(wsPath),
        saved: Value(localWorkspace.saved),
        dirty: Value(localWorkspace.dirty),
        createdAt: Value(localWorkspace.createdAt),
        updatedAt: Value(localWorkspace.updatedAt),
        lastOpenedAt: Value(DateTime.now()),
      );

      _workspaceDb.updateWorkspace(w);
      return;
    }
    final directory = Directory(wsPath);

    if (!await directory.exists()) {
      return;
    }

    final ws = WorkspacesCompanion(
      id: Value(const Uuid().v4()),
      name: Value(p.basename(directory.path)),
      type: Value("Local"),
      path: Value(directory.path),
      saved: Value(true),
      dirty: Value(false),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      lastOpenedAt: Value(DateTime.now()),
    );
    _workspaceDb.insertWorkspace(ws);
  }

  Future<List<FileSystemEntity>> getFileSystemEntity(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      return [];
    }

    final entities = await directory.list().toList();

    entities.sort((a, b) {
      final aIsDirectory = a is Directory;
      final bIsDirectory = b is Directory;

      if (aIsDirectory && !bIsDirectory) return -1;
      if (!aIsDirectory && bIsDirectory) return 1;

      final aName = a.path.split(Platform.pathSeparator).last.toLowerCase();
      final bName = b.path.split(Platform.pathSeparator).last.toLowerCase();

      return aName.compareTo(bName);
    });

    return entities;
  }

  Future<void> createFile(String path) async {
    final file = File(path);
    await file.create(recursive: true);
  }

  Future<void> createFolder(String path) async {
    final directory = Directory(path);
    await directory.create(recursive: true);
  }
}
