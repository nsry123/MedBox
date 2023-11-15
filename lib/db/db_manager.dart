import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
part 'db_manager.g.dart';


class TimeListConverter extends TypeConverter<List<dynamic>, String>{
  @override
  List<dynamic> fromSql(String fromDb) {
    // TODO: implement fromSql
    return json.decode(fromDb);
  }
  @override
  String toSql(List<dynamic> value) {
    // TODO: implement toSql
    return json.encode(value);
  }
}

class Medicines extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get timesPerDay => integer()();
  IntColumn get dosePerTime => integer()();
  TextColumn get unit => text()();
  TextColumn get taboos => text()();
  TextColumn get timesList => text().map(TimeListConverter())();
  IntColumn get mode => integer()();
}

@DriftDatabase(tables: [Medicines])
class DBManager extends _$DBManager {
  DBManager() : super(_openConnection());
  @override
  int get schemaVersion => 3;


  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // we added the dueDate property in the change from version 1 to
          // version 2
          await m.addColumn(medicines,medicines.dosePerTime);
        }
        if (from < 3) {
          // we added the dueDate property in the change from version 2 to
          // version 3
          await m.addColumn(medicines,medicines.mode);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}