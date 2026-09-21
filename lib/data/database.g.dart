// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Player({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Player copyWith({int? id, String? name, DateTime? createdAt}) => Player(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OpensTable extends Opens with TableInfo<$OpensTable, Open> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestOfMeta = const VerificationMeta('bestOf');
  @override
  late final GeneratedColumn<int> bestOf = GeneratedColumn<int>(
    'best_of',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('single_elim'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('setup'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _grandFinalResetMeta = const VerificationMeta(
    'grandFinalReset',
  );
  @override
  late final GeneratedColumn<bool> grandFinalReset = GeneratedColumn<bool>(
    'grand_final_reset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("grand_final_reset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    date,
    bestOf,
    format,
    status,
    createdAt,
    grandFinalReset,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'opens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Open> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('best_of')) {
      context.handle(
        _bestOfMeta,
        bestOf.isAcceptableOrUnknown(data['best_of']!, _bestOfMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('grand_final_reset')) {
      context.handle(
        _grandFinalResetMeta,
        grandFinalReset.isAcceptableOrUnknown(
          data['grand_final_reset']!,
          _grandFinalResetMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Open map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Open(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      bestOf: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_of'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      grandFinalReset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}grand_final_reset'],
      )!,
    );
  }

  @override
  $OpensTable createAlias(String alias) {
    return $OpensTable(attachedDatabase, alias);
  }
}

class Open extends DataClass implements Insertable<Open> {
  final int id;
  final String name;
  final String? location;
  final DateTime? date;
  final int bestOf;
  final String format;
  final String status;
  final DateTime createdAt;
  final bool grandFinalReset;
  const Open({
    required this.id,
    required this.name,
    this.location,
    this.date,
    required this.bestOf,
    required this.format,
    required this.status,
    required this.createdAt,
    required this.grandFinalReset,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    map['best_of'] = Variable<int>(bestOf);
    map['format'] = Variable<String>(format);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['grand_final_reset'] = Variable<bool>(grandFinalReset);
    return map;
  }

  OpensCompanion toCompanion(bool nullToAbsent) {
    return OpensCompanion(
      id: Value(id),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      bestOf: Value(bestOf),
      format: Value(format),
      status: Value(status),
      createdAt: Value(createdAt),
      grandFinalReset: Value(grandFinalReset),
    );
  }

  factory Open.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Open(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      date: serializer.fromJson<DateTime?>(json['date']),
      bestOf: serializer.fromJson<int>(json['bestOf']),
      format: serializer.fromJson<String>(json['format']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      grandFinalReset: serializer.fromJson<bool>(json['grandFinalReset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'date': serializer.toJson<DateTime?>(date),
      'bestOf': serializer.toJson<int>(bestOf),
      'format': serializer.toJson<String>(format),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'grandFinalReset': serializer.toJson<bool>(grandFinalReset),
    };
  }

  Open copyWith({
    int? id,
    String? name,
    Value<String?> location = const Value.absent(),
    Value<DateTime?> date = const Value.absent(),
    int? bestOf,
    String? format,
    String? status,
    DateTime? createdAt,
    bool? grandFinalReset,
  }) => Open(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location.present ? location.value : this.location,
    date: date.present ? date.value : this.date,
    bestOf: bestOf ?? this.bestOf,
    format: format ?? this.format,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    grandFinalReset: grandFinalReset ?? this.grandFinalReset,
  );
  Open copyWithCompanion(OpensCompanion data) {
    return Open(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      date: data.date.present ? data.date.value : this.date,
      bestOf: data.bestOf.present ? data.bestOf.value : this.bestOf,
      format: data.format.present ? data.format.value : this.format,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      grandFinalReset: data.grandFinalReset.present
          ? data.grandFinalReset.value
          : this.grandFinalReset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Open(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('date: $date, ')
          ..write('bestOf: $bestOf, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('grandFinalReset: $grandFinalReset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    date,
    bestOf,
    format,
    status,
    createdAt,
    grandFinalReset,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Open &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.date == this.date &&
          other.bestOf == this.bestOf &&
          other.format == this.format &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.grandFinalReset == this.grandFinalReset);
}

class OpensCompanion extends UpdateCompanion<Open> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> location;
  final Value<DateTime?> date;
  final Value<int> bestOf;
  final Value<String> format;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<bool> grandFinalReset;
  const OpensCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.date = const Value.absent(),
    this.bestOf = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.grandFinalReset = const Value.absent(),
  });
  OpensCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.location = const Value.absent(),
    this.date = const Value.absent(),
    this.bestOf = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.grandFinalReset = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Open> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<DateTime>? date,
    Expression<int>? bestOf,
    Expression<String>? format,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<bool>? grandFinalReset,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (date != null) 'date': date,
      if (bestOf != null) 'best_of': bestOf,
      if (format != null) 'format': format,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (grandFinalReset != null) 'grand_final_reset': grandFinalReset,
    });
  }

  OpensCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? location,
    Value<DateTime?>? date,
    Value<int>? bestOf,
    Value<String>? format,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<bool>? grandFinalReset,
  }) {
    return OpensCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      date: date ?? this.date,
      bestOf: bestOf ?? this.bestOf,
      format: format ?? this.format,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      grandFinalReset: grandFinalReset ?? this.grandFinalReset,
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
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (bestOf.present) {
      map['best_of'] = Variable<int>(bestOf.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (grandFinalReset.present) {
      map['grand_final_reset'] = Variable<bool>(grandFinalReset.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpensCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('date: $date, ')
          ..write('bestOf: $bestOf, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('grandFinalReset: $grandFinalReset')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, DartMatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _openIdMeta = const VerificationMeta('openId');
  @override
  late final GeneratedColumn<int> openId = GeneratedColumn<int>(
    'open_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opens (id)',
    ),
  );
  static const VerificationMeta _player1IdMeta = const VerificationMeta(
    'player1Id',
  );
  @override
  late final GeneratedColumn<int> player1Id = GeneratedColumn<int>(
    'player1_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _player2IdMeta = const VerificationMeta(
    'player2Id',
  );
  @override
  late final GeneratedColumn<int> player2Id = GeneratedColumn<int>(
    'player2_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _markerIdMeta = const VerificationMeta(
    'markerId',
  );
  @override
  late final GeneratedColumn<int> markerId = GeneratedColumn<int>(
    'marker_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _bestOfMeta = const VerificationMeta('bestOf');
  @override
  late final GeneratedColumn<int> bestOf = GeneratedColumn<int>(
    'best_of',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _winnerIdMeta = const VerificationMeta(
    'winnerId',
  );
  @override
  late final GeneratedColumn<int> winnerId = GeneratedColumn<int>(
    'winner_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
    'round',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    openId,
    player1Id,
    player2Id,
    markerId,
    bestOf,
    status,
    winnerId,
    round,
    createdAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<DartMatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('open_id')) {
      context.handle(
        _openIdMeta,
        openId.isAcceptableOrUnknown(data['open_id']!, _openIdMeta),
      );
    }
    if (data.containsKey('player1_id')) {
      context.handle(
        _player1IdMeta,
        player1Id.isAcceptableOrUnknown(data['player1_id']!, _player1IdMeta),
      );
    } else if (isInserting) {
      context.missing(_player1IdMeta);
    }
    if (data.containsKey('player2_id')) {
      context.handle(
        _player2IdMeta,
        player2Id.isAcceptableOrUnknown(data['player2_id']!, _player2IdMeta),
      );
    } else if (isInserting) {
      context.missing(_player2IdMeta);
    }
    if (data.containsKey('marker_id')) {
      context.handle(
        _markerIdMeta,
        markerId.isAcceptableOrUnknown(data['marker_id']!, _markerIdMeta),
      );
    }
    if (data.containsKey('best_of')) {
      context.handle(
        _bestOfMeta,
        bestOf.isAcceptableOrUnknown(data['best_of']!, _bestOfMeta),
      );
    } else if (isInserting) {
      context.missing(_bestOfMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('winner_id')) {
      context.handle(
        _winnerIdMeta,
        winnerId.isAcceptableOrUnknown(data['winner_id']!, _winnerIdMeta),
      );
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DartMatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DartMatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      openId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}open_id'],
      ),
      player1Id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player1_id'],
      )!,
      player2Id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player2_id'],
      )!,
      markerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marker_id'],
      ),
      bestOf: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_of'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      winnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}winner_id'],
      ),
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class DartMatch extends DataClass implements Insertable<DartMatch> {
  final int id;
  final int? openId;
  final int player1Id;
  final int player2Id;
  final int? markerId;
  final int bestOf;
  final String status;
  final int? winnerId;
  final int? round;
  final DateTime createdAt;
  final DateTime? finishedAt;
  const DartMatch({
    required this.id,
    this.openId,
    required this.player1Id,
    required this.player2Id,
    this.markerId,
    required this.bestOf,
    required this.status,
    this.winnerId,
    this.round,
    required this.createdAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || openId != null) {
      map['open_id'] = Variable<int>(openId);
    }
    map['player1_id'] = Variable<int>(player1Id);
    map['player2_id'] = Variable<int>(player2Id);
    if (!nullToAbsent || markerId != null) {
      map['marker_id'] = Variable<int>(markerId);
    }
    map['best_of'] = Variable<int>(bestOf);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || winnerId != null) {
      map['winner_id'] = Variable<int>(winnerId);
    }
    if (!nullToAbsent || round != null) {
      map['round'] = Variable<int>(round);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      openId: openId == null && nullToAbsent
          ? const Value.absent()
          : Value(openId),
      player1Id: Value(player1Id),
      player2Id: Value(player2Id),
      markerId: markerId == null && nullToAbsent
          ? const Value.absent()
          : Value(markerId),
      bestOf: Value(bestOf),
      status: Value(status),
      winnerId: winnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerId),
      round: round == null && nullToAbsent
          ? const Value.absent()
          : Value(round),
      createdAt: Value(createdAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory DartMatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DartMatch(
      id: serializer.fromJson<int>(json['id']),
      openId: serializer.fromJson<int?>(json['openId']),
      player1Id: serializer.fromJson<int>(json['player1Id']),
      player2Id: serializer.fromJson<int>(json['player2Id']),
      markerId: serializer.fromJson<int?>(json['markerId']),
      bestOf: serializer.fromJson<int>(json['bestOf']),
      status: serializer.fromJson<String>(json['status']),
      winnerId: serializer.fromJson<int?>(json['winnerId']),
      round: serializer.fromJson<int?>(json['round']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'openId': serializer.toJson<int?>(openId),
      'player1Id': serializer.toJson<int>(player1Id),
      'player2Id': serializer.toJson<int>(player2Id),
      'markerId': serializer.toJson<int?>(markerId),
      'bestOf': serializer.toJson<int>(bestOf),
      'status': serializer.toJson<String>(status),
      'winnerId': serializer.toJson<int?>(winnerId),
      'round': serializer.toJson<int?>(round),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  DartMatch copyWith({
    int? id,
    Value<int?> openId = const Value.absent(),
    int? player1Id,
    int? player2Id,
    Value<int?> markerId = const Value.absent(),
    int? bestOf,
    String? status,
    Value<int?> winnerId = const Value.absent(),
    Value<int?> round = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => DartMatch(
    id: id ?? this.id,
    openId: openId.present ? openId.value : this.openId,
    player1Id: player1Id ?? this.player1Id,
    player2Id: player2Id ?? this.player2Id,
    markerId: markerId.present ? markerId.value : this.markerId,
    bestOf: bestOf ?? this.bestOf,
    status: status ?? this.status,
    winnerId: winnerId.present ? winnerId.value : this.winnerId,
    round: round.present ? round.value : this.round,
    createdAt: createdAt ?? this.createdAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  DartMatch copyWithCompanion(MatchesCompanion data) {
    return DartMatch(
      id: data.id.present ? data.id.value : this.id,
      openId: data.openId.present ? data.openId.value : this.openId,
      player1Id: data.player1Id.present ? data.player1Id.value : this.player1Id,
      player2Id: data.player2Id.present ? data.player2Id.value : this.player2Id,
      markerId: data.markerId.present ? data.markerId.value : this.markerId,
      bestOf: data.bestOf.present ? data.bestOf.value : this.bestOf,
      status: data.status.present ? data.status.value : this.status,
      winnerId: data.winnerId.present ? data.winnerId.value : this.winnerId,
      round: data.round.present ? data.round.value : this.round,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DartMatch(')
          ..write('id: $id, ')
          ..write('openId: $openId, ')
          ..write('player1Id: $player1Id, ')
          ..write('player2Id: $player2Id, ')
          ..write('markerId: $markerId, ')
          ..write('bestOf: $bestOf, ')
          ..write('status: $status, ')
          ..write('winnerId: $winnerId, ')
          ..write('round: $round, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    openId,
    player1Id,
    player2Id,
    markerId,
    bestOf,
    status,
    winnerId,
    round,
    createdAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DartMatch &&
          other.id == this.id &&
          other.openId == this.openId &&
          other.player1Id == this.player1Id &&
          other.player2Id == this.player2Id &&
          other.markerId == this.markerId &&
          other.bestOf == this.bestOf &&
          other.status == this.status &&
          other.winnerId == this.winnerId &&
          other.round == this.round &&
          other.createdAt == this.createdAt &&
          other.finishedAt == this.finishedAt);
}

class MatchesCompanion extends UpdateCompanion<DartMatch> {
  final Value<int> id;
  final Value<int?> openId;
  final Value<int> player1Id;
  final Value<int> player2Id;
  final Value<int?> markerId;
  final Value<int> bestOf;
  final Value<String> status;
  final Value<int?> winnerId;
  final Value<int?> round;
  final Value<DateTime> createdAt;
  final Value<DateTime?> finishedAt;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.openId = const Value.absent(),
    this.player1Id = const Value.absent(),
    this.player2Id = const Value.absent(),
    this.markerId = const Value.absent(),
    this.bestOf = const Value.absent(),
    this.status = const Value.absent(),
    this.winnerId = const Value.absent(),
    this.round = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  });
  MatchesCompanion.insert({
    this.id = const Value.absent(),
    this.openId = const Value.absent(),
    required int player1Id,
    required int player2Id,
    this.markerId = const Value.absent(),
    required int bestOf,
    this.status = const Value.absent(),
    this.winnerId = const Value.absent(),
    this.round = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
  }) : player1Id = Value(player1Id),
       player2Id = Value(player2Id),
       bestOf = Value(bestOf);
  static Insertable<DartMatch> custom({
    Expression<int>? id,
    Expression<int>? openId,
    Expression<int>? player1Id,
    Expression<int>? player2Id,
    Expression<int>? markerId,
    Expression<int>? bestOf,
    Expression<String>? status,
    Expression<int>? winnerId,
    Expression<int>? round,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? finishedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openId != null) 'open_id': openId,
      if (player1Id != null) 'player1_id': player1Id,
      if (player2Id != null) 'player2_id': player2Id,
      if (markerId != null) 'marker_id': markerId,
      if (bestOf != null) 'best_of': bestOf,
      if (status != null) 'status': status,
      if (winnerId != null) 'winner_id': winnerId,
      if (round != null) 'round': round,
      if (createdAt != null) 'created_at': createdAt,
      if (finishedAt != null) 'finished_at': finishedAt,
    });
  }

  MatchesCompanion copyWith({
    Value<int>? id,
    Value<int?>? openId,
    Value<int>? player1Id,
    Value<int>? player2Id,
    Value<int?>? markerId,
    Value<int>? bestOf,
    Value<String>? status,
    Value<int?>? winnerId,
    Value<int?>? round,
    Value<DateTime>? createdAt,
    Value<DateTime?>? finishedAt,
  }) {
    return MatchesCompanion(
      id: id ?? this.id,
      openId: openId ?? this.openId,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      markerId: markerId ?? this.markerId,
      bestOf: bestOf ?? this.bestOf,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      round: round ?? this.round,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (openId.present) {
      map['open_id'] = Variable<int>(openId.value);
    }
    if (player1Id.present) {
      map['player1_id'] = Variable<int>(player1Id.value);
    }
    if (player2Id.present) {
      map['player2_id'] = Variable<int>(player2Id.value);
    }
    if (markerId.present) {
      map['marker_id'] = Variable<int>(markerId.value);
    }
    if (bestOf.present) {
      map['best_of'] = Variable<int>(bestOf.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (winnerId.present) {
      map['winner_id'] = Variable<int>(winnerId.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('openId: $openId, ')
          ..write('player1Id: $player1Id, ')
          ..write('player2Id: $player2Id, ')
          ..write('markerId: $markerId, ')
          ..write('bestOf: $bestOf, ')
          ..write('status: $status, ')
          ..write('winnerId: $winnerId, ')
          ..write('round: $round, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }
}

class $LegsTable extends Legs with TableInfo<$LegsTable, Leg> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES matches (id)',
    ),
  );
  static const VerificationMeta _legNumberMeta = const VerificationMeta(
    'legNumber',
  );
  @override
  late final GeneratedColumn<int> legNumber = GeneratedColumn<int>(
    'leg_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starterIdMeta = const VerificationMeta(
    'starterId',
  );
  @override
  late final GeneratedColumn<int> starterId = GeneratedColumn<int>(
    'starter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _winnerIdMeta = const VerificationMeta(
    'winnerId',
  );
  @override
  late final GeneratedColumn<int> winnerId = GeneratedColumn<int>(
    'winner_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    matchId,
    legNumber,
    starterId,
    winnerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'legs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Leg> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('leg_number')) {
      context.handle(
        _legNumberMeta,
        legNumber.isAcceptableOrUnknown(data['leg_number']!, _legNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_legNumberMeta);
    }
    if (data.containsKey('starter_id')) {
      context.handle(
        _starterIdMeta,
        starterId.isAcceptableOrUnknown(data['starter_id']!, _starterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_starterIdMeta);
    }
    if (data.containsKey('winner_id')) {
      context.handle(
        _winnerIdMeta,
        winnerId.isAcceptableOrUnknown(data['winner_id']!, _winnerIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Leg map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Leg(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_id'],
      )!,
      legNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leg_number'],
      )!,
      starterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starter_id'],
      )!,
      winnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}winner_id'],
      ),
    );
  }

  @override
  $LegsTable createAlias(String alias) {
    return $LegsTable(attachedDatabase, alias);
  }
}

class Leg extends DataClass implements Insertable<Leg> {
  final int id;
  final int matchId;
  final int legNumber;
  final int starterId;
  final int? winnerId;
  const Leg({
    required this.id,
    required this.matchId,
    required this.legNumber,
    required this.starterId,
    this.winnerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['match_id'] = Variable<int>(matchId);
    map['leg_number'] = Variable<int>(legNumber);
    map['starter_id'] = Variable<int>(starterId);
    if (!nullToAbsent || winnerId != null) {
      map['winner_id'] = Variable<int>(winnerId);
    }
    return map;
  }

  LegsCompanion toCompanion(bool nullToAbsent) {
    return LegsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      legNumber: Value(legNumber),
      starterId: Value(starterId),
      winnerId: winnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerId),
    );
  }

  factory Leg.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Leg(
      id: serializer.fromJson<int>(json['id']),
      matchId: serializer.fromJson<int>(json['matchId']),
      legNumber: serializer.fromJson<int>(json['legNumber']),
      starterId: serializer.fromJson<int>(json['starterId']),
      winnerId: serializer.fromJson<int?>(json['winnerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'matchId': serializer.toJson<int>(matchId),
      'legNumber': serializer.toJson<int>(legNumber),
      'starterId': serializer.toJson<int>(starterId),
      'winnerId': serializer.toJson<int?>(winnerId),
    };
  }

  Leg copyWith({
    int? id,
    int? matchId,
    int? legNumber,
    int? starterId,
    Value<int?> winnerId = const Value.absent(),
  }) => Leg(
    id: id ?? this.id,
    matchId: matchId ?? this.matchId,
    legNumber: legNumber ?? this.legNumber,
    starterId: starterId ?? this.starterId,
    winnerId: winnerId.present ? winnerId.value : this.winnerId,
  );
  Leg copyWithCompanion(LegsCompanion data) {
    return Leg(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      legNumber: data.legNumber.present ? data.legNumber.value : this.legNumber,
      starterId: data.starterId.present ? data.starterId.value : this.starterId,
      winnerId: data.winnerId.present ? data.winnerId.value : this.winnerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Leg(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('legNumber: $legNumber, ')
          ..write('starterId: $starterId, ')
          ..write('winnerId: $winnerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, matchId, legNumber, starterId, winnerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Leg &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.legNumber == this.legNumber &&
          other.starterId == this.starterId &&
          other.winnerId == this.winnerId);
}

class LegsCompanion extends UpdateCompanion<Leg> {
  final Value<int> id;
  final Value<int> matchId;
  final Value<int> legNumber;
  final Value<int> starterId;
  final Value<int?> winnerId;
  const LegsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.legNumber = const Value.absent(),
    this.starterId = const Value.absent(),
    this.winnerId = const Value.absent(),
  });
  LegsCompanion.insert({
    this.id = const Value.absent(),
    required int matchId,
    required int legNumber,
    required int starterId,
    this.winnerId = const Value.absent(),
  }) : matchId = Value(matchId),
       legNumber = Value(legNumber),
       starterId = Value(starterId);
  static Insertable<Leg> custom({
    Expression<int>? id,
    Expression<int>? matchId,
    Expression<int>? legNumber,
    Expression<int>? starterId,
    Expression<int>? winnerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (legNumber != null) 'leg_number': legNumber,
      if (starterId != null) 'starter_id': starterId,
      if (winnerId != null) 'winner_id': winnerId,
    });
  }

  LegsCompanion copyWith({
    Value<int>? id,
    Value<int>? matchId,
    Value<int>? legNumber,
    Value<int>? starterId,
    Value<int?>? winnerId,
  }) {
    return LegsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      legNumber: legNumber ?? this.legNumber,
      starterId: starterId ?? this.starterId,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    if (legNumber.present) {
      map['leg_number'] = Variable<int>(legNumber.value);
    }
    if (starterId.present) {
      map['starter_id'] = Variable<int>(starterId.value);
    }
    if (winnerId.present) {
      map['winner_id'] = Variable<int>(winnerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('legNumber: $legNumber, ')
          ..write('starterId: $starterId, ')
          ..write('winnerId: $winnerId')
          ..write(')'))
        .toString();
  }
}

class $TurnsTable extends Turns with TableInfo<$TurnsTable, Turn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _legIdMeta = const VerificationMeta('legId');
  @override
  late final GeneratedColumn<int> legId = GeneratedColumn<int>(
    'leg_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES legs (id)',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _turnNumberMeta = const VerificationMeta(
    'turnNumber',
  );
  @override
  late final GeneratedColumn<int> turnNumber = GeneratedColumn<int>(
    'turn_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dartsUsedMeta = const VerificationMeta(
    'dartsUsed',
  );
  @override
  late final GeneratedColumn<int> dartsUsed = GeneratedColumn<int>(
    'darts_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _isBustMeta = const VerificationMeta('isBust');
  @override
  late final GeneratedColumn<bool> isBust = GeneratedColumn<bool>(
    'is_bust',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bust" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCheckoutMeta = const VerificationMeta(
    'isCheckout',
  );
  @override
  late final GeneratedColumn<bool> isCheckout = GeneratedColumn<bool>(
    'is_checkout',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checkout" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    legId,
    playerId,
    turnNumber,
    score,
    dartsUsed,
    isBust,
    isCheckout,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Turn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('leg_id')) {
      context.handle(
        _legIdMeta,
        legId.isAcceptableOrUnknown(data['leg_id']!, _legIdMeta),
      );
    } else if (isInserting) {
      context.missing(_legIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('turn_number')) {
      context.handle(
        _turnNumberMeta,
        turnNumber.isAcceptableOrUnknown(data['turn_number']!, _turnNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_turnNumberMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('darts_used')) {
      context.handle(
        _dartsUsedMeta,
        dartsUsed.isAcceptableOrUnknown(data['darts_used']!, _dartsUsedMeta),
      );
    }
    if (data.containsKey('is_bust')) {
      context.handle(
        _isBustMeta,
        isBust.isAcceptableOrUnknown(data['is_bust']!, _isBustMeta),
      );
    }
    if (data.containsKey('is_checkout')) {
      context.handle(
        _isCheckoutMeta,
        isCheckout.isAcceptableOrUnknown(data['is_checkout']!, _isCheckoutMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Turn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Turn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      legId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leg_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      turnNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_number'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      dartsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}darts_used'],
      )!,
      isBust: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bust'],
      )!,
      isCheckout: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checkout'],
      )!,
    );
  }

  @override
  $TurnsTable createAlias(String alias) {
    return $TurnsTable(attachedDatabase, alias);
  }
}

class Turn extends DataClass implements Insertable<Turn> {
  final int id;
  final int legId;
  final int playerId;
  final int turnNumber;
  final int score;
  final int dartsUsed;
  final bool isBust;
  final bool isCheckout;
  const Turn({
    required this.id,
    required this.legId,
    required this.playerId,
    required this.turnNumber,
    required this.score,
    required this.dartsUsed,
    required this.isBust,
    required this.isCheckout,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['leg_id'] = Variable<int>(legId);
    map['player_id'] = Variable<int>(playerId);
    map['turn_number'] = Variable<int>(turnNumber);
    map['score'] = Variable<int>(score);
    map['darts_used'] = Variable<int>(dartsUsed);
    map['is_bust'] = Variable<bool>(isBust);
    map['is_checkout'] = Variable<bool>(isCheckout);
    return map;
  }

  TurnsCompanion toCompanion(bool nullToAbsent) {
    return TurnsCompanion(
      id: Value(id),
      legId: Value(legId),
      playerId: Value(playerId),
      turnNumber: Value(turnNumber),
      score: Value(score),
      dartsUsed: Value(dartsUsed),
      isBust: Value(isBust),
      isCheckout: Value(isCheckout),
    );
  }

  factory Turn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Turn(
      id: serializer.fromJson<int>(json['id']),
      legId: serializer.fromJson<int>(json['legId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      turnNumber: serializer.fromJson<int>(json['turnNumber']),
      score: serializer.fromJson<int>(json['score']),
      dartsUsed: serializer.fromJson<int>(json['dartsUsed']),
      isBust: serializer.fromJson<bool>(json['isBust']),
      isCheckout: serializer.fromJson<bool>(json['isCheckout']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'legId': serializer.toJson<int>(legId),
      'playerId': serializer.toJson<int>(playerId),
      'turnNumber': serializer.toJson<int>(turnNumber),
      'score': serializer.toJson<int>(score),
      'dartsUsed': serializer.toJson<int>(dartsUsed),
      'isBust': serializer.toJson<bool>(isBust),
      'isCheckout': serializer.toJson<bool>(isCheckout),
    };
  }

  Turn copyWith({
    int? id,
    int? legId,
    int? playerId,
    int? turnNumber,
    int? score,
    int? dartsUsed,
    bool? isBust,
    bool? isCheckout,
  }) => Turn(
    id: id ?? this.id,
    legId: legId ?? this.legId,
    playerId: playerId ?? this.playerId,
    turnNumber: turnNumber ?? this.turnNumber,
    score: score ?? this.score,
    dartsUsed: dartsUsed ?? this.dartsUsed,
    isBust: isBust ?? this.isBust,
    isCheckout: isCheckout ?? this.isCheckout,
  );
  Turn copyWithCompanion(TurnsCompanion data) {
    return Turn(
      id: data.id.present ? data.id.value : this.id,
      legId: data.legId.present ? data.legId.value : this.legId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      turnNumber: data.turnNumber.present
          ? data.turnNumber.value
          : this.turnNumber,
      score: data.score.present ? data.score.value : this.score,
      dartsUsed: data.dartsUsed.present ? data.dartsUsed.value : this.dartsUsed,
      isBust: data.isBust.present ? data.isBust.value : this.isBust,
      isCheckout: data.isCheckout.present
          ? data.isCheckout.value
          : this.isCheckout,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Turn(')
          ..write('id: $id, ')
          ..write('legId: $legId, ')
          ..write('playerId: $playerId, ')
          ..write('turnNumber: $turnNumber, ')
          ..write('score: $score, ')
          ..write('dartsUsed: $dartsUsed, ')
          ..write('isBust: $isBust, ')
          ..write('isCheckout: $isCheckout')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    legId,
    playerId,
    turnNumber,
    score,
    dartsUsed,
    isBust,
    isCheckout,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Turn &&
          other.id == this.id &&
          other.legId == this.legId &&
          other.playerId == this.playerId &&
          other.turnNumber == this.turnNumber &&
          other.score == this.score &&
          other.dartsUsed == this.dartsUsed &&
          other.isBust == this.isBust &&
          other.isCheckout == this.isCheckout);
}

class TurnsCompanion extends UpdateCompanion<Turn> {
  final Value<int> id;
  final Value<int> legId;
  final Value<int> playerId;
  final Value<int> turnNumber;
  final Value<int> score;
  final Value<int> dartsUsed;
  final Value<bool> isBust;
  final Value<bool> isCheckout;
  const TurnsCompanion({
    this.id = const Value.absent(),
    this.legId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.turnNumber = const Value.absent(),
    this.score = const Value.absent(),
    this.dartsUsed = const Value.absent(),
    this.isBust = const Value.absent(),
    this.isCheckout = const Value.absent(),
  });
  TurnsCompanion.insert({
    this.id = const Value.absent(),
    required int legId,
    required int playerId,
    required int turnNumber,
    required int score,
    this.dartsUsed = const Value.absent(),
    this.isBust = const Value.absent(),
    this.isCheckout = const Value.absent(),
  }) : legId = Value(legId),
       playerId = Value(playerId),
       turnNumber = Value(turnNumber),
       score = Value(score);
  static Insertable<Turn> custom({
    Expression<int>? id,
    Expression<int>? legId,
    Expression<int>? playerId,
    Expression<int>? turnNumber,
    Expression<int>? score,
    Expression<int>? dartsUsed,
    Expression<bool>? isBust,
    Expression<bool>? isCheckout,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (legId != null) 'leg_id': legId,
      if (playerId != null) 'player_id': playerId,
      if (turnNumber != null) 'turn_number': turnNumber,
      if (score != null) 'score': score,
      if (dartsUsed != null) 'darts_used': dartsUsed,
      if (isBust != null) 'is_bust': isBust,
      if (isCheckout != null) 'is_checkout': isCheckout,
    });
  }

  TurnsCompanion copyWith({
    Value<int>? id,
    Value<int>? legId,
    Value<int>? playerId,
    Value<int>? turnNumber,
    Value<int>? score,
    Value<int>? dartsUsed,
    Value<bool>? isBust,
    Value<bool>? isCheckout,
  }) {
    return TurnsCompanion(
      id: id ?? this.id,
      legId: legId ?? this.legId,
      playerId: playerId ?? this.playerId,
      turnNumber: turnNumber ?? this.turnNumber,
      score: score ?? this.score,
      dartsUsed: dartsUsed ?? this.dartsUsed,
      isBust: isBust ?? this.isBust,
      isCheckout: isCheckout ?? this.isCheckout,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (legId.present) {
      map['leg_id'] = Variable<int>(legId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (turnNumber.present) {
      map['turn_number'] = Variable<int>(turnNumber.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (dartsUsed.present) {
      map['darts_used'] = Variable<int>(dartsUsed.value);
    }
    if (isBust.present) {
      map['is_bust'] = Variable<bool>(isBust.value);
    }
    if (isCheckout.present) {
      map['is_checkout'] = Variable<bool>(isCheckout.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnsCompanion(')
          ..write('id: $id, ')
          ..write('legId: $legId, ')
          ..write('playerId: $playerId, ')
          ..write('turnNumber: $turnNumber, ')
          ..write('score: $score, ')
          ..write('dartsUsed: $dartsUsed, ')
          ..write('isBust: $isBust, ')
          ..write('isCheckout: $isCheckout')
          ..write(')'))
        .toString();
  }
}

class $OpenEntriesTable extends OpenEntries
    with TableInfo<$OpenEntriesTable, OpenEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpenEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _openIdMeta = const VerificationMeta('openId');
  @override
  late final GeneratedColumn<int> openId = GeneratedColumn<int>(
    'open_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opens (id)',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalPlacementMeta = const VerificationMeta(
    'finalPlacement',
  );
  @override
  late final GeneratedColumn<int> finalPlacement = GeneratedColumn<int>(
    'final_placement',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    openId,
    playerId,
    seed,
    finalPlacement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'open_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpenEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('open_id')) {
      context.handle(
        _openIdMeta,
        openId.isAcceptableOrUnknown(data['open_id']!, _openIdMeta),
      );
    } else if (isInserting) {
      context.missing(_openIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    }
    if (data.containsKey('final_placement')) {
      context.handle(
        _finalPlacementMeta,
        finalPlacement.isAcceptableOrUnknown(
          data['final_placement']!,
          _finalPlacementMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {openId, playerId},
  ];
  @override
  OpenEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpenEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      openId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}open_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      ),
      finalPlacement: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}final_placement'],
      ),
    );
  }

  @override
  $OpenEntriesTable createAlias(String alias) {
    return $OpenEntriesTable(attachedDatabase, alias);
  }
}

class OpenEntryRow extends DataClass implements Insertable<OpenEntryRow> {
  final int id;
  final int openId;
  final int playerId;
  final int? seed;
  final int? finalPlacement;
  const OpenEntryRow({
    required this.id,
    required this.openId,
    required this.playerId,
    this.seed,
    this.finalPlacement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['open_id'] = Variable<int>(openId);
    map['player_id'] = Variable<int>(playerId);
    if (!nullToAbsent || seed != null) {
      map['seed'] = Variable<int>(seed);
    }
    if (!nullToAbsent || finalPlacement != null) {
      map['final_placement'] = Variable<int>(finalPlacement);
    }
    return map;
  }

  OpenEntriesCompanion toCompanion(bool nullToAbsent) {
    return OpenEntriesCompanion(
      id: Value(id),
      openId: Value(openId),
      playerId: Value(playerId),
      seed: seed == null && nullToAbsent ? const Value.absent() : Value(seed),
      finalPlacement: finalPlacement == null && nullToAbsent
          ? const Value.absent()
          : Value(finalPlacement),
    );
  }

  factory OpenEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpenEntryRow(
      id: serializer.fromJson<int>(json['id']),
      openId: serializer.fromJson<int>(json['openId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      seed: serializer.fromJson<int?>(json['seed']),
      finalPlacement: serializer.fromJson<int?>(json['finalPlacement']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'openId': serializer.toJson<int>(openId),
      'playerId': serializer.toJson<int>(playerId),
      'seed': serializer.toJson<int?>(seed),
      'finalPlacement': serializer.toJson<int?>(finalPlacement),
    };
  }

  OpenEntryRow copyWith({
    int? id,
    int? openId,
    int? playerId,
    Value<int?> seed = const Value.absent(),
    Value<int?> finalPlacement = const Value.absent(),
  }) => OpenEntryRow(
    id: id ?? this.id,
    openId: openId ?? this.openId,
    playerId: playerId ?? this.playerId,
    seed: seed.present ? seed.value : this.seed,
    finalPlacement: finalPlacement.present
        ? finalPlacement.value
        : this.finalPlacement,
  );
  OpenEntryRow copyWithCompanion(OpenEntriesCompanion data) {
    return OpenEntryRow(
      id: data.id.present ? data.id.value : this.id,
      openId: data.openId.present ? data.openId.value : this.openId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      seed: data.seed.present ? data.seed.value : this.seed,
      finalPlacement: data.finalPlacement.present
          ? data.finalPlacement.value
          : this.finalPlacement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpenEntryRow(')
          ..write('id: $id, ')
          ..write('openId: $openId, ')
          ..write('playerId: $playerId, ')
          ..write('seed: $seed, ')
          ..write('finalPlacement: $finalPlacement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, openId, playerId, seed, finalPlacement);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpenEntryRow &&
          other.id == this.id &&
          other.openId == this.openId &&
          other.playerId == this.playerId &&
          other.seed == this.seed &&
          other.finalPlacement == this.finalPlacement);
}

class OpenEntriesCompanion extends UpdateCompanion<OpenEntryRow> {
  final Value<int> id;
  final Value<int> openId;
  final Value<int> playerId;
  final Value<int?> seed;
  final Value<int?> finalPlacement;
  const OpenEntriesCompanion({
    this.id = const Value.absent(),
    this.openId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.seed = const Value.absent(),
    this.finalPlacement = const Value.absent(),
  });
  OpenEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int openId,
    required int playerId,
    this.seed = const Value.absent(),
    this.finalPlacement = const Value.absent(),
  }) : openId = Value(openId),
       playerId = Value(playerId);
  static Insertable<OpenEntryRow> custom({
    Expression<int>? id,
    Expression<int>? openId,
    Expression<int>? playerId,
    Expression<int>? seed,
    Expression<int>? finalPlacement,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openId != null) 'open_id': openId,
      if (playerId != null) 'player_id': playerId,
      if (seed != null) 'seed': seed,
      if (finalPlacement != null) 'final_placement': finalPlacement,
    });
  }

  OpenEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? openId,
    Value<int>? playerId,
    Value<int?>? seed,
    Value<int?>? finalPlacement,
  }) {
    return OpenEntriesCompanion(
      id: id ?? this.id,
      openId: openId ?? this.openId,
      playerId: playerId ?? this.playerId,
      seed: seed ?? this.seed,
      finalPlacement: finalPlacement ?? this.finalPlacement,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (openId.present) {
      map['open_id'] = Variable<int>(openId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (finalPlacement.present) {
      map['final_placement'] = Variable<int>(finalPlacement.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpenEntriesCompanion(')
          ..write('id: $id, ')
          ..write('openId: $openId, ')
          ..write('playerId: $playerId, ')
          ..write('seed: $seed, ')
          ..write('finalPlacement: $finalPlacement')
          ..write(')'))
        .toString();
  }
}

class $BracketNodesTable extends BracketNodes
    with TableInfo<$BracketNodesTable, BracketNodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BracketNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _openIdMeta = const VerificationMeta('openId');
  @override
  late final GeneratedColumn<int> openId = GeneratedColumn<int>(
    'open_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES opens (id)',
    ),
  );
  static const VerificationMeta _nodeKeyMeta = const VerificationMeta(
    'nodeKey',
  );
  @override
  late final GeneratedColumn<String> nodeKey = GeneratedColumn<String>(
    'node_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bracketMeta = const VerificationMeta(
    'bracket',
  );
  @override
  late final GeneratedColumn<String> bracket = GeneratedColumn<String>(
    'bracket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
    'round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerAIdMeta = const VerificationMeta(
    'playerAId',
  );
  @override
  late final GeneratedColumn<int> playerAId = GeneratedColumn<int>(
    'player_a_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _playerBIdMeta = const VerificationMeta(
    'playerBId',
  );
  @override
  late final GeneratedColumn<int> playerBId = GeneratedColumn<int>(
    'player_b_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _winnerToKeyMeta = const VerificationMeta(
    'winnerToKey',
  );
  @override
  late final GeneratedColumn<String> winnerToKey = GeneratedColumn<String>(
    'winner_to_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _winnerToSlotMeta = const VerificationMeta(
    'winnerToSlot',
  );
  @override
  late final GeneratedColumn<String> winnerToSlot = GeneratedColumn<String>(
    'winner_to_slot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loserToKeyMeta = const VerificationMeta(
    'loserToKey',
  );
  @override
  late final GeneratedColumn<String> loserToKey = GeneratedColumn<String>(
    'loser_to_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loserToSlotMeta = const VerificationMeta(
    'loserToSlot',
  );
  @override
  late final GeneratedColumn<String> loserToSlot = GeneratedColumn<String>(
    'loser_to_slot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _winnerIdMeta = const VerificationMeta(
    'winnerId',
  );
  @override
  late final GeneratedColumn<int> winnerId = GeneratedColumn<int>(
    'winner_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _markerIdMeta = const VerificationMeta(
    'markerId',
  );
  @override
  late final GeneratedColumn<int> markerId = GeneratedColumn<int>(
    'marker_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
    'match_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES matches (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    openId,
    nodeKey,
    bracket,
    round,
    position,
    playerAId,
    playerBId,
    winnerToKey,
    winnerToSlot,
    loserToKey,
    loserToSlot,
    status,
    winnerId,
    markerId,
    matchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bracket_nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BracketNodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('open_id')) {
      context.handle(
        _openIdMeta,
        openId.isAcceptableOrUnknown(data['open_id']!, _openIdMeta),
      );
    } else if (isInserting) {
      context.missing(_openIdMeta);
    }
    if (data.containsKey('node_key')) {
      context.handle(
        _nodeKeyMeta,
        nodeKey.isAcceptableOrUnknown(data['node_key']!, _nodeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeKeyMeta);
    }
    if (data.containsKey('bracket')) {
      context.handle(
        _bracketMeta,
        bracket.isAcceptableOrUnknown(data['bracket']!, _bracketMeta),
      );
    } else if (isInserting) {
      context.missing(_bracketMeta);
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    } else if (isInserting) {
      context.missing(_roundMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('player_a_id')) {
      context.handle(
        _playerAIdMeta,
        playerAId.isAcceptableOrUnknown(data['player_a_id']!, _playerAIdMeta),
      );
    }
    if (data.containsKey('player_b_id')) {
      context.handle(
        _playerBIdMeta,
        playerBId.isAcceptableOrUnknown(data['player_b_id']!, _playerBIdMeta),
      );
    }
    if (data.containsKey('winner_to_key')) {
      context.handle(
        _winnerToKeyMeta,
        winnerToKey.isAcceptableOrUnknown(
          data['winner_to_key']!,
          _winnerToKeyMeta,
        ),
      );
    }
    if (data.containsKey('winner_to_slot')) {
      context.handle(
        _winnerToSlotMeta,
        winnerToSlot.isAcceptableOrUnknown(
          data['winner_to_slot']!,
          _winnerToSlotMeta,
        ),
      );
    }
    if (data.containsKey('loser_to_key')) {
      context.handle(
        _loserToKeyMeta,
        loserToKey.isAcceptableOrUnknown(
          data['loser_to_key']!,
          _loserToKeyMeta,
        ),
      );
    }
    if (data.containsKey('loser_to_slot')) {
      context.handle(
        _loserToSlotMeta,
        loserToSlot.isAcceptableOrUnknown(
          data['loser_to_slot']!,
          _loserToSlotMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('winner_id')) {
      context.handle(
        _winnerIdMeta,
        winnerId.isAcceptableOrUnknown(data['winner_id']!, _winnerIdMeta),
      );
    }
    if (data.containsKey('marker_id')) {
      context.handle(
        _markerIdMeta,
        markerId.isAcceptableOrUnknown(data['marker_id']!, _markerIdMeta),
      );
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {openId, nodeKey},
  ];
  @override
  BracketNodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BracketNodeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      openId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}open_id'],
      )!,
      nodeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_key'],
      )!,
      bracket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bracket'],
      )!,
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      playerAId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_a_id'],
      ),
      playerBId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_b_id'],
      ),
      winnerToKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner_to_key'],
      ),
      winnerToSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner_to_slot'],
      ),
      loserToKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loser_to_key'],
      ),
      loserToSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loser_to_slot'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      winnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}winner_id'],
      ),
      markerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marker_id'],
      ),
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_id'],
      ),
    );
  }

  @override
  $BracketNodesTable createAlias(String alias) {
    return $BracketNodesTable(attachedDatabase, alias);
  }
}

class BracketNodeRow extends DataClass implements Insertable<BracketNodeRow> {
  final int id;
  final int openId;
  final String nodeKey;
  final String bracket;
  final int round;
  final int position;
  final int? playerAId;
  final int? playerBId;
  final String? winnerToKey;
  final String? winnerToSlot;
  final String? loserToKey;
  final String? loserToSlot;
  final String status;
  final int? winnerId;
  final int? markerId;
  final int? matchId;
  const BracketNodeRow({
    required this.id,
    required this.openId,
    required this.nodeKey,
    required this.bracket,
    required this.round,
    required this.position,
    this.playerAId,
    this.playerBId,
    this.winnerToKey,
    this.winnerToSlot,
    this.loserToKey,
    this.loserToSlot,
    required this.status,
    this.winnerId,
    this.markerId,
    this.matchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['open_id'] = Variable<int>(openId);
    map['node_key'] = Variable<String>(nodeKey);
    map['bracket'] = Variable<String>(bracket);
    map['round'] = Variable<int>(round);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || playerAId != null) {
      map['player_a_id'] = Variable<int>(playerAId);
    }
    if (!nullToAbsent || playerBId != null) {
      map['player_b_id'] = Variable<int>(playerBId);
    }
    if (!nullToAbsent || winnerToKey != null) {
      map['winner_to_key'] = Variable<String>(winnerToKey);
    }
    if (!nullToAbsent || winnerToSlot != null) {
      map['winner_to_slot'] = Variable<String>(winnerToSlot);
    }
    if (!nullToAbsent || loserToKey != null) {
      map['loser_to_key'] = Variable<String>(loserToKey);
    }
    if (!nullToAbsent || loserToSlot != null) {
      map['loser_to_slot'] = Variable<String>(loserToSlot);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || winnerId != null) {
      map['winner_id'] = Variable<int>(winnerId);
    }
    if (!nullToAbsent || markerId != null) {
      map['marker_id'] = Variable<int>(markerId);
    }
    if (!nullToAbsent || matchId != null) {
      map['match_id'] = Variable<int>(matchId);
    }
    return map;
  }

  BracketNodesCompanion toCompanion(bool nullToAbsent) {
    return BracketNodesCompanion(
      id: Value(id),
      openId: Value(openId),
      nodeKey: Value(nodeKey),
      bracket: Value(bracket),
      round: Value(round),
      position: Value(position),
      playerAId: playerAId == null && nullToAbsent
          ? const Value.absent()
          : Value(playerAId),
      playerBId: playerBId == null && nullToAbsent
          ? const Value.absent()
          : Value(playerBId),
      winnerToKey: winnerToKey == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerToKey),
      winnerToSlot: winnerToSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerToSlot),
      loserToKey: loserToKey == null && nullToAbsent
          ? const Value.absent()
          : Value(loserToKey),
      loserToSlot: loserToSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(loserToSlot),
      status: Value(status),
      winnerId: winnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerId),
      markerId: markerId == null && nullToAbsent
          ? const Value.absent()
          : Value(markerId),
      matchId: matchId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchId),
    );
  }

  factory BracketNodeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BracketNodeRow(
      id: serializer.fromJson<int>(json['id']),
      openId: serializer.fromJson<int>(json['openId']),
      nodeKey: serializer.fromJson<String>(json['nodeKey']),
      bracket: serializer.fromJson<String>(json['bracket']),
      round: serializer.fromJson<int>(json['round']),
      position: serializer.fromJson<int>(json['position']),
      playerAId: serializer.fromJson<int?>(json['playerAId']),
      playerBId: serializer.fromJson<int?>(json['playerBId']),
      winnerToKey: serializer.fromJson<String?>(json['winnerToKey']),
      winnerToSlot: serializer.fromJson<String?>(json['winnerToSlot']),
      loserToKey: serializer.fromJson<String?>(json['loserToKey']),
      loserToSlot: serializer.fromJson<String?>(json['loserToSlot']),
      status: serializer.fromJson<String>(json['status']),
      winnerId: serializer.fromJson<int?>(json['winnerId']),
      markerId: serializer.fromJson<int?>(json['markerId']),
      matchId: serializer.fromJson<int?>(json['matchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'openId': serializer.toJson<int>(openId),
      'nodeKey': serializer.toJson<String>(nodeKey),
      'bracket': serializer.toJson<String>(bracket),
      'round': serializer.toJson<int>(round),
      'position': serializer.toJson<int>(position),
      'playerAId': serializer.toJson<int?>(playerAId),
      'playerBId': serializer.toJson<int?>(playerBId),
      'winnerToKey': serializer.toJson<String?>(winnerToKey),
      'winnerToSlot': serializer.toJson<String?>(winnerToSlot),
      'loserToKey': serializer.toJson<String?>(loserToKey),
      'loserToSlot': serializer.toJson<String?>(loserToSlot),
      'status': serializer.toJson<String>(status),
      'winnerId': serializer.toJson<int?>(winnerId),
      'markerId': serializer.toJson<int?>(markerId),
      'matchId': serializer.toJson<int?>(matchId),
    };
  }

  BracketNodeRow copyWith({
    int? id,
    int? openId,
    String? nodeKey,
    String? bracket,
    int? round,
    int? position,
    Value<int?> playerAId = const Value.absent(),
    Value<int?> playerBId = const Value.absent(),
    Value<String?> winnerToKey = const Value.absent(),
    Value<String?> winnerToSlot = const Value.absent(),
    Value<String?> loserToKey = const Value.absent(),
    Value<String?> loserToSlot = const Value.absent(),
    String? status,
    Value<int?> winnerId = const Value.absent(),
    Value<int?> markerId = const Value.absent(),
    Value<int?> matchId = const Value.absent(),
  }) => BracketNodeRow(
    id: id ?? this.id,
    openId: openId ?? this.openId,
    nodeKey: nodeKey ?? this.nodeKey,
    bracket: bracket ?? this.bracket,
    round: round ?? this.round,
    position: position ?? this.position,
    playerAId: playerAId.present ? playerAId.value : this.playerAId,
    playerBId: playerBId.present ? playerBId.value : this.playerBId,
    winnerToKey: winnerToKey.present ? winnerToKey.value : this.winnerToKey,
    winnerToSlot: winnerToSlot.present ? winnerToSlot.value : this.winnerToSlot,
    loserToKey: loserToKey.present ? loserToKey.value : this.loserToKey,
    loserToSlot: loserToSlot.present ? loserToSlot.value : this.loserToSlot,
    status: status ?? this.status,
    winnerId: winnerId.present ? winnerId.value : this.winnerId,
    markerId: markerId.present ? markerId.value : this.markerId,
    matchId: matchId.present ? matchId.value : this.matchId,
  );
  BracketNodeRow copyWithCompanion(BracketNodesCompanion data) {
    return BracketNodeRow(
      id: data.id.present ? data.id.value : this.id,
      openId: data.openId.present ? data.openId.value : this.openId,
      nodeKey: data.nodeKey.present ? data.nodeKey.value : this.nodeKey,
      bracket: data.bracket.present ? data.bracket.value : this.bracket,
      round: data.round.present ? data.round.value : this.round,
      position: data.position.present ? data.position.value : this.position,
      playerAId: data.playerAId.present ? data.playerAId.value : this.playerAId,
      playerBId: data.playerBId.present ? data.playerBId.value : this.playerBId,
      winnerToKey: data.winnerToKey.present
          ? data.winnerToKey.value
          : this.winnerToKey,
      winnerToSlot: data.winnerToSlot.present
          ? data.winnerToSlot.value
          : this.winnerToSlot,
      loserToKey: data.loserToKey.present
          ? data.loserToKey.value
          : this.loserToKey,
      loserToSlot: data.loserToSlot.present
          ? data.loserToSlot.value
          : this.loserToSlot,
      status: data.status.present ? data.status.value : this.status,
      winnerId: data.winnerId.present ? data.winnerId.value : this.winnerId,
      markerId: data.markerId.present ? data.markerId.value : this.markerId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BracketNodeRow(')
          ..write('id: $id, ')
          ..write('openId: $openId, ')
          ..write('nodeKey: $nodeKey, ')
          ..write('bracket: $bracket, ')
          ..write('round: $round, ')
          ..write('position: $position, ')
          ..write('playerAId: $playerAId, ')
          ..write('playerBId: $playerBId, ')
          ..write('winnerToKey: $winnerToKey, ')
          ..write('winnerToSlot: $winnerToSlot, ')
          ..write('loserToKey: $loserToKey, ')
          ..write('loserToSlot: $loserToSlot, ')
          ..write('status: $status, ')
          ..write('winnerId: $winnerId, ')
          ..write('markerId: $markerId, ')
          ..write('matchId: $matchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    openId,
    nodeKey,
    bracket,
    round,
    position,
    playerAId,
    playerBId,
    winnerToKey,
    winnerToSlot,
    loserToKey,
    loserToSlot,
    status,
    winnerId,
    markerId,
    matchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BracketNodeRow &&
          other.id == this.id &&
          other.openId == this.openId &&
          other.nodeKey == this.nodeKey &&
          other.bracket == this.bracket &&
          other.round == this.round &&
          other.position == this.position &&
          other.playerAId == this.playerAId &&
          other.playerBId == this.playerBId &&
          other.winnerToKey == this.winnerToKey &&
          other.winnerToSlot == this.winnerToSlot &&
          other.loserToKey == this.loserToKey &&
          other.loserToSlot == this.loserToSlot &&
          other.status == this.status &&
          other.winnerId == this.winnerId &&
          other.markerId == this.markerId &&
          other.matchId == this.matchId);
}

class BracketNodesCompanion extends UpdateCompanion<BracketNodeRow> {
  final Value<int> id;
  final Value<int> openId;
  final Value<String> nodeKey;
  final Value<String> bracket;
  final Value<int> round;
  final Value<int> position;
  final Value<int?> playerAId;
  final Value<int?> playerBId;
  final Value<String?> winnerToKey;
  final Value<String?> winnerToSlot;
  final Value<String?> loserToKey;
  final Value<String?> loserToSlot;
  final Value<String> status;
  final Value<int?> winnerId;
  final Value<int?> markerId;
  final Value<int?> matchId;
  const BracketNodesCompanion({
    this.id = const Value.absent(),
    this.openId = const Value.absent(),
    this.nodeKey = const Value.absent(),
    this.bracket = const Value.absent(),
    this.round = const Value.absent(),
    this.position = const Value.absent(),
    this.playerAId = const Value.absent(),
    this.playerBId = const Value.absent(),
    this.winnerToKey = const Value.absent(),
    this.winnerToSlot = const Value.absent(),
    this.loserToKey = const Value.absent(),
    this.loserToSlot = const Value.absent(),
    this.status = const Value.absent(),
    this.winnerId = const Value.absent(),
    this.markerId = const Value.absent(),
    this.matchId = const Value.absent(),
  });
  BracketNodesCompanion.insert({
    this.id = const Value.absent(),
    required int openId,
    required String nodeKey,
    required String bracket,
    required int round,
    required int position,
    this.playerAId = const Value.absent(),
    this.playerBId = const Value.absent(),
    this.winnerToKey = const Value.absent(),
    this.winnerToSlot = const Value.absent(),
    this.loserToKey = const Value.absent(),
    this.loserToSlot = const Value.absent(),
    this.status = const Value.absent(),
    this.winnerId = const Value.absent(),
    this.markerId = const Value.absent(),
    this.matchId = const Value.absent(),
  }) : openId = Value(openId),
       nodeKey = Value(nodeKey),
       bracket = Value(bracket),
       round = Value(round),
       position = Value(position);
  static Insertable<BracketNodeRow> custom({
    Expression<int>? id,
    Expression<int>? openId,
    Expression<String>? nodeKey,
    Expression<String>? bracket,
    Expression<int>? round,
    Expression<int>? position,
    Expression<int>? playerAId,
    Expression<int>? playerBId,
    Expression<String>? winnerToKey,
    Expression<String>? winnerToSlot,
    Expression<String>? loserToKey,
    Expression<String>? loserToSlot,
    Expression<String>? status,
    Expression<int>? winnerId,
    Expression<int>? markerId,
    Expression<int>? matchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openId != null) 'open_id': openId,
      if (nodeKey != null) 'node_key': nodeKey,
      if (bracket != null) 'bracket': bracket,
      if (round != null) 'round': round,
      if (position != null) 'position': position,
      if (playerAId != null) 'player_a_id': playerAId,
      if (playerBId != null) 'player_b_id': playerBId,
      if (winnerToKey != null) 'winner_to_key': winnerToKey,
      if (winnerToSlot != null) 'winner_to_slot': winnerToSlot,
      if (loserToKey != null) 'loser_to_key': loserToKey,
      if (loserToSlot != null) 'loser_to_slot': loserToSlot,
      if (status != null) 'status': status,
      if (winnerId != null) 'winner_id': winnerId,
      if (markerId != null) 'marker_id': markerId,
      if (matchId != null) 'match_id': matchId,
    });
  }

  BracketNodesCompanion copyWith({
    Value<int>? id,
    Value<int>? openId,
    Value<String>? nodeKey,
    Value<String>? bracket,
    Value<int>? round,
    Value<int>? position,
    Value<int?>? playerAId,
    Value<int?>? playerBId,
    Value<String?>? winnerToKey,
    Value<String?>? winnerToSlot,
    Value<String?>? loserToKey,
    Value<String?>? loserToSlot,
    Value<String>? status,
    Value<int?>? winnerId,
    Value<int?>? markerId,
    Value<int?>? matchId,
  }) {
    return BracketNodesCompanion(
      id: id ?? this.id,
      openId: openId ?? this.openId,
      nodeKey: nodeKey ?? this.nodeKey,
      bracket: bracket ?? this.bracket,
      round: round ?? this.round,
      position: position ?? this.position,
      playerAId: playerAId ?? this.playerAId,
      playerBId: playerBId ?? this.playerBId,
      winnerToKey: winnerToKey ?? this.winnerToKey,
      winnerToSlot: winnerToSlot ?? this.winnerToSlot,
      loserToKey: loserToKey ?? this.loserToKey,
      loserToSlot: loserToSlot ?? this.loserToSlot,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      markerId: markerId ?? this.markerId,
      matchId: matchId ?? this.matchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (openId.present) {
      map['open_id'] = Variable<int>(openId.value);
    }
    if (nodeKey.present) {
      map['node_key'] = Variable<String>(nodeKey.value);
    }
    if (bracket.present) {
      map['bracket'] = Variable<String>(bracket.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (playerAId.present) {
      map['player_a_id'] = Variable<int>(playerAId.value);
    }
    if (playerBId.present) {
      map['player_b_id'] = Variable<int>(playerBId.value);
    }
    if (winnerToKey.present) {
      map['winner_to_key'] = Variable<String>(winnerToKey.value);
    }
    if (winnerToSlot.present) {
      map['winner_to_slot'] = Variable<String>(winnerToSlot.value);
    }
    if (loserToKey.present) {
      map['loser_to_key'] = Variable<String>(loserToKey.value);
    }
    if (loserToSlot.present) {
      map['loser_to_slot'] = Variable<String>(loserToSlot.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (winnerId.present) {
      map['winner_id'] = Variable<int>(winnerId.value);
    }
    if (markerId.present) {
      map['marker_id'] = Variable<int>(markerId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BracketNodesCompanion(')
          ..write('id: $id, ')
          ..write('openId: $openId, ')
          ..write('nodeKey: $nodeKey, ')
          ..write('bracket: $bracket, ')
          ..write('round: $round, ')
          ..write('position: $position, ')
          ..write('playerAId: $playerAId, ')
          ..write('playerBId: $playerBId, ')
          ..write('winnerToKey: $winnerToKey, ')
          ..write('winnerToSlot: $winnerToSlot, ')
          ..write('loserToKey: $loserToKey, ')
          ..write('loserToSlot: $loserToSlot, ')
          ..write('status: $status, ')
          ..write('winnerId: $winnerId, ')
          ..write('markerId: $markerId, ')
          ..write('matchId: $matchId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $OpensTable opens = $OpensTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $LegsTable legs = $LegsTable(this);
  late final $TurnsTable turns = $TurnsTable(this);
  late final $OpenEntriesTable openEntries = $OpenEntriesTable(this);
  late final $BracketNodesTable bracketNodes = $BracketNodesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    opens,
    matches,
    legs,
    turns,
    openEntries,
    bracketNodes,
  ];
}

typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  Value<int> id,
  required String name,
  Value<DateTime> createdAt,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
});

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TurnsTable, List<Turn>> _turnsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.turns,
    aliasName: 'players__id__turns__player_id',
  );

  $$TurnsTableProcessedTableManager get turnsRefs {
    final manager = $$TurnsTableTableManager(
      $_db,
      $_db.turns,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_turnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OpenEntriesTable, List<OpenEntryRow>>
  _openEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.openEntries,
    aliasName: 'players__id__open_entries__player_id',
  );

  $$OpenEntriesTableProcessedTableManager get openEntriesRefs {
    final manager = $$OpenEntriesTableTableManager(
      $_db,
      $_db.openEntries,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_openEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> turnsRefs(
    Expression<bool> Function($$TurnsTableFilterComposer f) f,
  ) {
    final $$TurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableFilterComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> openEntriesRefs(
    Expression<bool> Function($$OpenEntriesTableFilterComposer f) f,
  ) {
    final $$OpenEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.openEntries,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpenEntriesTableFilterComposer(
            $db: $db,
            $table: $db.openEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> turnsRefs<T extends Object>(
    Expression<T> Function($$TurnsTableAnnotationComposer a) f,
  ) {
    final $$TurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> openEntriesRefs<T extends Object>(
    Expression<T> Function($$OpenEntriesTableAnnotationComposer a) f,
  ) {
    final $$OpenEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.openEntries,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpenEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.openEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({bool turnsRefs, bool openEntriesRefs})
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => PlayersCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayersTable, Player>(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({turnsRefs = false, openEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (turnsRefs) db.turns,
                    if (openEntriesRefs) db.openEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (turnsRefs)
                        await $_getPrefetchedData<Player, $PlayersTable, Turn>(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._turnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(db, table, p0).turnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (openEntriesRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          OpenEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._openEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).openEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({bool turnsRefs, bool openEntriesRefs})
    >;
typedef $$OpensTableCreateCompanionBuilder = OpensCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> location,
  Value<DateTime?> date,
  Value<int> bestOf,
  Value<String> format,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<bool> grandFinalReset,
});
typedef $$OpensTableUpdateCompanionBuilder = OpensCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> location,
  Value<DateTime?> date,
  Value<int> bestOf,
  Value<String> format,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<bool> grandFinalReset,
});

final class $$OpensTableReferences
    extends BaseReferences<_$AppDatabase, $OpensTable, Open> {
  $$OpensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MatchesTable, List<DartMatch>> _matchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: 'opens__id__matches__open_id',
  );

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.openId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OpenEntriesTable, List<OpenEntryRow>>
  _openEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.openEntries,
    aliasName: 'opens__id__open_entries__open_id',
  );

  $$OpenEntriesTableProcessedTableManager get openEntriesRefs {
    final manager = $$OpenEntriesTableTableManager(
      $_db,
      $_db.openEntries,
    ).filter((f) => f.openId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_openEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BracketNodesTable, List<BracketNodeRow>>
  _bracketNodesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bracketNodes,
    aliasName: 'opens__id__bracket_nodes__open_id',
  );

  $$BracketNodesTableProcessedTableManager get bracketNodesRefs {
    final manager = $$BracketNodesTableTableManager(
      $_db,
      $_db.bracketNodes,
    ).filter((f) => f.openId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bracketNodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OpensTableFilterComposer extends Composer<_$AppDatabase, $OpensTable> {
  $$OpensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestOf => $composableBuilder(
    column: $table.bestOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get grandFinalReset => $composableBuilder(
    column: $table.grandFinalReset,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> matchesRefs(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.openId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> openEntriesRefs(
    Expression<bool> Function($$OpenEntriesTableFilterComposer f) f,
  ) {
    final $$OpenEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.openEntries,
      getReferencedColumn: (t) => t.openId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpenEntriesTableFilterComposer(
            $db: $db,
            $table: $db.openEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bracketNodesRefs(
    Expression<bool> Function($$BracketNodesTableFilterComposer f) f,
  ) {
    final $$BracketNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bracketNodes,
      getReferencedColumn: (t) => t.openId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BracketNodesTableFilterComposer(
            $db: $db,
            $table: $db.bracketNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OpensTableOrderingComposer
    extends Composer<_$AppDatabase, $OpensTable> {
  $$OpensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestOf => $composableBuilder(
    column: $table.bestOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get grandFinalReset => $composableBuilder(
    column: $table.grandFinalReset,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpensTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpensTable> {
  $$OpensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get bestOf =>
      $composableBuilder(column: $table.bestOf, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get grandFinalReset => $composableBuilder(
    column: $table.grandFinalReset,
    builder: (column) => column,
  );

  Expression<T> matchesRefs<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.openId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> openEntriesRefs<T extends Object>(
    Expression<T> Function($$OpenEntriesTableAnnotationComposer a) f,
  ) {
    final $$OpenEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.openEntries,
      getReferencedColumn: (t) => t.openId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpenEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.openEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bracketNodesRefs<T extends Object>(
    Expression<T> Function($$BracketNodesTableAnnotationComposer a) f,
  ) {
    final $$BracketNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bracketNodes,
      getReferencedColumn: (t) => t.openId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BracketNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.bracketNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OpensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpensTable,
          Open,
          $$OpensTableFilterComposer,
          $$OpensTableOrderingComposer,
          $$OpensTableAnnotationComposer,
          $$OpensTableCreateCompanionBuilder,
          $$OpensTableUpdateCompanionBuilder,
          (Open, $$OpensTableReferences),
          Open,
          PrefetchHooks Function({
            bool matchesRefs,
            bool openEntriesRefs,
            bool bracketNodesRefs,
          })
        > {
  $$OpensTableTableManager(_$AppDatabase db, $OpensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<int> bestOf = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> grandFinalReset = const Value.absent(),
              }) => OpensCompanion(
                id: id,
                name: name,
                location: location,
                date: date,
                bestOf: bestOf,
                format: format,
                status: status,
                createdAt: createdAt,
                grandFinalReset: grandFinalReset,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> location = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<int> bestOf = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> grandFinalReset = const Value.absent(),
              }) => OpensCompanion.insert(
                id: id,
                name: name,
                location: location,
                date: date,
                bestOf: bestOf,
                format: format,
                status: status,
                createdAt: createdAt,
                grandFinalReset: grandFinalReset,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpensTable, Open>(table),
                  $$OpensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                matchesRefs = false,
                openEntriesRefs = false,
                bracketNodesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (matchesRefs) db.matches,
                    if (openEntriesRefs) db.openEntries,
                    if (bracketNodesRefs) db.bracketNodes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchesRefs)
                        await $_getPrefetchedData<Open, $OpensTable, DartMatch>(
                          currentTable: table,
                          referencedTable: $$OpensTableReferences
                              ._matchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpensTableReferences(db, table, p0).matchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.openId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (openEntriesRefs)
                        await $_getPrefetchedData<
                          Open,
                          $OpensTable,
                          OpenEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$OpensTableReferences
                              ._openEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpensTableReferences(
                                db,
                                table,
                                p0,
                              ).openEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.openId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bracketNodesRefs)
                        await $_getPrefetchedData<
                          Open,
                          $OpensTable,
                          BracketNodeRow
                        >(
                          currentTable: table,
                          referencedTable: $$OpensTableReferences
                              ._bracketNodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpensTableReferences(
                                db,
                                table,
                                p0,
                              ).bracketNodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.openId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OpensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpensTable,
      Open,
      $$OpensTableFilterComposer,
      $$OpensTableOrderingComposer,
      $$OpensTableAnnotationComposer,
      $$OpensTableCreateCompanionBuilder,
      $$OpensTableUpdateCompanionBuilder,
      (Open, $$OpensTableReferences),
      Open,
      PrefetchHooks Function({
        bool matchesRefs,
        bool openEntriesRefs,
        bool bracketNodesRefs,
      })
    >;
typedef $$MatchesTableCreateCompanionBuilder = MatchesCompanion Function({
  Value<int> id,
  Value<int?> openId,
  required int player1Id,
  required int player2Id,
  Value<int?> markerId,
  required int bestOf,
  Value<String> status,
  Value<int?> winnerId,
  Value<int?> round,
  Value<DateTime> createdAt,
  Value<DateTime?> finishedAt,
});
typedef $$MatchesTableUpdateCompanionBuilder = MatchesCompanion Function({
  Value<int> id,
  Value<int?> openId,
  Value<int> player1Id,
  Value<int> player2Id,
  Value<int?> markerId,
  Value<int> bestOf,
  Value<String> status,
  Value<int?> winnerId,
  Value<int?> round,
  Value<DateTime> createdAt,
  Value<DateTime?> finishedAt,
});

final class $$MatchesTableReferences
    extends BaseReferences<_$AppDatabase, $MatchesTable, DartMatch> {
  $$MatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OpensTable _openIdTable(_$AppDatabase db) =>
      db.opens.createAlias('matches__open_id__opens__id');

  $$OpensTableProcessedTableManager? get openId {
    final $_column = $_itemColumn<int>('open_id');
    if ($_column == null) return null;
    final manager = $$OpensTableTableManager(
      $_db,
      $_db.opens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_openIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _player1IdTable(_$AppDatabase db) =>
      db.players.createAlias('matches__player1_id__players__id');

  $$PlayersTableProcessedTableManager get player1Id {
    final $_column = $_itemColumn<int>('player1_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_player1IdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _player2IdTable(_$AppDatabase db) =>
      db.players.createAlias('matches__player2_id__players__id');

  $$PlayersTableProcessedTableManager get player2Id {
    final $_column = $_itemColumn<int>('player2_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_player2IdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _markerIdTable(_$AppDatabase db) =>
      db.players.createAlias('matches__marker_id__players__id');

  $$PlayersTableProcessedTableManager? get markerId {
    final $_column = $_itemColumn<int>('marker_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_markerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _winnerIdTable(_$AppDatabase db) =>
      db.players.createAlias('matches__winner_id__players__id');

  $$PlayersTableProcessedTableManager? get winnerId {
    final $_column = $_itemColumn<int>('winner_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_winnerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LegsTable, List<Leg>> _legsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.legs,
    aliasName: 'matches__id__legs__match_id',
  );

  $$LegsTableProcessedTableManager get legsRefs {
    final manager = $$LegsTableTableManager(
      $_db,
      $_db.legs,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_legsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BracketNodesTable, List<BracketNodeRow>>
  _bracketNodesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bracketNodes,
    aliasName: 'matches__id__bracket_nodes__match_id',
  );

  $$BracketNodesTableProcessedTableManager get bracketNodesRefs {
    final manager = $$BracketNodesTableTableManager(
      $_db,
      $_db.bracketNodes,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bracketNodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestOf => $composableBuilder(
    column: $table.bestOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OpensTableFilterComposer get openId {
    final $$OpensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableFilterComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get player1Id {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player1Id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get player2Id {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player2Id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get markerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get winnerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> legsRefs(
    Expression<bool> Function($$LegsTableFilterComposer f) f,
  ) {
    final $$LegsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.legs,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegsTableFilterComposer(
            $db: $db,
            $table: $db.legs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bracketNodesRefs(
    Expression<bool> Function($$BracketNodesTableFilterComposer f) f,
  ) {
    final $$BracketNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bracketNodes,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BracketNodesTableFilterComposer(
            $db: $db,
            $table: $db.bracketNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestOf => $composableBuilder(
    column: $table.bestOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OpensTableOrderingComposer get openId {
    final $$OpensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableOrderingComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get player1Id {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player1Id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get player2Id {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player2Id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get markerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get winnerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bestOf =>
      $composableBuilder(column: $table.bestOf, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$OpensTableAnnotationComposer get openId {
    final $$OpensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableAnnotationComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get player1Id {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player1Id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get player2Id {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player2Id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get markerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get winnerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> legsRefs<T extends Object>(
    Expression<T> Function($$LegsTableAnnotationComposer a) f,
  ) {
    final $$LegsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.legs,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegsTableAnnotationComposer(
            $db: $db,
            $table: $db.legs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bracketNodesRefs<T extends Object>(
    Expression<T> Function($$BracketNodesTableAnnotationComposer a) f,
  ) {
    final $$BracketNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bracketNodes,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BracketNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.bracketNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTable,
          DartMatch,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (DartMatch, $$MatchesTableReferences),
          DartMatch,
          PrefetchHooks Function({
            bool openId,
            bool player1Id,
            bool player2Id,
            bool markerId,
            bool winnerId,
            bool legsRefs,
            bool bracketNodesRefs,
          })
        > {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> openId = const Value.absent(),
                Value<int> player1Id = const Value.absent(),
                Value<int> player2Id = const Value.absent(),
                Value<int?> markerId = const Value.absent(),
                Value<int> bestOf = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> winnerId = const Value.absent(),
                Value<int?> round = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                openId: openId,
                player1Id: player1Id,
                player2Id: player2Id,
                markerId: markerId,
                bestOf: bestOf,
                status: status,
                winnerId: winnerId,
                round: round,
                createdAt: createdAt,
                finishedAt: finishedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> openId = const Value.absent(),
                required int player1Id,
                required int player2Id,
                Value<int?> markerId = const Value.absent(),
                required int bestOf,
                Value<String> status = const Value.absent(),
                Value<int?> winnerId = const Value.absent(),
                Value<int?> round = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                openId: openId,
                player1Id: player1Id,
                player2Id: player2Id,
                markerId: markerId,
                bestOf: bestOf,
                status: status,
                winnerId: winnerId,
                round: round,
                createdAt: createdAt,
                finishedAt: finishedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MatchesTable, DartMatch>(table),
                  $$MatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                openId = false,
                player1Id = false,
                player2Id = false,
                markerId = false,
                winnerId = false,
                legsRefs = false,
                bracketNodesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (legsRefs) db.legs,
                    if (bracketNodesRefs) db.bracketNodes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (openId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.openId,
                            referencedTable: $$MatchesTableReferences
                                ._openIdTable(db),
                            referencedColumn: $$MatchesTableReferences
                                ._openIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (player1Id) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.player1Id,
                            referencedTable: $$MatchesTableReferences
                                ._player1IdTable(db),
                            referencedColumn: $$MatchesTableReferences
                                ._player1IdTable(db)
                                .id,
                          ) as T;
                        }
                        if (player2Id) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.player2Id,
                            referencedTable: $$MatchesTableReferences
                                ._player2IdTable(db),
                            referencedColumn: $$MatchesTableReferences
                                ._player2IdTable(db)
                                .id,
                          ) as T;
                        }
                        if (markerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.markerId,
                            referencedTable: $$MatchesTableReferences
                                ._markerIdTable(db),
                            referencedColumn: $$MatchesTableReferences
                                ._markerIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (winnerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.winnerId,
                            referencedTable: $$MatchesTableReferences
                                ._winnerIdTable(db),
                            referencedColumn: $$MatchesTableReferences
                                ._winnerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (legsRefs)
                        await $_getPrefetchedData<
                          DartMatch,
                          $MatchesTable,
                          Leg
                        >(
                          currentTable: table,
                          referencedTable: $$MatchesTableReferences
                              ._legsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MatchesTableReferences(db, table, p0).legsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.matchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bracketNodesRefs)
                        await $_getPrefetchedData<
                          DartMatch,
                          $MatchesTable,
                          BracketNodeRow
                        >(
                          currentTable: table,
                          referencedTable: $$MatchesTableReferences
                              ._bracketNodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).bracketNodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.matchId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTable,
      DartMatch,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (DartMatch, $$MatchesTableReferences),
      DartMatch,
      PrefetchHooks Function({
        bool openId,
        bool player1Id,
        bool player2Id,
        bool markerId,
        bool winnerId,
        bool legsRefs,
        bool bracketNodesRefs,
      })
    >;
typedef $$LegsTableCreateCompanionBuilder = LegsCompanion Function({
  Value<int> id,
  required int matchId,
  required int legNumber,
  required int starterId,
  Value<int?> winnerId,
});
typedef $$LegsTableUpdateCompanionBuilder = LegsCompanion Function({
  Value<int> id,
  Value<int> matchId,
  Value<int> legNumber,
  Value<int> starterId,
  Value<int?> winnerId,
});

final class $$LegsTableReferences
    extends BaseReferences<_$AppDatabase, $LegsTable, Leg> {
  $$LegsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MatchesTable _matchIdTable(_$AppDatabase db) =>
      db.matches.createAlias('legs__match_id__matches__id');

  $$MatchesTableProcessedTableManager get matchId {
    final $_column = $_itemColumn<int>('match_id')!;

    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _starterIdTable(_$AppDatabase db) =>
      db.players.createAlias('legs__starter_id__players__id');

  $$PlayersTableProcessedTableManager get starterId {
    final $_column = $_itemColumn<int>('starter_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_starterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _winnerIdTable(_$AppDatabase db) =>
      db.players.createAlias('legs__winner_id__players__id');

  $$PlayersTableProcessedTableManager? get winnerId {
    final $_column = $_itemColumn<int>('winner_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_winnerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TurnsTable, List<Turn>> _turnsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.turns,
    aliasName: 'legs__id__turns__leg_id',
  );

  $$TurnsTableProcessedTableManager get turnsRefs {
    final manager = $$TurnsTableTableManager(
      $_db,
      $_db.turns,
    ).filter((f) => f.legId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_turnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LegsTableFilterComposer extends Composer<_$AppDatabase, $LegsTable> {
  $$LegsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legNumber => $composableBuilder(
    column: $table.legNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$MatchesTableFilterComposer get matchId {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get starterId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.starterId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get winnerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> turnsRefs(
    Expression<bool> Function($$TurnsTableFilterComposer f) f,
  ) {
    final $$TurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.legId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableFilterComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LegsTableOrderingComposer extends Composer<_$AppDatabase, $LegsTable> {
  $$LegsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legNumber => $composableBuilder(
    column: $table.legNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$MatchesTableOrderingComposer get matchId {
    final $$MatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableOrderingComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get starterId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.starterId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get winnerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LegsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LegsTable> {
  $$LegsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get legNumber =>
      $composableBuilder(column: $table.legNumber, builder: (column) => column);

  $$MatchesTableAnnotationComposer get matchId {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get starterId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.starterId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get winnerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> turnsRefs<T extends Object>(
    Expression<T> Function($$TurnsTableAnnotationComposer a) f,
  ) {
    final $$TurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.legId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LegsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LegsTable,
          Leg,
          $$LegsTableFilterComposer,
          $$LegsTableOrderingComposer,
          $$LegsTableAnnotationComposer,
          $$LegsTableCreateCompanionBuilder,
          $$LegsTableUpdateCompanionBuilder,
          (Leg, $$LegsTableReferences),
          Leg,
          PrefetchHooks Function({
            bool matchId,
            bool starterId,
            bool winnerId,
            bool turnsRefs,
          })
        > {
  $$LegsTableTableManager(_$AppDatabase db, $LegsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LegsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LegsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LegsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> matchId = const Value.absent(),
                Value<int> legNumber = const Value.absent(),
                Value<int> starterId = const Value.absent(),
                Value<int?> winnerId = const Value.absent(),
              }) => LegsCompanion(
                id: id,
                matchId: matchId,
                legNumber: legNumber,
                starterId: starterId,
                winnerId: winnerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int matchId,
                required int legNumber,
                required int starterId,
                Value<int?> winnerId = const Value.absent(),
              }) => LegsCompanion.insert(
                id: id,
                matchId: matchId,
                legNumber: legNumber,
                starterId: starterId,
                winnerId: winnerId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LegsTable, Leg>(table),
                  $$LegsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                matchId = false,
                starterId = false,
                winnerId = false,
                turnsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (turnsRefs) db.turns],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (matchId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.matchId,
                            referencedTable: $$LegsTableReferences
                                ._matchIdTable(db),
                            referencedColumn: $$LegsTableReferences
                                ._matchIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (starterId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.starterId,
                            referencedTable: $$LegsTableReferences
                                ._starterIdTable(db),
                            referencedColumn: $$LegsTableReferences
                                ._starterIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (winnerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.winnerId,
                            referencedTable: $$LegsTableReferences
                                ._winnerIdTable(db),
                            referencedColumn: $$LegsTableReferences
                                ._winnerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (turnsRefs)
                        await $_getPrefetchedData<Leg, $LegsTable, Turn>(
                          currentTable: table,
                          referencedTable: $$LegsTableReferences
                              ._turnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LegsTableReferences(db, table, p0).turnsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.legId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LegsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LegsTable,
      Leg,
      $$LegsTableFilterComposer,
      $$LegsTableOrderingComposer,
      $$LegsTableAnnotationComposer,
      $$LegsTableCreateCompanionBuilder,
      $$LegsTableUpdateCompanionBuilder,
      (Leg, $$LegsTableReferences),
      Leg,
      PrefetchHooks Function({
        bool matchId,
        bool starterId,
        bool winnerId,
        bool turnsRefs,
      })
    >;
typedef $$TurnsTableCreateCompanionBuilder = TurnsCompanion Function({
  Value<int> id,
  required int legId,
  required int playerId,
  required int turnNumber,
  required int score,
  Value<int> dartsUsed,
  Value<bool> isBust,
  Value<bool> isCheckout,
});
typedef $$TurnsTableUpdateCompanionBuilder = TurnsCompanion Function({
  Value<int> id,
  Value<int> legId,
  Value<int> playerId,
  Value<int> turnNumber,
  Value<int> score,
  Value<int> dartsUsed,
  Value<bool> isBust,
  Value<bool> isCheckout,
});

final class $$TurnsTableReferences
    extends BaseReferences<_$AppDatabase, $TurnsTable, Turn> {
  $$TurnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LegsTable _legIdTable(_$AppDatabase db) =>
      db.legs.createAlias('turns__leg_id__legs__id');

  $$LegsTableProcessedTableManager get legId {
    final $_column = $_itemColumn<int>('leg_id')!;

    final manager = $$LegsTableTableManager(
      $_db,
      $_db.legs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_legIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('turns__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TurnsTableFilterComposer extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnNumber => $composableBuilder(
    column: $table.turnNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dartsUsed => $composableBuilder(
    column: $table.dartsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBust => $composableBuilder(
    column: $table.isBust,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCheckout => $composableBuilder(
    column: $table.isCheckout,
    builder: (column) => ColumnFilters(column),
  );

  $$LegsTableFilterComposer get legId {
    final $$LegsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.legId,
      referencedTable: $db.legs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegsTableFilterComposer(
            $db: $db,
            $table: $db.legs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnNumber => $composableBuilder(
    column: $table.turnNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dartsUsed => $composableBuilder(
    column: $table.dartsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBust => $composableBuilder(
    column: $table.isBust,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCheckout => $composableBuilder(
    column: $table.isCheckout,
    builder: (column) => ColumnOrderings(column),
  );

  $$LegsTableOrderingComposer get legId {
    final $$LegsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.legId,
      referencedTable: $db.legs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegsTableOrderingComposer(
            $db: $db,
            $table: $db.legs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get turnNumber => $composableBuilder(
    column: $table.turnNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get dartsUsed =>
      $composableBuilder(column: $table.dartsUsed, builder: (column) => column);

  GeneratedColumn<bool> get isBust =>
      $composableBuilder(column: $table.isBust, builder: (column) => column);

  GeneratedColumn<bool> get isCheckout => $composableBuilder(
    column: $table.isCheckout,
    builder: (column) => column,
  );

  $$LegsTableAnnotationComposer get legId {
    final $$LegsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.legId,
      referencedTable: $db.legs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LegsTableAnnotationComposer(
            $db: $db,
            $table: $db.legs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TurnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TurnsTable,
          Turn,
          $$TurnsTableFilterComposer,
          $$TurnsTableOrderingComposer,
          $$TurnsTableAnnotationComposer,
          $$TurnsTableCreateCompanionBuilder,
          $$TurnsTableUpdateCompanionBuilder,
          (Turn, $$TurnsTableReferences),
          Turn,
          PrefetchHooks Function({bool legId, bool playerId})
        > {
  $$TurnsTableTableManager(_$AppDatabase db, $TurnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> legId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int> turnNumber = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> dartsUsed = const Value.absent(),
                Value<bool> isBust = const Value.absent(),
                Value<bool> isCheckout = const Value.absent(),
              }) => TurnsCompanion(
                id: id,
                legId: legId,
                playerId: playerId,
                turnNumber: turnNumber,
                score: score,
                dartsUsed: dartsUsed,
                isBust: isBust,
                isCheckout: isCheckout,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int legId,
                required int playerId,
                required int turnNumber,
                required int score,
                Value<int> dartsUsed = const Value.absent(),
                Value<bool> isBust = const Value.absent(),
                Value<bool> isCheckout = const Value.absent(),
              }) => TurnsCompanion.insert(
                id: id,
                legId: legId,
                playerId: playerId,
                turnNumber: turnNumber,
                score: score,
                dartsUsed: dartsUsed,
                isBust: isBust,
                isCheckout: isCheckout,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TurnsTable, Turn>(table),
                  $$TurnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({legId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (legId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.legId,
                        referencedTable: $$TurnsTableReferences._legIdTable(db),
                        referencedColumn: $$TurnsTableReferences
                            ._legIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (playerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playerId,
                        referencedTable: $$TurnsTableReferences._playerIdTable(
                          db,
                        ),
                        referencedColumn: $$TurnsTableReferences
                            ._playerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TurnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TurnsTable,
      Turn,
      $$TurnsTableFilterComposer,
      $$TurnsTableOrderingComposer,
      $$TurnsTableAnnotationComposer,
      $$TurnsTableCreateCompanionBuilder,
      $$TurnsTableUpdateCompanionBuilder,
      (Turn, $$TurnsTableReferences),
      Turn,
      PrefetchHooks Function({bool legId, bool playerId})
    >;
typedef $$OpenEntriesTableCreateCompanionBuilder =
    OpenEntriesCompanion Function({
      Value<int> id,
      required int openId,
      required int playerId,
      Value<int?> seed,
      Value<int?> finalPlacement,
    });
typedef $$OpenEntriesTableUpdateCompanionBuilder =
    OpenEntriesCompanion Function({
      Value<int> id,
      Value<int> openId,
      Value<int> playerId,
      Value<int?> seed,
      Value<int?> finalPlacement,
    });

final class $$OpenEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $OpenEntriesTable, OpenEntryRow> {
  $$OpenEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OpensTable _openIdTable(_$AppDatabase db) =>
      db.opens.createAlias('open_entries__open_id__opens__id');

  $$OpensTableProcessedTableManager get openId {
    final $_column = $_itemColumn<int>('open_id')!;

    final manager = $$OpensTableTableManager(
      $_db,
      $_db.opens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_openIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('open_entries__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OpenEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OpenEntriesTable> {
  $$OpenEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalPlacement => $composableBuilder(
    column: $table.finalPlacement,
    builder: (column) => ColumnFilters(column),
  );

  $$OpensTableFilterComposer get openId {
    final $$OpensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableFilterComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OpenEntriesTable> {
  $$OpenEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalPlacement => $composableBuilder(
    column: $table.finalPlacement,
    builder: (column) => ColumnOrderings(column),
  );

  $$OpensTableOrderingComposer get openId {
    final $$OpensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableOrderingComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpenEntriesTable> {
  $$OpenEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<int> get finalPlacement => $composableBuilder(
    column: $table.finalPlacement,
    builder: (column) => column,
  );

  $$OpensTableAnnotationComposer get openId {
    final $$OpensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableAnnotationComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpenEntriesTable,
          OpenEntryRow,
          $$OpenEntriesTableFilterComposer,
          $$OpenEntriesTableOrderingComposer,
          $$OpenEntriesTableAnnotationComposer,
          $$OpenEntriesTableCreateCompanionBuilder,
          $$OpenEntriesTableUpdateCompanionBuilder,
          (OpenEntryRow, $$OpenEntriesTableReferences),
          OpenEntryRow,
          PrefetchHooks Function({bool openId, bool playerId})
        > {
  $$OpenEntriesTableTableManager(_$AppDatabase db, $OpenEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpenEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpenEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpenEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> openId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int?> seed = const Value.absent(),
                Value<int?> finalPlacement = const Value.absent(),
              }) => OpenEntriesCompanion(
                id: id,
                openId: openId,
                playerId: playerId,
                seed: seed,
                finalPlacement: finalPlacement,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int openId,
                required int playerId,
                Value<int?> seed = const Value.absent(),
                Value<int?> finalPlacement = const Value.absent(),
              }) => OpenEntriesCompanion.insert(
                id: id,
                openId: openId,
                playerId: playerId,
                seed: seed,
                finalPlacement: finalPlacement,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpenEntriesTable, OpenEntryRow>(table),
                  $$OpenEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({openId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (openId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.openId,
                        referencedTable: $$OpenEntriesTableReferences
                            ._openIdTable(db),
                        referencedColumn: $$OpenEntriesTableReferences
                            ._openIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (playerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playerId,
                        referencedTable: $$OpenEntriesTableReferences
                            ._playerIdTable(db),
                        referencedColumn: $$OpenEntriesTableReferences
                            ._playerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OpenEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpenEntriesTable,
      OpenEntryRow,
      $$OpenEntriesTableFilterComposer,
      $$OpenEntriesTableOrderingComposer,
      $$OpenEntriesTableAnnotationComposer,
      $$OpenEntriesTableCreateCompanionBuilder,
      $$OpenEntriesTableUpdateCompanionBuilder,
      (OpenEntryRow, $$OpenEntriesTableReferences),
      OpenEntryRow,
      PrefetchHooks Function({bool openId, bool playerId})
    >;
typedef $$BracketNodesTableCreateCompanionBuilder =
    BracketNodesCompanion Function({
      Value<int> id,
      required int openId,
      required String nodeKey,
      required String bracket,
      required int round,
      required int position,
      Value<int?> playerAId,
      Value<int?> playerBId,
      Value<String?> winnerToKey,
      Value<String?> winnerToSlot,
      Value<String?> loserToKey,
      Value<String?> loserToSlot,
      Value<String> status,
      Value<int?> winnerId,
      Value<int?> markerId,
      Value<int?> matchId,
    });
typedef $$BracketNodesTableUpdateCompanionBuilder =
    BracketNodesCompanion Function({
      Value<int> id,
      Value<int> openId,
      Value<String> nodeKey,
      Value<String> bracket,
      Value<int> round,
      Value<int> position,
      Value<int?> playerAId,
      Value<int?> playerBId,
      Value<String?> winnerToKey,
      Value<String?> winnerToSlot,
      Value<String?> loserToKey,
      Value<String?> loserToSlot,
      Value<String> status,
      Value<int?> winnerId,
      Value<int?> markerId,
      Value<int?> matchId,
    });

final class $$BracketNodesTableReferences
    extends BaseReferences<_$AppDatabase, $BracketNodesTable, BracketNodeRow> {
  $$BracketNodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OpensTable _openIdTable(_$AppDatabase db) =>
      db.opens.createAlias('bracket_nodes__open_id__opens__id');

  $$OpensTableProcessedTableManager get openId {
    final $_column = $_itemColumn<int>('open_id')!;

    final manager = $$OpensTableTableManager(
      $_db,
      $_db.opens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_openIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerAIdTable(_$AppDatabase db) =>
      db.players.createAlias('bracket_nodes__player_a_id__players__id');

  $$PlayersTableProcessedTableManager? get playerAId {
    final $_column = $_itemColumn<int>('player_a_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerAIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerBIdTable(_$AppDatabase db) =>
      db.players.createAlias('bracket_nodes__player_b_id__players__id');

  $$PlayersTableProcessedTableManager? get playerBId {
    final $_column = $_itemColumn<int>('player_b_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerBIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _winnerIdTable(_$AppDatabase db) =>
      db.players.createAlias('bracket_nodes__winner_id__players__id');

  $$PlayersTableProcessedTableManager? get winnerId {
    final $_column = $_itemColumn<int>('winner_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_winnerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _markerIdTable(_$AppDatabase db) =>
      db.players.createAlias('bracket_nodes__marker_id__players__id');

  $$PlayersTableProcessedTableManager? get markerId {
    final $_column = $_itemColumn<int>('marker_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_markerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MatchesTable _matchIdTable(_$AppDatabase db) =>
      db.matches.createAlias('bracket_nodes__match_id__matches__id');

  $$MatchesTableProcessedTableManager? get matchId {
    final $_column = $_itemColumn<int>('match_id');
    if ($_column == null) return null;
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BracketNodesTableFilterComposer
    extends Composer<_$AppDatabase, $BracketNodesTable> {
  $$BracketNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeKey => $composableBuilder(
    column: $table.nodeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bracket => $composableBuilder(
    column: $table.bracket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winnerToKey => $composableBuilder(
    column: $table.winnerToKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winnerToSlot => $composableBuilder(
    column: $table.winnerToSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loserToKey => $composableBuilder(
    column: $table.loserToKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loserToSlot => $composableBuilder(
    column: $table.loserToSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$OpensTableFilterComposer get openId {
    final $$OpensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableFilterComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerAId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerAId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerBId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerBId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get winnerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get markerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchesTableFilterComposer get matchId {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BracketNodesTableOrderingComposer
    extends Composer<_$AppDatabase, $BracketNodesTable> {
  $$BracketNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeKey => $composableBuilder(
    column: $table.nodeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bracket => $composableBuilder(
    column: $table.bracket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winnerToKey => $composableBuilder(
    column: $table.winnerToKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winnerToSlot => $composableBuilder(
    column: $table.winnerToSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loserToKey => $composableBuilder(
    column: $table.loserToKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loserToSlot => $composableBuilder(
    column: $table.loserToSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$OpensTableOrderingComposer get openId {
    final $$OpensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableOrderingComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerAId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerAId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerBId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerBId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get winnerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get markerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchesTableOrderingComposer get matchId {
    final $$MatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableOrderingComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BracketNodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BracketNodesTable> {
  $$BracketNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nodeKey =>
      $composableBuilder(column: $table.nodeKey, builder: (column) => column);

  GeneratedColumn<String> get bracket =>
      $composableBuilder(column: $table.bracket, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get winnerToKey => $composableBuilder(
    column: $table.winnerToKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winnerToSlot => $composableBuilder(
    column: $table.winnerToSlot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loserToKey => $composableBuilder(
    column: $table.loserToKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loserToSlot => $composableBuilder(
    column: $table.loserToSlot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$OpensTableAnnotationComposer get openId {
    final $$OpensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openId,
      referencedTable: $db.opens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpensTableAnnotationComposer(
            $db: $db,
            $table: $db.opens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerAId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerAId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerBId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerBId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get winnerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get markerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.markerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchesTableAnnotationComposer get matchId {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BracketNodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BracketNodesTable,
          BracketNodeRow,
          $$BracketNodesTableFilterComposer,
          $$BracketNodesTableOrderingComposer,
          $$BracketNodesTableAnnotationComposer,
          $$BracketNodesTableCreateCompanionBuilder,
          $$BracketNodesTableUpdateCompanionBuilder,
          (BracketNodeRow, $$BracketNodesTableReferences),
          BracketNodeRow,
          PrefetchHooks Function({
            bool openId,
            bool playerAId,
            bool playerBId,
            bool winnerId,
            bool markerId,
            bool matchId,
          })
        > {
  $$BracketNodesTableTableManager(_$AppDatabase db, $BracketNodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BracketNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BracketNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BracketNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> openId = const Value.absent(),
                Value<String> nodeKey = const Value.absent(),
                Value<String> bracket = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> playerAId = const Value.absent(),
                Value<int?> playerBId = const Value.absent(),
                Value<String?> winnerToKey = const Value.absent(),
                Value<String?> winnerToSlot = const Value.absent(),
                Value<String?> loserToKey = const Value.absent(),
                Value<String?> loserToSlot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> winnerId = const Value.absent(),
                Value<int?> markerId = const Value.absent(),
                Value<int?> matchId = const Value.absent(),
              }) => BracketNodesCompanion(
                id: id,
                openId: openId,
                nodeKey: nodeKey,
                bracket: bracket,
                round: round,
                position: position,
                playerAId: playerAId,
                playerBId: playerBId,
                winnerToKey: winnerToKey,
                winnerToSlot: winnerToSlot,
                loserToKey: loserToKey,
                loserToSlot: loserToSlot,
                status: status,
                winnerId: winnerId,
                markerId: markerId,
                matchId: matchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int openId,
                required String nodeKey,
                required String bracket,
                required int round,
                required int position,
                Value<int?> playerAId = const Value.absent(),
                Value<int?> playerBId = const Value.absent(),
                Value<String?> winnerToKey = const Value.absent(),
                Value<String?> winnerToSlot = const Value.absent(),
                Value<String?> loserToKey = const Value.absent(),
                Value<String?> loserToSlot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> winnerId = const Value.absent(),
                Value<int?> markerId = const Value.absent(),
                Value<int?> matchId = const Value.absent(),
              }) => BracketNodesCompanion.insert(
                id: id,
                openId: openId,
                nodeKey: nodeKey,
                bracket: bracket,
                round: round,
                position: position,
                playerAId: playerAId,
                playerBId: playerBId,
                winnerToKey: winnerToKey,
                winnerToSlot: winnerToSlot,
                loserToKey: loserToKey,
                loserToSlot: loserToSlot,
                status: status,
                winnerId: winnerId,
                markerId: markerId,
                matchId: matchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BracketNodesTable, BracketNodeRow>(table),
                  $$BracketNodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                openId = false,
                playerAId = false,
                playerBId = false,
                winnerId = false,
                markerId = false,
                matchId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (openId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.openId,
                            referencedTable: $$BracketNodesTableReferences
                                ._openIdTable(db),
                            referencedColumn: $$BracketNodesTableReferences
                                ._openIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (playerAId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.playerAId,
                            referencedTable: $$BracketNodesTableReferences
                                ._playerAIdTable(db),
                            referencedColumn: $$BracketNodesTableReferences
                                ._playerAIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (playerBId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.playerBId,
                            referencedTable: $$BracketNodesTableReferences
                                ._playerBIdTable(db),
                            referencedColumn: $$BracketNodesTableReferences
                                ._playerBIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (winnerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.winnerId,
                            referencedTable: $$BracketNodesTableReferences
                                ._winnerIdTable(db),
                            referencedColumn: $$BracketNodesTableReferences
                                ._winnerIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (markerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.markerId,
                            referencedTable: $$BracketNodesTableReferences
                                ._markerIdTable(db),
                            referencedColumn: $$BracketNodesTableReferences
                                ._markerIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (matchId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.matchId,
                            referencedTable: $$BracketNodesTableReferences
                                ._matchIdTable(db),
                            referencedColumn: $$BracketNodesTableReferences
                                ._matchIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$BracketNodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BracketNodesTable,
      BracketNodeRow,
      $$BracketNodesTableFilterComposer,
      $$BracketNodesTableOrderingComposer,
      $$BracketNodesTableAnnotationComposer,
      $$BracketNodesTableCreateCompanionBuilder,
      $$BracketNodesTableUpdateCompanionBuilder,
      (BracketNodeRow, $$BracketNodesTableReferences),
      BracketNodeRow,
      PrefetchHooks Function({
        bool openId,
        bool playerAId,
        bool playerBId,
        bool winnerId,
        bool markerId,
        bool matchId,
      })
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$OpensTableTableManager get opens =>
      $$OpensTableTableManager(_db, _db.opens);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$LegsTableTableManager get legs => $$LegsTableTableManager(_db, _db.legs);
  $$TurnsTableTableManager get turns =>
      $$TurnsTableTableManager(_db, _db.turns);
  $$OpenEntriesTableTableManager get openEntries =>
      $$OpenEntriesTableTableManager(_db, _db.openEntries);
  $$BracketNodesTableTableManager get bracketNodes =>
      $$BracketNodesTableTableManager(_db, _db.bracketNodes);
}
