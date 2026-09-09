import 'dart:io';

import 'package:path/path.dart' as path;

class AppDirectories {
  final Directory documentsDirectory;

  const AppDirectories({
    required this.documentsDirectory,
  });

  Directory get xorrDirectory =>
      Directory(path.join(documentsDirectory.path, 'Xorr'));

  Directory get databaseDirectory =>
      Directory(path.join(xorrDirectory.path, 'database'));

  File get databaseFile =>
      File(path.join(databaseDirectory.path, 'app.db'));

  Directory get configDirectory =>
      Directory(path.join(xorrDirectory.path, 'config'));

  Directory get cacheDirectory =>
      Directory(path.join(xorrDirectory.path, 'cache'));

  Directory get workspacesDirectory =>
      Directory(path.join(xorrDirectory.path, 'workspaces'));
}