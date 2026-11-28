import 'package:drift/drift.dart';

import 'local_date_converter.dart';

@DataClassName('WalletDto')
class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get currency => text()();
  IntColumn get openingBalanceMinor => integer()();
  TextColumn get status => text()();
  TextColumn get createdOn =>
      text().map(const LocalDateConverter('wallets', 'created_on'))();
  BoolColumn get hasTransactions =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryDto')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  BoolColumn get isDefault => boolean()();
  TextColumn get systemKey => text().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionDto')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get date =>
      text().map(const LocalDateConverter('transactions', 'date'))();
  TextColumn get note => text().nullable()();
  TextColumn get walletId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get transferId => text().nullable().unique()();
  TextColumn get fromWalletId => text().nullable()();
  TextColumn get toWalletId => text().nullable()();
  IntColumn get amountSentMinor => integer().nullable()();
  TextColumn get sentCurrency => text().nullable()();
  IntColumn get amountReceivedMinor => integer().nullable()();
  TextColumn get receivedCurrency => text().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetDto')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  IntColumn get limitMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get effectiveFrom => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExchangeRateDto')
class Rates extends Table {
  TextColumn get date =>
      text().map(const LocalDateConverter('rates', 'date'))();
  TextColumn get currency => text()();
  IntColumn get perUsdMicros => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {date, currency};
}

@DataClassName('PreferencesDto')
class Preferences extends Table {
  TextColumn get id => text()();
  TextColumn get displayCurrency => text()();
  TextColumn get walletAppearance => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OutboxEntryDto')
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get writes => text()();
  TextColumn get keys => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get createdAt => integer()();
}

@DataClassName('NeedsAttentionDto')
class NeedsAttention extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get outboxSeq => integer()();
  TextColumn get errorCode => text()();
  IntColumn get createdAt => integer()();
}

@DataClassName('SyncCursorDto')
class SyncCursors extends Table {
  TextColumn get collection => text()();
  IntColumn get cursorMicros => integer()();

  @override
  Set<Column> get primaryKey => {collection};

  @override
  String get tableName => 'sync_cursor';
}
