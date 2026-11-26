// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WalletsTable extends Wallets with TableInfo<$WalletsTable, WalletDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMinorMeta =
      const VerificationMeta('openingBalanceMinor');
  @override
  late final GeneratedColumn<int> openingBalanceMinor = GeneratedColumn<int>(
    'opening_balance_minor',
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
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> createdOn =
      GeneratedColumn<String>(
        'created_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($WalletsTable.$convertercreatedOn);
  static const VerificationMeta _hasTransactionsMeta = const VerificationMeta(
    'hasTransactions',
  );
  @override
  late final GeneratedColumn<bool> hasTransactions = GeneratedColumn<bool>(
    'has_transactions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_transactions" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    currency,
    openingBalanceMinor,
    status,
    createdOn,
    hasTransactions,
    deleted,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('opening_balance_minor')) {
      context.handle(
        _openingBalanceMinorMeta,
        openingBalanceMinor.isAcceptableOrUnknown(
          data['opening_balance_minor']!,
          _openingBalanceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceMinorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('has_transactions')) {
      context.handle(
        _hasTransactionsMeta,
        hasTransactions.isAcceptableOrUnknown(
          data['has_transactions']!,
          _hasTransactionsMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      openingBalanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_minor'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdOn: $WalletsTable.$convertercreatedOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_on'],
        )!,
      ),
      hasTransactions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_transactions'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $convertercreatedOn =
      const LocalDateConverter('wallets', 'created_on');
}

class WalletDto extends DataClass implements Insertable<WalletDto> {
  final String id;
  final String name;
  final String kind;
  final String currency;
  final int openingBalanceMinor;
  final String status;
  final LocalDate createdOn;
  final bool hasTransactions;
  final bool deleted;
  final int? serverUpdatedAt;
  const WalletDto({
    required this.id,
    required this.name,
    required this.kind,
    required this.currency,
    required this.openingBalanceMinor,
    required this.status,
    required this.createdOn,
    required this.hasTransactions,
    required this.deleted,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['currency'] = Variable<String>(currency);
    map['opening_balance_minor'] = Variable<int>(openingBalanceMinor);
    map['status'] = Variable<String>(status);
    {
      map['created_on'] = Variable<String>(
        $WalletsTable.$convertercreatedOn.toSql(createdOn),
      );
    }
    map['has_transactions'] = Variable<bool>(hasTransactions);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      currency: Value(currency),
      openingBalanceMinor: Value(openingBalanceMinor),
      status: Value(status),
      createdOn: Value(createdOn),
      hasTransactions: Value(hasTransactions),
      deleted: Value(deleted),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory WalletDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletDto(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      currency: serializer.fromJson<String>(json['currency']),
      openingBalanceMinor: serializer.fromJson<int>(
        json['openingBalanceMinor'],
      ),
      status: serializer.fromJson<String>(json['status']),
      createdOn: serializer.fromJson<LocalDate>(json['createdOn']),
      hasTransactions: serializer.fromJson<bool>(json['hasTransactions']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'currency': serializer.toJson<String>(currency),
      'openingBalanceMinor': serializer.toJson<int>(openingBalanceMinor),
      'status': serializer.toJson<String>(status),
      'createdOn': serializer.toJson<LocalDate>(createdOn),
      'hasTransactions': serializer.toJson<bool>(hasTransactions),
      'deleted': serializer.toJson<bool>(deleted),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  WalletDto copyWith({
    String? id,
    String? name,
    String? kind,
    String? currency,
    int? openingBalanceMinor,
    String? status,
    LocalDate? createdOn,
    bool? hasTransactions,
    bool? deleted,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => WalletDto(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    currency: currency ?? this.currency,
    openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
    status: status ?? this.status,
    createdOn: createdOn ?? this.createdOn,
    hasTransactions: hasTransactions ?? this.hasTransactions,
    deleted: deleted ?? this.deleted,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  WalletDto copyWithCompanion(WalletsCompanion data) {
    return WalletDto(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      currency: data.currency.present ? data.currency.value : this.currency,
      openingBalanceMinor: data.openingBalanceMinor.present
          ? data.openingBalanceMinor.value
          : this.openingBalanceMinor,
      status: data.status.present ? data.status.value : this.status,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
      hasTransactions: data.hasTransactions.present
          ? data.hasTransactions.value
          : this.hasTransactions,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletDto(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('status: $status, ')
          ..write('createdOn: $createdOn, ')
          ..write('hasTransactions: $hasTransactions, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    currency,
    openingBalanceMinor,
    status,
    createdOn,
    hasTransactions,
    deleted,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletDto &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.currency == this.currency &&
          other.openingBalanceMinor == this.openingBalanceMinor &&
          other.status == this.status &&
          other.createdOn == this.createdOn &&
          other.hasTransactions == this.hasTransactions &&
          other.deleted == this.deleted &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class WalletsCompanion extends UpdateCompanion<WalletDto> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> currency;
  final Value<int> openingBalanceMinor;
  final Value<String> status;
  final Value<LocalDate> createdOn;
  final Value<bool> hasTransactions;
  final Value<bool> deleted;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const WalletsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.currency = const Value.absent(),
    this.openingBalanceMinor = const Value.absent(),
    this.status = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.hasTransactions = const Value.absent(),
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required String currency,
    required int openingBalanceMinor,
    required String status,
    required LocalDate createdOn,
    this.hasTransactions = const Value.absent(),
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       currency = Value(currency),
       openingBalanceMinor = Value(openingBalanceMinor),
       status = Value(status),
       createdOn = Value(createdOn);
  static Insertable<WalletDto> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? currency,
    Expression<int>? openingBalanceMinor,
    Expression<String>? status,
    Expression<String>? createdOn,
    Expression<bool>? hasTransactions,
    Expression<bool>? deleted,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (currency != null) 'currency': currency,
      if (openingBalanceMinor != null)
        'opening_balance_minor': openingBalanceMinor,
      if (status != null) 'status': status,
      if (createdOn != null) 'created_on': createdOn,
      if (hasTransactions != null) 'has_transactions': hasTransactions,
      if (deleted != null) 'deleted': deleted,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? currency,
    Value<int>? openingBalanceMinor,
    Value<String>? status,
    Value<LocalDate>? createdOn,
    Value<bool>? hasTransactions,
    Value<bool>? deleted,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return WalletsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      hasTransactions: hasTransactions ?? this.hasTransactions,
      deleted: deleted ?? this.deleted,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (openingBalanceMinor.present) {
      map['opening_balance_minor'] = Variable<int>(openingBalanceMinor.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<String>(
        $WalletsTable.$convertercreatedOn.toSql(createdOn.value),
      );
    }
    if (hasTransactions.present) {
      map['has_transactions'] = Variable<bool>(hasTransactions.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('status: $status, ')
          ..write('createdOn: $createdOn, ')
          ..write('hasTransactions: $hasTransactions, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
  );
  static const VerificationMeta _systemKeyMeta = const VerificationMeta(
    'systemKey',
  );
  @override
  late final GeneratedColumn<String> systemKey = GeneratedColumn<String>(
    'system_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    isDefault,
    systemKey,
    deleted,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    } else if (isInserting) {
      context.missing(_isDefaultMeta);
    }
    if (data.containsKey('system_key')) {
      context.handle(
        _systemKeyMeta,
        systemKey.isAcceptableOrUnknown(data['system_key']!, _systemKeyMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      systemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_key'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryDto extends DataClass implements Insertable<CategoryDto> {
  final String id;
  final String name;
  final String type;
  final bool isDefault;
  final String? systemKey;
  final bool deleted;
  final int? serverUpdatedAt;
  const CategoryDto({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    this.systemKey,
    required this.deleted,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || systemKey != null) {
      map['system_key'] = Variable<String>(systemKey);
    }
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      isDefault: Value(isDefault),
      systemKey: systemKey == null && nullToAbsent
          ? const Value.absent()
          : Value(systemKey),
      deleted: Value(deleted),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory CategoryDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryDto(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      systemKey: serializer.fromJson<String?>(json['systemKey']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'isDefault': serializer.toJson<bool>(isDefault),
      'systemKey': serializer.toJson<String?>(systemKey),
      'deleted': serializer.toJson<bool>(deleted),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  CategoryDto copyWith({
    String? id,
    String? name,
    String? type,
    bool? isDefault,
    Value<String?> systemKey = const Value.absent(),
    bool? deleted,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => CategoryDto(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
    systemKey: systemKey.present ? systemKey.value : this.systemKey,
    deleted: deleted ?? this.deleted,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  CategoryDto copyWithCompanion(CategoriesCompanion data) {
    return CategoryDto(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      systemKey: data.systemKey.present ? data.systemKey.value : this.systemKey,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryDto(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('systemKey: $systemKey, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    isDefault,
    systemKey,
    deleted,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryDto &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.isDefault == this.isDefault &&
          other.systemKey == this.systemKey &&
          other.deleted == this.deleted &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryDto> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<bool> isDefault;
  final Value<String?> systemKey;
  final Value<bool> deleted;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.systemKey = const Value.absent(),
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required bool isDefault,
    this.systemKey = const Value.absent(),
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       isDefault = Value(isDefault);
  static Insertable<CategoryDto> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? isDefault,
    Expression<String>? systemKey,
    Expression<bool>? deleted,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
      if (systemKey != null) 'system_key': systemKey,
      if (deleted != null) 'deleted': deleted,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<bool>? isDefault,
    Value<String?>? systemKey,
    Value<bool>? deleted,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      systemKey: systemKey ?? this.systemKey,
      deleted: deleted ?? this.deleted,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (systemKey.present) {
      map['system_key'] = Variable<String>(systemKey.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('systemKey: $systemKey, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($TransactionsTable.$converterdate);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferIdMeta = const VerificationMeta(
    'transferId',
  );
  @override
  late final GeneratedColumn<String> transferId = GeneratedColumn<String>(
    'transfer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fromWalletIdMeta = const VerificationMeta(
    'fromWalletId',
  );
  @override
  late final GeneratedColumn<String> fromWalletId = GeneratedColumn<String>(
    'from_wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toWalletIdMeta = const VerificationMeta(
    'toWalletId',
  );
  @override
  late final GeneratedColumn<String> toWalletId = GeneratedColumn<String>(
    'to_wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountSentMinorMeta = const VerificationMeta(
    'amountSentMinor',
  );
  @override
  late final GeneratedColumn<int> amountSentMinor = GeneratedColumn<int>(
    'amount_sent_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sentCurrencyMeta = const VerificationMeta(
    'sentCurrency',
  );
  @override
  late final GeneratedColumn<String> sentCurrency = GeneratedColumn<String>(
    'sent_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountReceivedMinorMeta =
      const VerificationMeta('amountReceivedMinor');
  @override
  late final GeneratedColumn<int> amountReceivedMinor = GeneratedColumn<int>(
    'amount_received_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedCurrencyMeta = const VerificationMeta(
    'receivedCurrency',
  );
  @override
  late final GeneratedColumn<String> receivedCurrency = GeneratedColumn<String>(
    'received_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    date,
    note,
    walletId,
    categoryId,
    amountMinor,
    currency,
    transferId,
    fromWalletId,
    toWalletId,
    amountSentMinor,
    sentCurrency,
    amountReceivedMinor,
    receivedCurrency,
    deleted,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('transfer_id')) {
      context.handle(
        _transferIdMeta,
        transferId.isAcceptableOrUnknown(data['transfer_id']!, _transferIdMeta),
      );
    }
    if (data.containsKey('from_wallet_id')) {
      context.handle(
        _fromWalletIdMeta,
        fromWalletId.isAcceptableOrUnknown(
          data['from_wallet_id']!,
          _fromWalletIdMeta,
        ),
      );
    }
    if (data.containsKey('to_wallet_id')) {
      context.handle(
        _toWalletIdMeta,
        toWalletId.isAcceptableOrUnknown(
          data['to_wallet_id']!,
          _toWalletIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_sent_minor')) {
      context.handle(
        _amountSentMinorMeta,
        amountSentMinor.isAcceptableOrUnknown(
          data['amount_sent_minor']!,
          _amountSentMinorMeta,
        ),
      );
    }
    if (data.containsKey('sent_currency')) {
      context.handle(
        _sentCurrencyMeta,
        sentCurrency.isAcceptableOrUnknown(
          data['sent_currency']!,
          _sentCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('amount_received_minor')) {
      context.handle(
        _amountReceivedMinorMeta,
        amountReceivedMinor.isAcceptableOrUnknown(
          data['amount_received_minor']!,
          _amountReceivedMinorMeta,
        ),
      );
    }
    if (data.containsKey('received_currency')) {
      context.handle(
        _receivedCurrencyMeta,
        receivedCurrency.isAcceptableOrUnknown(
          data['received_currency']!,
          _receivedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      date: $TransactionsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      transferId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_id'],
      ),
      fromWalletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_wallet_id'],
      ),
      toWalletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_wallet_id'],
      ),
      amountSentMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_sent_minor'],
      ),
      sentCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_currency'],
      ),
      amountReceivedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_received_minor'],
      ),
      receivedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_currency'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdate =
      const LocalDateConverter('transactions', 'date');
}

class TransactionDto extends DataClass implements Insertable<TransactionDto> {
  final String id;
  final String kind;
  final LocalDate date;
  final String? note;
  final String? walletId;
  final String? categoryId;
  final int? amountMinor;
  final String? currency;
  final String? transferId;
  final String? fromWalletId;
  final String? toWalletId;
  final int? amountSentMinor;
  final String? sentCurrency;
  final int? amountReceivedMinor;
  final String? receivedCurrency;
  final bool deleted;
  final int? serverUpdatedAt;
  const TransactionDto({
    required this.id,
    required this.kind,
    required this.date,
    this.note,
    this.walletId,
    this.categoryId,
    this.amountMinor,
    this.currency,
    this.transferId,
    this.fromWalletId,
    this.toWalletId,
    this.amountSentMinor,
    this.sentCurrency,
    this.amountReceivedMinor,
    this.receivedCurrency,
    required this.deleted,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    {
      map['date'] = Variable<String>(
        $TransactionsTable.$converterdate.toSql(date),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<String>(walletId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || transferId != null) {
      map['transfer_id'] = Variable<String>(transferId);
    }
    if (!nullToAbsent || fromWalletId != null) {
      map['from_wallet_id'] = Variable<String>(fromWalletId);
    }
    if (!nullToAbsent || toWalletId != null) {
      map['to_wallet_id'] = Variable<String>(toWalletId);
    }
    if (!nullToAbsent || amountSentMinor != null) {
      map['amount_sent_minor'] = Variable<int>(amountSentMinor);
    }
    if (!nullToAbsent || sentCurrency != null) {
      map['sent_currency'] = Variable<String>(sentCurrency);
    }
    if (!nullToAbsent || amountReceivedMinor != null) {
      map['amount_received_minor'] = Variable<int>(amountReceivedMinor);
    }
    if (!nullToAbsent || receivedCurrency != null) {
      map['received_currency'] = Variable<String>(receivedCurrency);
    }
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      kind: Value(kind),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      transferId: transferId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferId),
      fromWalletId: fromWalletId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromWalletId),
      toWalletId: toWalletId == null && nullToAbsent
          ? const Value.absent()
          : Value(toWalletId),
      amountSentMinor: amountSentMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountSentMinor),
      sentCurrency: sentCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(sentCurrency),
      amountReceivedMinor: amountReceivedMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountReceivedMinor),
      receivedCurrency: receivedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedCurrency),
      deleted: Value(deleted),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory TransactionDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionDto(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      date: serializer.fromJson<LocalDate>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      walletId: serializer.fromJson<String?>(json['walletId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currency: serializer.fromJson<String?>(json['currency']),
      transferId: serializer.fromJson<String?>(json['transferId']),
      fromWalletId: serializer.fromJson<String?>(json['fromWalletId']),
      toWalletId: serializer.fromJson<String?>(json['toWalletId']),
      amountSentMinor: serializer.fromJson<int?>(json['amountSentMinor']),
      sentCurrency: serializer.fromJson<String?>(json['sentCurrency']),
      amountReceivedMinor: serializer.fromJson<int?>(
        json['amountReceivedMinor'],
      ),
      receivedCurrency: serializer.fromJson<String?>(json['receivedCurrency']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'date': serializer.toJson<LocalDate>(date),
      'note': serializer.toJson<String?>(note),
      'walletId': serializer.toJson<String?>(walletId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currency': serializer.toJson<String?>(currency),
      'transferId': serializer.toJson<String?>(transferId),
      'fromWalletId': serializer.toJson<String?>(fromWalletId),
      'toWalletId': serializer.toJson<String?>(toWalletId),
      'amountSentMinor': serializer.toJson<int?>(amountSentMinor),
      'sentCurrency': serializer.toJson<String?>(sentCurrency),
      'amountReceivedMinor': serializer.toJson<int?>(amountReceivedMinor),
      'receivedCurrency': serializer.toJson<String?>(receivedCurrency),
      'deleted': serializer.toJson<bool>(deleted),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  TransactionDto copyWith({
    String? id,
    String? kind,
    LocalDate? date,
    Value<String?> note = const Value.absent(),
    Value<String?> walletId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<int?> amountMinor = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    Value<String?> transferId = const Value.absent(),
    Value<String?> fromWalletId = const Value.absent(),
    Value<String?> toWalletId = const Value.absent(),
    Value<int?> amountSentMinor = const Value.absent(),
    Value<String?> sentCurrency = const Value.absent(),
    Value<int?> amountReceivedMinor = const Value.absent(),
    Value<String?> receivedCurrency = const Value.absent(),
    bool? deleted,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => TransactionDto(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    walletId: walletId.present ? walletId.value : this.walletId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    currency: currency.present ? currency.value : this.currency,
    transferId: transferId.present ? transferId.value : this.transferId,
    fromWalletId: fromWalletId.present ? fromWalletId.value : this.fromWalletId,
    toWalletId: toWalletId.present ? toWalletId.value : this.toWalletId,
    amountSentMinor: amountSentMinor.present
        ? amountSentMinor.value
        : this.amountSentMinor,
    sentCurrency: sentCurrency.present ? sentCurrency.value : this.sentCurrency,
    amountReceivedMinor: amountReceivedMinor.present
        ? amountReceivedMinor.value
        : this.amountReceivedMinor,
    receivedCurrency: receivedCurrency.present
        ? receivedCurrency.value
        : this.receivedCurrency,
    deleted: deleted ?? this.deleted,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  TransactionDto copyWithCompanion(TransactionsCompanion data) {
    return TransactionDto(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      transferId: data.transferId.present
          ? data.transferId.value
          : this.transferId,
      fromWalletId: data.fromWalletId.present
          ? data.fromWalletId.value
          : this.fromWalletId,
      toWalletId: data.toWalletId.present
          ? data.toWalletId.value
          : this.toWalletId,
      amountSentMinor: data.amountSentMinor.present
          ? data.amountSentMinor.value
          : this.amountSentMinor,
      sentCurrency: data.sentCurrency.present
          ? data.sentCurrency.value
          : this.sentCurrency,
      amountReceivedMinor: data.amountReceivedMinor.present
          ? data.amountReceivedMinor.value
          : this.amountReceivedMinor,
      receivedCurrency: data.receivedCurrency.present
          ? data.receivedCurrency.value
          : this.receivedCurrency,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionDto(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('walletId: $walletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('transferId: $transferId, ')
          ..write('fromWalletId: $fromWalletId, ')
          ..write('toWalletId: $toWalletId, ')
          ..write('amountSentMinor: $amountSentMinor, ')
          ..write('sentCurrency: $sentCurrency, ')
          ..write('amountReceivedMinor: $amountReceivedMinor, ')
          ..write('receivedCurrency: $receivedCurrency, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    date,
    note,
    walletId,
    categoryId,
    amountMinor,
    currency,
    transferId,
    fromWalletId,
    toWalletId,
    amountSentMinor,
    sentCurrency,
    amountReceivedMinor,
    receivedCurrency,
    deleted,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionDto &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.date == this.date &&
          other.note == this.note &&
          other.walletId == this.walletId &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.transferId == this.transferId &&
          other.fromWalletId == this.fromWalletId &&
          other.toWalletId == this.toWalletId &&
          other.amountSentMinor == this.amountSentMinor &&
          other.sentCurrency == this.sentCurrency &&
          other.amountReceivedMinor == this.amountReceivedMinor &&
          other.receivedCurrency == this.receivedCurrency &&
          other.deleted == this.deleted &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionDto> {
  final Value<String> id;
  final Value<String> kind;
  final Value<LocalDate> date;
  final Value<String?> note;
  final Value<String?> walletId;
  final Value<String?> categoryId;
  final Value<int?> amountMinor;
  final Value<String?> currency;
  final Value<String?> transferId;
  final Value<String?> fromWalletId;
  final Value<String?> toWalletId;
  final Value<int?> amountSentMinor;
  final Value<String?> sentCurrency;
  final Value<int?> amountReceivedMinor;
  final Value<String?> receivedCurrency;
  final Value<bool> deleted;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.walletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.transferId = const Value.absent(),
    this.fromWalletId = const Value.absent(),
    this.toWalletId = const Value.absent(),
    this.amountSentMinor = const Value.absent(),
    this.sentCurrency = const Value.absent(),
    this.amountReceivedMinor = const Value.absent(),
    this.receivedCurrency = const Value.absent(),
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String kind,
    required LocalDate date,
    this.note = const Value.absent(),
    this.walletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.transferId = const Value.absent(),
    this.fromWalletId = const Value.absent(),
    this.toWalletId = const Value.absent(),
    this.amountSentMinor = const Value.absent(),
    this.sentCurrency = const Value.absent(),
    this.amountReceivedMinor = const Value.absent(),
    this.receivedCurrency = const Value.absent(),
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       date = Value(date);
  static Insertable<TransactionDto> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? date,
    Expression<String>? note,
    Expression<String>? walletId,
    Expression<String>? categoryId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? transferId,
    Expression<String>? fromWalletId,
    Expression<String>? toWalletId,
    Expression<int>? amountSentMinor,
    Expression<String>? sentCurrency,
    Expression<int>? amountReceivedMinor,
    Expression<String>? receivedCurrency,
    Expression<bool>? deleted,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (walletId != null) 'wallet_id': walletId,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (transferId != null) 'transfer_id': transferId,
      if (fromWalletId != null) 'from_wallet_id': fromWalletId,
      if (toWalletId != null) 'to_wallet_id': toWalletId,
      if (amountSentMinor != null) 'amount_sent_minor': amountSentMinor,
      if (sentCurrency != null) 'sent_currency': sentCurrency,
      if (amountReceivedMinor != null)
        'amount_received_minor': amountReceivedMinor,
      if (receivedCurrency != null) 'received_currency': receivedCurrency,
      if (deleted != null) 'deleted': deleted,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<LocalDate>? date,
    Value<String?>? note,
    Value<String?>? walletId,
    Value<String?>? categoryId,
    Value<int?>? amountMinor,
    Value<String?>? currency,
    Value<String?>? transferId,
    Value<String?>? fromWalletId,
    Value<String?>? toWalletId,
    Value<int?>? amountSentMinor,
    Value<String?>? sentCurrency,
    Value<int?>? amountReceivedMinor,
    Value<String?>? receivedCurrency,
    Value<bool>? deleted,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      date: date ?? this.date,
      note: note ?? this.note,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      transferId: transferId ?? this.transferId,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      amountSentMinor: amountSentMinor ?? this.amountSentMinor,
      sentCurrency: sentCurrency ?? this.sentCurrency,
      amountReceivedMinor: amountReceivedMinor ?? this.amountReceivedMinor,
      receivedCurrency: receivedCurrency ?? this.receivedCurrency,
      deleted: deleted ?? this.deleted,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $TransactionsTable.$converterdate.toSql(date.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (transferId.present) {
      map['transfer_id'] = Variable<String>(transferId.value);
    }
    if (fromWalletId.present) {
      map['from_wallet_id'] = Variable<String>(fromWalletId.value);
    }
    if (toWalletId.present) {
      map['to_wallet_id'] = Variable<String>(toWalletId.value);
    }
    if (amountSentMinor.present) {
      map['amount_sent_minor'] = Variable<int>(amountSentMinor.value);
    }
    if (sentCurrency.present) {
      map['sent_currency'] = Variable<String>(sentCurrency.value);
    }
    if (amountReceivedMinor.present) {
      map['amount_received_minor'] = Variable<int>(amountReceivedMinor.value);
    }
    if (receivedCurrency.present) {
      map['received_currency'] = Variable<String>(receivedCurrency.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('walletId: $walletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('transferId: $transferId, ')
          ..write('fromWalletId: $fromWalletId, ')
          ..write('toWalletId: $toWalletId, ')
          ..write('amountSentMinor: $amountSentMinor, ')
          ..write('sentCurrency: $sentCurrency, ')
          ..write('amountReceivedMinor: $amountReceivedMinor, ')
          ..write('receivedCurrency: $receivedCurrency, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitMinorMeta = const VerificationMeta(
    'limitMinor',
  );
  @override
  late final GeneratedColumn<int> limitMinor = GeneratedColumn<int>(
    'limit_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    limitMinor,
    currency,
    effectiveFrom,
    deleted,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('limit_minor')) {
      context.handle(
        _limitMinorMeta,
        limitMinor.isAcceptableOrUnknown(data['limit_minor']!, _limitMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_limitMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      limitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetDto extends DataClass implements Insertable<BudgetDto> {
  final String id;
  final String categoryId;
  final int limitMinor;
  final String currency;
  final String effectiveFrom;
  final bool deleted;
  final int? serverUpdatedAt;
  const BudgetDto({
    required this.id,
    required this.categoryId,
    required this.limitMinor,
    required this.currency,
    required this.effectiveFrom,
    required this.deleted,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['limit_minor'] = Variable<int>(limitMinor);
    map['currency'] = Variable<String>(currency);
    map['effective_from'] = Variable<String>(effectiveFrom);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      limitMinor: Value(limitMinor),
      currency: Value(currency),
      effectiveFrom: Value(effectiveFrom),
      deleted: Value(deleted),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory BudgetDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetDto(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      limitMinor: serializer.fromJson<int>(json['limitMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      effectiveFrom: serializer.fromJson<String>(json['effectiveFrom']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'limitMinor': serializer.toJson<int>(limitMinor),
      'currency': serializer.toJson<String>(currency),
      'effectiveFrom': serializer.toJson<String>(effectiveFrom),
      'deleted': serializer.toJson<bool>(deleted),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  BudgetDto copyWith({
    String? id,
    String? categoryId,
    int? limitMinor,
    String? currency,
    String? effectiveFrom,
    bool? deleted,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => BudgetDto(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    limitMinor: limitMinor ?? this.limitMinor,
    currency: currency ?? this.currency,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    deleted: deleted ?? this.deleted,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  BudgetDto copyWithCompanion(BudgetsCompanion data) {
    return BudgetDto(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      limitMinor: data.limitMinor.present
          ? data.limitMinor.value
          : this.limitMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetDto(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currency: $currency, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    limitMinor,
    currency,
    effectiveFrom,
    deleted,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetDto &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.limitMinor == this.limitMinor &&
          other.currency == this.currency &&
          other.effectiveFrom == this.effectiveFrom &&
          other.deleted == this.deleted &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class BudgetsCompanion extends UpdateCompanion<BudgetDto> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<int> limitMinor;
  final Value<String> currency;
  final Value<String> effectiveFrom;
  final Value<bool> deleted;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.limitMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String categoryId,
    required int limitMinor,
    required String currency,
    required String effectiveFrom,
    this.deleted = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       limitMinor = Value(limitMinor),
       currency = Value(currency),
       effectiveFrom = Value(effectiveFrom);
  static Insertable<BudgetDto> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<int>? limitMinor,
    Expression<String>? currency,
    Expression<String>? effectiveFrom,
    Expression<bool>? deleted,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (limitMinor != null) 'limit_minor': limitMinor,
      if (currency != null) 'currency': currency,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (deleted != null) 'deleted': deleted,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<int>? limitMinor,
    Value<String>? currency,
    Value<String>? effectiveFrom,
    Value<bool>? deleted,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitMinor: limitMinor ?? this.limitMinor,
      currency: currency ?? this.currency,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      deleted: deleted ?? this.deleted,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (limitMinor.present) {
      map['limit_minor'] = Variable<int>(limitMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currency: $currency, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('deleted: $deleted, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RatesTable extends Rates with TableInfo<$RatesTable, ExchangeRateDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RatesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($RatesTable.$converterdate);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perUsdMicrosMeta = const VerificationMeta(
    'perUsdMicros',
  );
  @override
  late final GeneratedColumn<int> perUsdMicros = GeneratedColumn<int>(
    'per_usd_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    currency,
    perUsdMicros,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRateDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('per_usd_micros')) {
      context.handle(
        _perUsdMicrosMeta,
        perUsdMicros.isAcceptableOrUnknown(
          data['per_usd_micros']!,
          _perUsdMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perUsdMicrosMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, currency};
  @override
  ExchangeRateDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateDto(
      date: $RatesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      perUsdMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}per_usd_micros'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $RatesTable createAlias(String alias) {
    return $RatesTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdate =
      const LocalDateConverter('rates', 'date');
}

class ExchangeRateDto extends DataClass implements Insertable<ExchangeRateDto> {
  final LocalDate date;
  final String currency;
  final int perUsdMicros;
  final int? serverUpdatedAt;
  const ExchangeRateDto({
    required this.date,
    required this.currency,
    required this.perUsdMicros,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['date'] = Variable<String>($RatesTable.$converterdate.toSql(date));
    }
    map['currency'] = Variable<String>(currency);
    map['per_usd_micros'] = Variable<int>(perUsdMicros);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  RatesCompanion toCompanion(bool nullToAbsent) {
    return RatesCompanion(
      date: Value(date),
      currency: Value(currency),
      perUsdMicros: Value(perUsdMicros),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory ExchangeRateDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateDto(
      date: serializer.fromJson<LocalDate>(json['date']),
      currency: serializer.fromJson<String>(json['currency']),
      perUsdMicros: serializer.fromJson<int>(json['perUsdMicros']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<LocalDate>(date),
      'currency': serializer.toJson<String>(currency),
      'perUsdMicros': serializer.toJson<int>(perUsdMicros),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  ExchangeRateDto copyWith({
    LocalDate? date,
    String? currency,
    int? perUsdMicros,
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => ExchangeRateDto(
    date: date ?? this.date,
    currency: currency ?? this.currency,
    perUsdMicros: perUsdMicros ?? this.perUsdMicros,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  ExchangeRateDto copyWithCompanion(RatesCompanion data) {
    return ExchangeRateDto(
      date: data.date.present ? data.date.value : this.date,
      currency: data.currency.present ? data.currency.value : this.currency,
      perUsdMicros: data.perUsdMicros.present
          ? data.perUsdMicros.value
          : this.perUsdMicros,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateDto(')
          ..write('date: $date, ')
          ..write('currency: $currency, ')
          ..write('perUsdMicros: $perUsdMicros, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, currency, perUsdMicros, serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateDto &&
          other.date == this.date &&
          other.currency == this.currency &&
          other.perUsdMicros == this.perUsdMicros &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class RatesCompanion extends UpdateCompanion<ExchangeRateDto> {
  final Value<LocalDate> date;
  final Value<String> currency;
  final Value<int> perUsdMicros;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const RatesCompanion({
    this.date = const Value.absent(),
    this.currency = const Value.absent(),
    this.perUsdMicros = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RatesCompanion.insert({
    required LocalDate date,
    required String currency,
    required int perUsdMicros,
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       currency = Value(currency),
       perUsdMicros = Value(perUsdMicros);
  static Insertable<ExchangeRateDto> custom({
    Expression<String>? date,
    Expression<String>? currency,
    Expression<int>? perUsdMicros,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (currency != null) 'currency': currency,
      if (perUsdMicros != null) 'per_usd_micros': perUsdMicros,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RatesCompanion copyWith({
    Value<LocalDate>? date,
    Value<String>? currency,
    Value<int>? perUsdMicros,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return RatesCompanion(
      date: date ?? this.date,
      currency: currency ?? this.currency,
      perUsdMicros: perUsdMicros ?? this.perUsdMicros,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(
        $RatesTable.$converterdate.toSql(date.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (perUsdMicros.present) {
      map['per_usd_micros'] = Variable<int>(perUsdMicros.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RatesCompanion(')
          ..write('date: $date, ')
          ..write('currency: $currency, ')
          ..write('perUsdMicros: $perUsdMicros, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, PreferencesDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayCurrencyMeta = const VerificationMeta(
    'displayCurrency',
  );
  @override
  late final GeneratedColumn<String> displayCurrency = GeneratedColumn<String>(
    'display_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletAppearanceMeta = const VerificationMeta(
    'walletAppearance',
  );
  @override
  late final GeneratedColumn<String> walletAppearance = GeneratedColumn<String>(
    'wallet_appearance',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayCurrency,
    walletAppearance,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferencesDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_currency')) {
      context.handle(
        _displayCurrencyMeta,
        displayCurrency.isAcceptableOrUnknown(
          data['display_currency']!,
          _displayCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayCurrencyMeta);
    }
    if (data.containsKey('wallet_appearance')) {
      context.handle(
        _walletAppearanceMeta,
        walletAppearance.isAcceptableOrUnknown(
          data['wallet_appearance']!,
          _walletAppearanceMeta,
        ),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreferencesDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferencesDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_currency'],
      )!,
      walletAppearance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_appearance'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class PreferencesDto extends DataClass implements Insertable<PreferencesDto> {
  final String id;
  final String displayCurrency;
  final String? walletAppearance;
  final int? serverUpdatedAt;
  const PreferencesDto({
    required this.id,
    required this.displayCurrency,
    this.walletAppearance,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_currency'] = Variable<String>(displayCurrency);
    if (!nullToAbsent || walletAppearance != null) {
      map['wallet_appearance'] = Variable<String>(walletAppearance);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      id: Value(id),
      displayCurrency: Value(displayCurrency),
      walletAppearance: walletAppearance == null && nullToAbsent
          ? const Value.absent()
          : Value(walletAppearance),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory PreferencesDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferencesDto(
      id: serializer.fromJson<String>(json['id']),
      displayCurrency: serializer.fromJson<String>(json['displayCurrency']),
      walletAppearance: serializer.fromJson<String?>(json['walletAppearance']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayCurrency': serializer.toJson<String>(displayCurrency),
      'walletAppearance': serializer.toJson<String?>(walletAppearance),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  PreferencesDto copyWith({
    String? id,
    String? displayCurrency,
    Value<String?> walletAppearance = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => PreferencesDto(
    id: id ?? this.id,
    displayCurrency: displayCurrency ?? this.displayCurrency,
    walletAppearance: walletAppearance.present
        ? walletAppearance.value
        : this.walletAppearance,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  PreferencesDto copyWithCompanion(PreferencesCompanion data) {
    return PreferencesDto(
      id: data.id.present ? data.id.value : this.id,
      displayCurrency: data.displayCurrency.present
          ? data.displayCurrency.value
          : this.displayCurrency,
      walletAppearance: data.walletAppearance.present
          ? data.walletAppearance.value
          : this.walletAppearance,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesDto(')
          ..write('id: $id, ')
          ..write('displayCurrency: $displayCurrency, ')
          ..write('walletAppearance: $walletAppearance, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayCurrency, walletAppearance, serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferencesDto &&
          other.id == this.id &&
          other.displayCurrency == this.displayCurrency &&
          other.walletAppearance == this.walletAppearance &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class PreferencesCompanion extends UpdateCompanion<PreferencesDto> {
  final Value<String> id;
  final Value<String> displayCurrency;
  final Value<String?> walletAppearance;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.id = const Value.absent(),
    this.displayCurrency = const Value.absent(),
    this.walletAppearance = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String id,
    required String displayCurrency,
    this.walletAppearance = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayCurrency = Value(displayCurrency);
  static Insertable<PreferencesDto> custom({
    Expression<String>? id,
    Expression<String>? displayCurrency,
    Expression<String>? walletAppearance,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayCurrency != null) 'display_currency': displayCurrency,
      if (walletAppearance != null) 'wallet_appearance': walletAppearance,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayCurrency,
    Value<String?>? walletAppearance,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
      id: id ?? this.id,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      walletAppearance: walletAppearance ?? this.walletAppearance,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayCurrency.present) {
      map['display_currency'] = Variable<String>(displayCurrency.value);
    }
    if (walletAppearance.present) {
      map['wallet_appearance'] = Variable<String>(walletAppearance.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('id: $id, ')
          ..write('displayCurrency: $displayCurrency, ')
          ..write('walletAppearance: $walletAppearance, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxEntryDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _writesMeta = const VerificationMeta('writes');
  @override
  late final GeneratedColumn<String> writes = GeneratedColumn<String>(
    'writes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keysMeta = const VerificationMeta('keys');
  @override
  late final GeneratedColumn<String> keys = GeneratedColumn<String>(
    'keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seq, writes, keys, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntryDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('writes')) {
      context.handle(
        _writesMeta,
        writes.isAcceptableOrUnknown(data['writes']!, _writesMeta),
      );
    } else if (isInserting) {
      context.missing(_writesMeta);
    }
    if (data.containsKey('keys')) {
      context.handle(
        _keysMeta,
        keys.isAcceptableOrUnknown(data['keys']!, _keysMeta),
      );
    } else if (isInserting) {
      context.missing(_keysMeta);
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxEntryDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntryDto(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      writes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}writes'],
      )!,
      keys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keys'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxEntryDto extends DataClass implements Insertable<OutboxEntryDto> {
  final int seq;
  final String writes;
  final String keys;
  final String status;
  final int createdAt;
  const OutboxEntryDto({
    required this.seq,
    required this.writes,
    required this.keys,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['writes'] = Variable<String>(writes);
    map['keys'] = Variable<String>(keys);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      writes: Value(writes),
      keys: Value(keys),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEntryDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntryDto(
      seq: serializer.fromJson<int>(json['seq']),
      writes: serializer.fromJson<String>(json['writes']),
      keys: serializer.fromJson<String>(json['keys']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'writes': serializer.toJson<String>(writes),
      'keys': serializer.toJson<String>(keys),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxEntryDto copyWith({
    int? seq,
    String? writes,
    String? keys,
    String? status,
    int? createdAt,
  }) => OutboxEntryDto(
    seq: seq ?? this.seq,
    writes: writes ?? this.writes,
    keys: keys ?? this.keys,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxEntryDto copyWithCompanion(OutboxCompanion data) {
    return OutboxEntryDto(
      seq: data.seq.present ? data.seq.value : this.seq,
      writes: data.writes.present ? data.writes.value : this.writes,
      keys: data.keys.present ? data.keys.value : this.keys,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntryDto(')
          ..write('seq: $seq, ')
          ..write('writes: $writes, ')
          ..write('keys: $keys, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, writes, keys, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntryDto &&
          other.seq == this.seq &&
          other.writes == this.writes &&
          other.keys == this.keys &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxEntryDto> {
  final Value<int> seq;
  final Value<String> writes;
  final Value<String> keys;
  final Value<String> status;
  final Value<int> createdAt;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.writes = const Value.absent(),
    this.keys = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String writes,
    required String keys,
    this.status = const Value.absent(),
    required int createdAt,
  }) : writes = Value(writes),
       keys = Value(keys),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntryDto> custom({
    Expression<int>? seq,
    Expression<String>? writes,
    Expression<String>? keys,
    Expression<String>? status,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (writes != null) 'writes': writes,
      if (keys != null) 'keys': keys,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? writes,
    Value<String>? keys,
    Value<String>? status,
    Value<int>? createdAt,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      writes: writes ?? this.writes,
      keys: keys ?? this.keys,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (writes.present) {
      map['writes'] = Variable<String>(writes.value);
    }
    if (keys.present) {
      map['keys'] = Variable<String>(keys.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('writes: $writes, ')
          ..write('keys: $keys, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NeedsAttentionTable extends NeedsAttention
    with TableInfo<$NeedsAttentionTable, NeedsAttentionDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NeedsAttentionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _outboxSeqMeta = const VerificationMeta(
    'outboxSeq',
  );
  @override
  late final GeneratedColumn<int> outboxSeq = GeneratedColumn<int>(
    'outbox_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, outboxSeq, errorCode, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'needs_attention';
  @override
  VerificationContext validateIntegrity(
    Insertable<NeedsAttentionDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('outbox_seq')) {
      context.handle(
        _outboxSeqMeta,
        outboxSeq.isAcceptableOrUnknown(data['outbox_seq']!, _outboxSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_outboxSeqMeta);
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_errorCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NeedsAttentionDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NeedsAttentionDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      outboxSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outbox_seq'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NeedsAttentionTable createAlias(String alias) {
    return $NeedsAttentionTable(attachedDatabase, alias);
  }
}

class NeedsAttentionDto extends DataClass
    implements Insertable<NeedsAttentionDto> {
  final int id;
  final int outboxSeq;
  final String errorCode;
  final int createdAt;
  const NeedsAttentionDto({
    required this.id,
    required this.outboxSeq,
    required this.errorCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['outbox_seq'] = Variable<int>(outboxSeq);
    map['error_code'] = Variable<String>(errorCode);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  NeedsAttentionCompanion toCompanion(bool nullToAbsent) {
    return NeedsAttentionCompanion(
      id: Value(id),
      outboxSeq: Value(outboxSeq),
      errorCode: Value(errorCode),
      createdAt: Value(createdAt),
    );
  }

  factory NeedsAttentionDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NeedsAttentionDto(
      id: serializer.fromJson<int>(json['id']),
      outboxSeq: serializer.fromJson<int>(json['outboxSeq']),
      errorCode: serializer.fromJson<String>(json['errorCode']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'outboxSeq': serializer.toJson<int>(outboxSeq),
      'errorCode': serializer.toJson<String>(errorCode),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  NeedsAttentionDto copyWith({
    int? id,
    int? outboxSeq,
    String? errorCode,
    int? createdAt,
  }) => NeedsAttentionDto(
    id: id ?? this.id,
    outboxSeq: outboxSeq ?? this.outboxSeq,
    errorCode: errorCode ?? this.errorCode,
    createdAt: createdAt ?? this.createdAt,
  );
  NeedsAttentionDto copyWithCompanion(NeedsAttentionCompanion data) {
    return NeedsAttentionDto(
      id: data.id.present ? data.id.value : this.id,
      outboxSeq: data.outboxSeq.present ? data.outboxSeq.value : this.outboxSeq,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NeedsAttentionDto(')
          ..write('id: $id, ')
          ..write('outboxSeq: $outboxSeq, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, outboxSeq, errorCode, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NeedsAttentionDto &&
          other.id == this.id &&
          other.outboxSeq == this.outboxSeq &&
          other.errorCode == this.errorCode &&
          other.createdAt == this.createdAt);
}

class NeedsAttentionCompanion extends UpdateCompanion<NeedsAttentionDto> {
  final Value<int> id;
  final Value<int> outboxSeq;
  final Value<String> errorCode;
  final Value<int> createdAt;
  const NeedsAttentionCompanion({
    this.id = const Value.absent(),
    this.outboxSeq = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NeedsAttentionCompanion.insert({
    this.id = const Value.absent(),
    required int outboxSeq,
    required String errorCode,
    required int createdAt,
  }) : outboxSeq = Value(outboxSeq),
       errorCode = Value(errorCode),
       createdAt = Value(createdAt);
  static Insertable<NeedsAttentionDto> custom({
    Expression<int>? id,
    Expression<int>? outboxSeq,
    Expression<String>? errorCode,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (outboxSeq != null) 'outbox_seq': outboxSeq,
      if (errorCode != null) 'error_code': errorCode,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NeedsAttentionCompanion copyWith({
    Value<int>? id,
    Value<int>? outboxSeq,
    Value<String>? errorCode,
    Value<int>? createdAt,
  }) {
    return NeedsAttentionCompanion(
      id: id ?? this.id,
      outboxSeq: outboxSeq ?? this.outboxSeq,
      errorCode: errorCode ?? this.errorCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (outboxSeq.present) {
      map['outbox_seq'] = Variable<int>(outboxSeq.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NeedsAttentionCompanion(')
          ..write('id: $id, ')
          ..write('outboxSeq: $outboxSeq, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
    'collection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMicrosMeta = const VerificationMeta(
    'cursorMicros',
  );
  @override
  late final GeneratedColumn<int> cursorMicros = GeneratedColumn<int>(
    'cursor_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [collection, cursorMicros];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursor';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('cursor_micros')) {
      context.handle(
        _cursorMicrosMeta,
        cursorMicros.isAcceptableOrUnknown(
          data['cursor_micros']!,
          _cursorMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cursorMicrosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collection};
  @override
  SyncCursorDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorDto(
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection'],
      )!,
      cursorMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor_micros'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorDto extends DataClass implements Insertable<SyncCursorDto> {
  final String collection;
  final int cursorMicros;
  const SyncCursorDto({required this.collection, required this.cursorMicros});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection'] = Variable<String>(collection);
    map['cursor_micros'] = Variable<int>(cursorMicros);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      collection: Value(collection),
      cursorMicros: Value(cursorMicros),
    );
  }

  factory SyncCursorDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorDto(
      collection: serializer.fromJson<String>(json['collection']),
      cursorMicros: serializer.fromJson<int>(json['cursorMicros']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collection': serializer.toJson<String>(collection),
      'cursorMicros': serializer.toJson<int>(cursorMicros),
    };
  }

  SyncCursorDto copyWith({String? collection, int? cursorMicros}) =>
      SyncCursorDto(
        collection: collection ?? this.collection,
        cursorMicros: cursorMicros ?? this.cursorMicros,
      );
  SyncCursorDto copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorDto(
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      cursorMicros: data.cursorMicros.present
          ? data.cursorMicros.value
          : this.cursorMicros,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorDto(')
          ..write('collection: $collection, ')
          ..write('cursorMicros: $cursorMicros')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collection, cursorMicros);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorDto &&
          other.collection == this.collection &&
          other.cursorMicros == this.cursorMicros);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorDto> {
  final Value<String> collection;
  final Value<int> cursorMicros;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.collection = const Value.absent(),
    this.cursorMicros = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String collection,
    required int cursorMicros,
    this.rowid = const Value.absent(),
  }) : collection = Value(collection),
       cursorMicros = Value(cursorMicros);
  static Insertable<SyncCursorDto> custom({
    Expression<String>? collection,
    Expression<int>? cursorMicros,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collection != null) 'collection': collection,
      if (cursorMicros != null) 'cursor_micros': cursorMicros,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? collection,
    Value<int>? cursorMicros,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      collection: collection ?? this.collection,
      cursorMicros: cursorMicros ?? this.cursorMicros,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (cursorMicros.present) {
      map['cursor_micros'] = Variable<int>(cursorMicros.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('collection: $collection, ')
          ..write('cursorMicros: $cursorMicros, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RatesTable rates = $RatesTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $NeedsAttentionTable needsAttention = $NeedsAttentionTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wallets,
    categories,
    transactions,
    budgets,
    rates,
    preferences,
    outbox,
    needsAttention,
    syncCursors,
  ];
}

typedef $$WalletsTableCreateCompanionBuilder = WalletsCompanion Function({
  required String id,
  required String name,
  required String kind,
  required String currency,
  required int openingBalanceMinor,
  required String status,
  required LocalDate createdOn,
  Value<bool> hasTransactions,
  Value<bool> deleted,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$WalletsTableUpdateCompanionBuilder = WalletsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> kind,
  Value<String> currency,
  Value<int> openingBalanceMinor,
  Value<String> status,
  Value<LocalDate> createdOn,
  Value<bool> hasTransactions,
  Value<bool> deleted,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get createdOn =>
      $composableBuilder(
        column: $table.createdOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get hasTransactions => $composableBuilder(
    column: $table.hasTransactions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasTransactions => $composableBuilder(
    column: $table.hasTransactions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  GeneratedColumn<bool> get hasTransactions => $composableBuilder(
    column: $table.hasTransactions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          WalletDto,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (WalletDto, BaseReferences<_$AppDatabase, $WalletsTable, WalletDto>),
          WalletDto,
          PrefetchHooks Function()
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> openingBalanceMinor = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<LocalDate> createdOn = const Value.absent(),
                Value<bool> hasTransactions = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletsCompanion(
                id: id,
                name: name,
                kind: kind,
                currency: currency,
                openingBalanceMinor: openingBalanceMinor,
                status: status,
                createdOn: createdOn,
                hasTransactions: hasTransactions,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required String currency,
                required int openingBalanceMinor,
                required String status,
                required LocalDate createdOn,
                Value<bool> hasTransactions = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                currency: currency,
                openingBalanceMinor: openingBalanceMinor,
                status: status,
                createdOn: createdOn,
                hasTransactions: hasTransactions,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WalletsTable, WalletDto>(table),
                  BaseReferences<_$AppDatabase, $WalletsTable, WalletDto>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      WalletDto,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (WalletDto, BaseReferences<_$AppDatabase, $WalletsTable, WalletDto>),
      WalletDto,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required String type,
  required bool isDefault,
  Value<String?> systemKey,
  Value<bool> deleted,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<bool> isDefault,
  Value<String?> systemKey,
  Value<bool> deleted,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemKey => $composableBuilder(
    column: $table.systemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemKey => $composableBuilder(
    column: $table.systemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get systemKey =>
      $composableBuilder(column: $table.systemKey, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryDto,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryDto,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryDto>,
          ),
          CategoryDto,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> systemKey = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                isDefault: isDefault,
                systemKey: systemKey,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required bool isDefault,
                Value<String?> systemKey = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                isDefault: isDefault,
                systemKey: systemKey,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryDto>(table),
                  BaseReferences<_$AppDatabase, $CategoriesTable, CategoryDto>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryDto,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryDto,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryDto>,
      ),
      CategoryDto,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String kind,
      required LocalDate date,
      Value<String?> note,
      Value<String?> walletId,
      Value<String?> categoryId,
      Value<int?> amountMinor,
      Value<String?> currency,
      Value<String?> transferId,
      Value<String?> fromWalletId,
      Value<String?> toWalletId,
      Value<int?> amountSentMinor,
      Value<String?> sentCurrency,
      Value<int?> amountReceivedMinor,
      Value<String?> receivedCurrency,
      Value<bool> deleted,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<LocalDate> date,
      Value<String?> note,
      Value<String?> walletId,
      Value<String?> categoryId,
      Value<int?> amountMinor,
      Value<String?> currency,
      Value<String?> transferId,
      Value<String?> fromWalletId,
      Value<String?> toWalletId,
      Value<int?> amountSentMinor,
      Value<String?> sentCurrency,
      Value<int?> amountReceivedMinor,
      Value<String?> receivedCurrency,
      Value<bool> deleted,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromWalletId => $composableBuilder(
    column: $table.fromWalletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toWalletId => $composableBuilder(
    column: $table.toWalletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountSentMinor => $composableBuilder(
    column: $table.amountSentMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentCurrency => $composableBuilder(
    column: $table.sentCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountReceivedMinor => $composableBuilder(
    column: $table.amountReceivedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedCurrency => $composableBuilder(
    column: $table.receivedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromWalletId => $composableBuilder(
    column: $table.fromWalletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toWalletId => $composableBuilder(
    column: $table.toWalletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountSentMinor => $composableBuilder(
    column: $table.amountSentMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentCurrency => $composableBuilder(
    column: $table.sentCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountReceivedMinor => $composableBuilder(
    column: $table.amountReceivedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedCurrency => $composableBuilder(
    column: $table.receivedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get transferId => $composableBuilder(
    column: $table.transferId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromWalletId => $composableBuilder(
    column: $table.fromWalletId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toWalletId => $composableBuilder(
    column: $table.toWalletId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountSentMinor => $composableBuilder(
    column: $table.amountSentMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sentCurrency => $composableBuilder(
    column: $table.sentCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountReceivedMinor => $composableBuilder(
    column: $table.amountReceivedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receivedCurrency => $composableBuilder(
    column: $table.receivedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionDto,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionDto,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionDto>,
          ),
          TransactionDto,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<LocalDate> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> walletId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> transferId = const Value.absent(),
                Value<String?> fromWalletId = const Value.absent(),
                Value<String?> toWalletId = const Value.absent(),
                Value<int?> amountSentMinor = const Value.absent(),
                Value<String?> sentCurrency = const Value.absent(),
                Value<int?> amountReceivedMinor = const Value.absent(),
                Value<String?> receivedCurrency = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                kind: kind,
                date: date,
                note: note,
                walletId: walletId,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currency: currency,
                transferId: transferId,
                fromWalletId: fromWalletId,
                toWalletId: toWalletId,
                amountSentMinor: amountSentMinor,
                sentCurrency: sentCurrency,
                amountReceivedMinor: amountReceivedMinor,
                receivedCurrency: receivedCurrency,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required LocalDate date,
                Value<String?> note = const Value.absent(),
                Value<String?> walletId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> transferId = const Value.absent(),
                Value<String?> fromWalletId = const Value.absent(),
                Value<String?> toWalletId = const Value.absent(),
                Value<int?> amountSentMinor = const Value.absent(),
                Value<String?> sentCurrency = const Value.absent(),
                Value<int?> amountReceivedMinor = const Value.absent(),
                Value<String?> receivedCurrency = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                kind: kind,
                date: date,
                note: note,
                walletId: walletId,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currency: currency,
                transferId: transferId,
                fromWalletId: fromWalletId,
                toWalletId: toWalletId,
                amountSentMinor: amountSentMinor,
                sentCurrency: sentCurrency,
                amountReceivedMinor: amountReceivedMinor,
                receivedCurrency: receivedCurrency,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionDto>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TransactionsTable,
                    TransactionDto
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionDto,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionDto,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionDto>,
      ),
      TransactionDto,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  required String categoryId,
  required int limitMinor,
  required String currency,
  required String effectiveFrom,
  Value<bool> deleted,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> categoryId,
  Value<int> limitMinor,
  Value<String> currency,
  Value<String> effectiveFrom,
  Value<bool> deleted,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          BudgetDto,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (BudgetDto, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetDto>),
          BudgetDto,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> limitMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                categoryId: categoryId,
                limitMinor: limitMinor,
                currency: currency,
                effectiveFrom: effectiveFrom,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required int limitMinor,
                required String currency,
                required String effectiveFrom,
                Value<bool> deleted = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                categoryId: categoryId,
                limitMinor: limitMinor,
                currency: currency,
                effectiveFrom: effectiveFrom,
                deleted: deleted,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, BudgetDto>(table),
                  BaseReferences<_$AppDatabase, $BudgetsTable, BudgetDto>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      BudgetDto,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (BudgetDto, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetDto>),
      BudgetDto,
      PrefetchHooks Function()
    >;
typedef $$RatesTableCreateCompanionBuilder = RatesCompanion Function({
  required LocalDate date,
  required String currency,
  required int perUsdMicros,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$RatesTableUpdateCompanionBuilder = RatesCompanion Function({
  Value<LocalDate> date,
  Value<String> currency,
  Value<int> perUsdMicros,
  Value<int?> serverUpdatedAt,
  Value<int> rowid,
});

class $$RatesTableFilterComposer extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perUsdMicros => $composableBuilder(
    column: $table.perUsdMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perUsdMicros => $composableBuilder(
    column: $table.perUsdMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get perUsdMicros => $composableBuilder(
    column: $table.perUsdMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$RatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RatesTable,
          ExchangeRateDto,
          $$RatesTableFilterComposer,
          $$RatesTableOrderingComposer,
          $$RatesTableAnnotationComposer,
          $$RatesTableCreateCompanionBuilder,
          $$RatesTableUpdateCompanionBuilder,
          (
            ExchangeRateDto,
            BaseReferences<_$AppDatabase, $RatesTable, ExchangeRateDto>,
          ),
          ExchangeRateDto,
          PrefetchHooks Function()
        > {
  $$RatesTableTableManager(_$AppDatabase db, $RatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<LocalDate> date = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> perUsdMicros = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatesCompanion(
                date: date,
                currency: currency,
                perUsdMicros: perUsdMicros,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required LocalDate date,
                required String currency,
                required int perUsdMicros,
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatesCompanion.insert(
                date: date,
                currency: currency,
                perUsdMicros: perUsdMicros,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RatesTable, ExchangeRateDto>(table),
                  BaseReferences<_$AppDatabase, $RatesTable, ExchangeRateDto>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RatesTable,
      ExchangeRateDto,
      $$RatesTableFilterComposer,
      $$RatesTableOrderingComposer,
      $$RatesTableAnnotationComposer,
      $$RatesTableCreateCompanionBuilder,
      $$RatesTableUpdateCompanionBuilder,
      (
        ExchangeRateDto,
        BaseReferences<_$AppDatabase, $RatesTable, ExchangeRateDto>,
      ),
      ExchangeRateDto,
      PrefetchHooks Function()
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String id,
      required String displayCurrency,
      Value<String?> walletAppearance,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> id,
      Value<String> displayCurrency,
      Value<String?> walletAppearance,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayCurrency => $composableBuilder(
    column: $table.displayCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletAppearance => $composableBuilder(
    column: $table.walletAppearance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayCurrency => $composableBuilder(
    column: $table.displayCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletAppearance => $composableBuilder(
    column: $table.walletAppearance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayCurrency => $composableBuilder(
    column: $table.displayCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get walletAppearance => $composableBuilder(
    column: $table.walletAppearance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTable,
          PreferencesDto,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            PreferencesDto,
            BaseReferences<_$AppDatabase, $PreferencesTable, PreferencesDto>,
          ),
          PreferencesDto,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$AppDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayCurrency = const Value.absent(),
                Value<String?> walletAppearance = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(
                id: id,
                displayCurrency: displayCurrency,
                walletAppearance: walletAppearance,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayCurrency,
                Value<String?> walletAppearance = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                id: id,
                displayCurrency: displayCurrency,
                walletAppearance: walletAppearance,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferencesTable, PreferencesDto>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PreferencesTable,
                    PreferencesDto
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTable,
      PreferencesDto,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        PreferencesDto,
        BaseReferences<_$AppDatabase, $PreferencesTable, PreferencesDto>,
      ),
      PreferencesDto,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  required String writes,
  required String keys,
  Value<String> status,
  required int createdAt,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  Value<String> writes,
  Value<String> keys,
  Value<String> status,
  Value<int> createdAt,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get writes => $composableBuilder(
    column: $table.writes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get writes => $composableBuilder(
    column: $table.writes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get writes =>
      $composableBuilder(column: $table.writes, builder: (column) => column);

  GeneratedColumn<String> get keys =>
      $composableBuilder(column: $table.keys, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxEntryDto,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (
            OutboxEntryDto,
            BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntryDto>,
          ),
          OutboxEntryDto,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> writes = const Value.absent(),
                Value<String> keys = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                writes: writes,
                keys: keys,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String writes,
                required String keys,
                Value<String> status = const Value.absent(),
                required int createdAt,
              }) => OutboxCompanion.insert(
                seq: seq,
                writes: writes,
                keys: keys,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxEntryDto>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntryDto>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxEntryDto,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (
        OutboxEntryDto,
        BaseReferences<_$AppDatabase, $OutboxTable, OutboxEntryDto>,
      ),
      OutboxEntryDto,
      PrefetchHooks Function()
    >;
typedef $$NeedsAttentionTableCreateCompanionBuilder =
    NeedsAttentionCompanion Function({
      Value<int> id,
      required int outboxSeq,
      required String errorCode,
      required int createdAt,
    });
typedef $$NeedsAttentionTableUpdateCompanionBuilder =
    NeedsAttentionCompanion Function({
      Value<int> id,
      Value<int> outboxSeq,
      Value<String> errorCode,
      Value<int> createdAt,
    });

class $$NeedsAttentionTableFilterComposer
    extends Composer<_$AppDatabase, $NeedsAttentionTable> {
  $$NeedsAttentionTableFilterComposer({
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

  ColumnFilters<int> get outboxSeq => $composableBuilder(
    column: $table.outboxSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NeedsAttentionTableOrderingComposer
    extends Composer<_$AppDatabase, $NeedsAttentionTable> {
  $$NeedsAttentionTableOrderingComposer({
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

  ColumnOrderings<int> get outboxSeq => $composableBuilder(
    column: $table.outboxSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NeedsAttentionTableAnnotationComposer
    extends Composer<_$AppDatabase, $NeedsAttentionTable> {
  $$NeedsAttentionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get outboxSeq =>
      $composableBuilder(column: $table.outboxSeq, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NeedsAttentionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NeedsAttentionTable,
          NeedsAttentionDto,
          $$NeedsAttentionTableFilterComposer,
          $$NeedsAttentionTableOrderingComposer,
          $$NeedsAttentionTableAnnotationComposer,
          $$NeedsAttentionTableCreateCompanionBuilder,
          $$NeedsAttentionTableUpdateCompanionBuilder,
          (
            NeedsAttentionDto,
            BaseReferences<
              _$AppDatabase,
              $NeedsAttentionTable,
              NeedsAttentionDto
            >,
          ),
          NeedsAttentionDto,
          PrefetchHooks Function()
        > {
  $$NeedsAttentionTableTableManager(
    _$AppDatabase db,
    $NeedsAttentionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NeedsAttentionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NeedsAttentionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NeedsAttentionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> outboxSeq = const Value.absent(),
                Value<String> errorCode = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => NeedsAttentionCompanion(
                id: id,
                outboxSeq: outboxSeq,
                errorCode: errorCode,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int outboxSeq,
                required String errorCode,
                required int createdAt,
              }) => NeedsAttentionCompanion.insert(
                id: id,
                outboxSeq: outboxSeq,
                errorCode: errorCode,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NeedsAttentionTable, NeedsAttentionDto>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NeedsAttentionTable,
                    NeedsAttentionDto
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NeedsAttentionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NeedsAttentionTable,
      NeedsAttentionDto,
      $$NeedsAttentionTableFilterComposer,
      $$NeedsAttentionTableOrderingComposer,
      $$NeedsAttentionTableAnnotationComposer,
      $$NeedsAttentionTableCreateCompanionBuilder,
      $$NeedsAttentionTableUpdateCompanionBuilder,
      (
        NeedsAttentionDto,
        BaseReferences<_$AppDatabase, $NeedsAttentionTable, NeedsAttentionDto>,
      ),
      NeedsAttentionDto,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String collection,
      required int cursorMicros,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> collection,
      Value<int> cursorMicros,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursorMicros => $composableBuilder(
    column: $table.cursorMicros,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursorMicros => $composableBuilder(
    column: $table.cursorMicros,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cursorMicros => $composableBuilder(
    column: $table.cursorMicros,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorDto,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursorDto,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorDto>,
          ),
          SyncCursorDto,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collection = const Value.absent(),
                Value<int> cursorMicros = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                collection: collection,
                cursorMicros: cursorMicros,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collection,
                required int cursorMicros,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                collection: collection,
                cursorMicros: cursorMicros,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursorDto>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncCursorsTable,
                    SyncCursorDto
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorDto,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursorDto,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorDto>,
      ),
      SyncCursorDto,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RatesTableTableManager get rates =>
      $$RatesTableTableManager(_db, _db.rates);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$NeedsAttentionTableTableManager get needsAttention =>
      $$NeedsAttentionTableTableManager(_db, _db.needsAttention);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
}
