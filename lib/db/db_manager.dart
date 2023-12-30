import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  TextColumn get whetherTakenList => text().map(TimeListConverter())();
}

class DailyLogs extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get log => text()();
}

@DriftDatabase(tables: [Medicines, DailyLogs])
class DBManager extends _$DBManager {
  DBManager() : super(_openConnection());
  @override
  int get schemaVersion => 5;


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
        if (from < 4) {
          // we added the dueDate property in the change from version 3 to
          // version 4
          await m.addColumn(medicines,medicines.whetherTakenList);
          await m.createTable(dailyLogs);
        }
      },
    );
  }

  Future deleteMedicineById(int id){
    return (delete(medicines)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future deleteAllMedicine(){
    return (delete(medicines)..where((tbl) => tbl.id.isBiggerThanValue(-2))).go();
  }

  Future<Medicine> searchMedicineById(int id){
    return (select(medicines)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future deleteAllLog(){
    return (delete(dailyLogs)..where((tbl) => tbl.id.isBiggerThanValue(-2))).go();
  }

  Future<List<DailyLog>> searchLogByDate(String date){
    return (select(dailyLogs)..where((tbl) => tbl.date.equals(date))).get();
  }


}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}