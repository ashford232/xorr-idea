import 'package:drift/drift.dart';
import 'package:xorr/data/db/app_db.dart';

class WorkspaceDb {
  final AppDb db;

  const WorkspaceDb(this.db);

  Future<List<Workspace>> getAll() {
    return (db.select(db.workspaces)..orderBy([
          (w) => OrderingTerm(expression: w.lastOpenedAt, mode: .desc),
        ]))
        .get();
  }

  Future<Workspace?> getById(String id) {
    return (db.select(
      db.workspaces,
    )..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Future<Workspace?> getLatestOpened() {
    return (db.select(db.workspaces)
          ..orderBy([
            (w) => OrderingTerm(
              expression: w.lastOpenedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> insertWorkspace(WorkspacesCompanion workspace) {
    return db.into(db.workspaces).insert(workspace);
  }

  Future<Workspace?> getByPath(String path) {
    return (db.select(
      db.workspaces,
    )..where((w) => w.path.equals(path))).getSingleOrNull();
  }

  Future<int> updateWorkspace(WorkspacesCompanion workspace) {
    final id = workspace.id.value;
    return (db.update(
      db.workspaces,
    )..where((w) => w.id.equals(id))).write(workspace);
  }

  Future<int> deleteById(String id) {
    return (db.delete(db.workspaces)..where((w) => w.id.equals(id))).go();
  }
}
