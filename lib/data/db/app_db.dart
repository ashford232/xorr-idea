import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xorr/features/workspace/models/app_directories.dart';

part 'app_db.g.dart';

class Workspaces extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get type => text()();

  TextColumn get path => text().unique()();

  BoolColumn get saved => boolean().withDefault(const Constant(true))();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  BoolColumn get error => boolean().withDefault(const Constant(false))();

  TextColumn get description => text().nullable()();

  TextColumn get emoji => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Workspaces])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docDirectory = await getApplicationDocumentsDirectory();
    final dbFile = AppDirectories(documentsDirectory: docDirectory)
        .databaseFile;

    return NativeDatabase.createInBackground(dbFile);
  });
}
