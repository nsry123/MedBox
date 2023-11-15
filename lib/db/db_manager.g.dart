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
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, timesPerDay, dosePerTime, unit, taboos, timesList, mode];
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
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<dynamic>, String> $convertertimesList =
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
  const Medicine(
      {required this.id,
      required this.name,
      required this.timesPerDay,
      required this.dosePerTime,
      required this.unit,
      required this.taboos,
      required this.timesList,
      required this.mode});
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
      final converter = $MedicinesTable.$convertertimesList;
      map['times_list'] = Variable<String>(converter.toSql(timesList));
    }
    map['mode'] = Variable<int>(mode);
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
          int? mode}) =>
      Medicine(
        id: id ?? this.id,
        name: name ?? this.name,
        timesPerDay: timesPerDay ?? this.timesPerDay,
        dosePerTime: dosePerTime ?? this.dosePerTime,
        unit: unit ?? this.unit,
        taboos: taboos ?? this.taboos,
        timesList: timesList ?? this.timesList,
        mode: mode ?? this.mode,
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
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, timesPerDay, dosePerTime, unit, taboos, timesList, mode);
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
          other.mode == this.mode);
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
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.dosePerTime = const Value.absent(),
    this.unit = const Value.absent(),
    this.taboos = const Value.absent(),
    this.timesList = const Value.absent(),
    this.mode = const Value.absent(),
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
  })  : name = Value(name),
        timesPerDay = Value(timesPerDay),
        dosePerTime = Value(dosePerTime),
        unit = Value(unit),
        taboos = Value(taboos),
        timesList = Value(timesList),
        mode = Value(mode);
  static Insertable<Medicine> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? timesPerDay,
    Expression<int>? dosePerTime,
    Expression<String>? unit,
    Expression<String>? taboos,
    Expression<String>? timesList,
    Expression<int>? mode,
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
      Value<int>? mode}) {
    return MedicinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      dosePerTime: dosePerTime ?? this.dosePerTime,
      unit: unit ?? this.unit,
      taboos: taboos ?? this.taboos,
      timesList: timesList ?? this.timesList,
      mode: mode ?? this.mode,
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
      final converter = $MedicinesTable.$convertertimesList;

      map['times_list'] = Variable<String>(converter.toSql(timesList.value));
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
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
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }
}

abstract class _$DBManager extends GeneratedDatabase {
  _$DBManager(QueryExecutor e) : super(e);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [medicines];
}