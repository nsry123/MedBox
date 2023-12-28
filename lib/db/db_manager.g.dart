// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_manager.dart';

// ignore_for_file: type=lint
class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, Medicine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timesPerDayMeta =
      const VerificationMeta('timesPerDay');
  @override
  late final GeneratedColumn<int> timesPerDay = GeneratedColumn<int>(
      'times_per_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dosePerTimeMeta =
      const VerificationMeta('dosePerTime');
  @override
  late final GeneratedColumn<int> dosePerTime = GeneratedColumn<int>(
      'dose_per_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taboosMeta = const VerificationMeta('taboos');
  @override
  late final GeneratedColumn<String> taboos = GeneratedColumn<String>(
      'taboos', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timesListMeta =
      const VerificationMeta('timesList');
  @override
  late final GeneratedColumnWithTypeConverter<List<dynamic>, String> timesList =
      GeneratedColumn<String>('times_list', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<dynamic>>($MedicinesTable.$convertertimesList);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<int> mode = GeneratedColumn<int>(
      'mode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _whetherTakenListMeta =
      const VerificationMeta('whetherTakenList');
  @override
  late final GeneratedColumnWithTypeConverter<List<dynamic>, String>
      whetherTakenList = GeneratedColumn<String>(
              'whether_taken_list', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<dynamic>>(
              $MedicinesTable.$converterwhetherTakenList);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        timesPerDay,
        dosePerTime,
        unit,
        taboos,
        timesList,
        mode,
        whetherTakenList
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(Insertable<Medicine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('times_per_day')) {
      context.handle(
          _timesPerDayMeta,
          timesPerDay.isAcceptableOrUnknown(
              data['times_per_day']!, _timesPerDayMeta));
    } else if (isInserting) {
      context.missing(_timesPerDayMeta);
    }
    if (data.containsKey('dose_per_time')) {
      context.handle(
          _dosePerTimeMeta,
          dosePerTime.isAcceptableOrUnknown(
              data['dose_per_time']!, _dosePerTimeMeta));
    } else if (isInserting) {
      context.missing(_dosePerTimeMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('taboos')) {
      context.handle(_taboosMeta,
          taboos.isAcceptableOrUnknown(data['taboos']!, _taboosMeta));
    } else if (isInserting) {
      context.missing(_taboosMeta);
    }
    context.handle(_timesListMeta, const VerificationResult.success());
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    context.handle(_whetherTakenListMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medicine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      timesPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times_per_day'])!,
      dosePerTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dose_per_time'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      taboos: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taboos'])!,
      timesList: $MedicinesTable.$convertertimesList.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}times_list'])!),
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mode'])!,
      whetherTakenList: $MedicinesTable.$converterwhetherTakenList.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}whether_taken_list'])!),
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<dynamic>, String> $convertertimesList =
      TimeListConverter();
  static TypeConverter<List<dynamic>, String> $converterwhetherTakenList =
      TimeListConverter();
}

class Medicine extends DataClass implements Insertable<Medicine> {
  final int id;
  final String name;
  final int timesPerDay;
  final int dosePerTime;
  final String unit;
  final String taboos;
  final List<dynamic> timesList;
  final int mode;
  final List<dynamic> whetherTakenList;
  const Medicine(
      {required this.id,
      required this.name,
      required this.timesPerDay,
      required this.dosePerTime,
      required this.unit,
      required this.taboos,
      required this.timesList,
      required this.mode,
      required this.whetherTakenList});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['times_per_day'] = Variable<int>(timesPerDay);
    map['dose_per_time'] = Variable<int>(dosePerTime);
    map['unit'] = Variable<String>(unit);
    map['taboos'] = Variable<String>(taboos);
    {
      map['times_list'] = Variable<String>(
          $MedicinesTable.$convertertimesList.toSql(timesList));
    }
    map['mode'] = Variable<int>(mode);
    {
      map['whether_taken_list'] = Variable<String>(
          $MedicinesTable.$converterwhetherTakenList.toSql(whetherTakenList));
    }
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      name: Value(name),
      timesPerDay: Value(timesPerDay),
      dosePerTime: Value(dosePerTime),
      unit: Value(unit),
      taboos: Value(taboos),
      timesList: Value(timesList),
      mode: Value(mode),
      whetherTakenList: Value(whetherTakenList),
    );
  }

  factory Medicine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicine(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      timesPerDay: serializer.fromJson<int>(json['timesPerDay']),
      dosePerTime: serializer.fromJson<int>(json['dosePerTime']),
      unit: serializer.fromJson<String>(json['unit']),
      taboos: serializer.fromJson<String>(json['taboos']),
      timesList: serializer.fromJson<List<dynamic>>(json['timesList']),
      mode: serializer.fromJson<int>(json['mode']),
      whetherTakenList:
          serializer.fromJson<List<dynamic>>(json['whetherTakenList']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'timesPerDay': serializer.toJson<int>(timesPerDay),
      'dosePerTime': serializer.toJson<int>(dosePerTime),
      'unit': serializer.toJson<String>(unit),
      'taboos': serializer.toJson<String>(taboos),
      'timesList': serializer.toJson<List<dynamic>>(timesList),
      'mode': serializer.toJson<int>(mode),
      'whetherTakenList': serializer.toJson<List<dynamic>>(whetherTakenList),
    };
  }

  Medicine copyWith(
          {int? id,
          String? name,
          int? timesPerDay,
          int? dosePerTime,
          String? unit,
          String? taboos,
          List<dynamic>? timesList,
          int? mode,
          List<dynamic>? whetherTakenList}) =>
      Medicine(
        id: id ?? this.id,
        name: name ?? this.name,
        timesPerDay: timesPerDay ?? this.timesPerDay,
        dosePerTime: dosePerTime ?? this.dosePerTime,
        unit: unit ?? this.unit,
        taboos: taboos ?? this.taboos,
        timesList: timesList ?? this.timesList,
        mode: mode ?? this.mode,
        whetherTakenList: whetherTakenList ?? this.whetherTakenList,
      );
  @override
  String toString() {
    return (StringBuffer('Medicine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('dosePerTime: $dosePerTime, ')
          ..write('unit: $unit, ')
          ..write('taboos: $taboos, ')
          ..write('timesList: $timesList, ')
          ..write('mode: $mode, ')
          ..write('whetherTakenList: $whetherTakenList')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, timesPerDay, dosePerTime, unit,
      taboos, timesList, mode, whetherTakenList);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicine &&
          other.id == this.id &&
          other.name == this.name &&
          other.timesPerDay == this.timesPerDay &&
          other.dosePerTime == this.dosePerTime &&
          other.unit == this.unit &&
          other.taboos == this.taboos &&
          other.timesList == this.timesList &&
          other.mode == this.mode &&
          other.whetherTakenList == this.whetherTakenList);
}

class MedicinesCompanion extends UpdateCompanion<Medicine> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> timesPerDay;
  final Value<int> dosePerTime;
  final Value<String> unit;
  final Value<String> taboos;
  final Value<List<dynamic>> timesList;
  final Value<int> mode;
  final Value<List<dynamic>> whetherTakenList;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.dosePerTime = const Value.absent(),
    this.unit = const Value.absent(),
    this.taboos = const Value.absent(),
    this.timesList = const Value.absent(),
    this.mode = const Value.absent(),
    this.whetherTakenList = const Value.absent(),
  });
  MedicinesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int timesPerDay,
    required int dosePerTime,
    required String unit,
    required String taboos,
    required List<dynamic> timesList,
    required int mode,
    required List<dynamic> whetherTakenList,
  })  : name = Value(name),
        timesPerDay = Value(timesPerDay),
        dosePerTime = Value(dosePerTime),
        unit = Value(unit),
        taboos = Value(taboos),
        timesList = Value(timesList),
        mode = Value(mode),
        whetherTakenList = Value(whetherTakenList);
  static Insertable<Medicine> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? timesPerDay,
    Expression<int>? dosePerTime,
    Expression<String>? unit,
    Expression<String>? taboos,
    Expression<String>? timesList,
    Expression<int>? mode,
    Expression<String>? whetherTakenList,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (dosePerTime != null) 'dose_per_time': dosePerTime,
      if (unit != null) 'unit': unit,
      if (taboos != null) 'taboos': taboos,
      if (timesList != null) 'times_list': timesList,
      if (mode != null) 'mode': mode,
      if (whetherTakenList != null) 'whether_taken_list': whetherTakenList,
    });
  }

  MedicinesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? timesPerDay,
      Value<int>? dosePerTime,
      Value<String>? unit,
      Value<String>? taboos,
      Value<List<dynamic>>? timesList,
      Value<int>? mode,
      Value<List<dynamic>>? whetherTakenList}) {
    return MedicinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      dosePerTime: dosePerTime ?? this.dosePerTime,
      unit: unit ?? this.unit,
      taboos: taboos ?? this.taboos,
      timesList: timesList ?? this.timesList,
      mode: mode ?? this.mode,
      whetherTakenList: whetherTakenList ?? this.whetherTakenList,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timesPerDay.present) {
      map['times_per_day'] = Variable<int>(timesPerDay.value);
    }
    if (dosePerTime.present) {
      map['dose_per_time'] = Variable<int>(dosePerTime.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (taboos.present) {
      map['taboos'] = Variable<String>(taboos.value);
    }
    if (timesList.present) {
      map['times_list'] = Variable<String>(
          $MedicinesTable.$convertertimesList.toSql(timesList.value));
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (whetherTakenList.present) {
      map['whether_taken_list'] = Variable<String>($MedicinesTable
          .$converterwhetherTakenList
          .toSql(whetherTakenList.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('dosePerTime: $dosePerTime, ')
          ..write('unit: $unit, ')
          ..write('taboos: $taboos, ')
          ..write('timesList: $timesList, ')
          ..write('mode: $mode, ')
          ..write('whetherTakenList: $whetherTakenList')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logMeta = const VerificationMeta('log');
  @override
  late final GeneratedColumn<String> log = GeneratedColumn<String>(
      'log', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, date, log];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(Insertable<DailyLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('log')) {
      context.handle(
          _logMeta, log.isAcceptableOrUnknown(data['log']!, _logMeta));
    } else if (isInserting) {
      context.missing(_logMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      log: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}log'])!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }
}

class DailyLog extends DataClass implements Insertable<DailyLog> {
  final int id;
  final String date;
  final String log;
  const DailyLog({required this.id, required this.date, required this.log});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['log'] = Variable<String>(log);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      id: Value(id),
      date: Value(date),
      log: Value(log),
    );
  }

  factory DailyLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      log: serializer.fromJson<String>(json['log']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'log': serializer.toJson<String>(log),
    };
  }

  DailyLog copyWith({int? id, String? date, String? log}) => DailyLog(
        id: id ?? this.id,
        date: date ?? this.date,
        log: log ?? this.log,
      );
  @override
  String toString() {
    return (StringBuffer('DailyLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('log: $log')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, log);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.log == this.log);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLog> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> log;
  const DailyLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.log = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String log,
  })  : date = Value(date),
        log = Value(log);
  static Insertable<DailyLog> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? log,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (log != null) 'log': log,
    });
  }

  DailyLogsCompanion copyWith(
      {Value<int>? id, Value<String>? date, Value<String>? log}) {
    return DailyLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      log: log ?? this.log,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (log.present) {
      map['log'] = Variable<String>(log.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('log: $log')
          ..write(')'))
        .toString();
  }
}

abstract class _$DBManager extends GeneratedDatabase {
  _$DBManager(QueryExecutor e) : super(e);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [medicines, dailyLogs];
}
