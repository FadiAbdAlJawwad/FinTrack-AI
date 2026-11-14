import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin_track_ai/core/error/wallet_exception.dart';
import 'package:fin_track_ai/features/wallets/data/services/wallet_migration_service.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory wallet store keyed by document id. `addWallet` and
/// `deleteWallet` are not implemented (a [Fake] throws), proving the
/// seeding path only upserts deterministic ids.
class InMemoryWalletRepository extends Fake implements WalletRepository {
  InMemoryWalletRepository([Map<String, WalletModel>? initial])
    : store = {...?initial};

  final Map<String, WalletModel> store;
  final upserts = <String>[];
  Object? upsertError;

  @override
  Stream<List<WalletModel>> getWalletsStream() => Stream.value([
    for (final MapEntry(key: id, value: w) in store.entries) w.copyWith(id: id),
  ]);

  @override
  Future<void> upsertWallet(String id, WalletModel wallet) async {
    if (upsertError != null) throw upsertError!;
    upserts.add(id);
    store[id] = wallet;
  }
}

const cash = WalletModel(name: 'Cash', icon: 'payments', isDefault: true);

void main() {
  group('WalletMigrationService seeding', () {
    test('no wallets: upserts exactly bank, paypal, other, cash', () async {
      final repo = InMemoryWalletRepository();
      await WalletMigrationService(repository: repo).runIfNeeded();

      expect(repo.upserts, ['bank', 'paypal', 'other', 'cash']);
    });

    test('seeded wallets keep the existing names, icons and default', () async {
      final repo = InMemoryWalletRepository();
      await WalletMigrationService(repository: repo).runIfNeeded();

      expect(repo.store['cash'], cash);
      expect(
        repo.store['bank'],
        const WalletModel(name: 'Bank Account', icon: 'account_balance', type: WalletType.bank),
      );
      expect(
        repo.store['paypal'],
        const WalletModel(name: 'PayPal', icon: 'account_balance_wallet', type: WalletType.eWallet),
      );
      expect(
        repo.store['other'],
        const WalletModel(name: 'Other', icon: 'more_horiz', type: WalletType.cash),
      );
      expect(repo.store.values.where((w) => w.isDefault), hasLength(1));
    });

    test('default wallet exists with secondary wallets deleted: no writes', () async {
      final repo = InMemoryWalletRepository({'cash': cash});
      await WalletMigrationService(repository: repo).runIfNeeded();

      expect(repo.upserts, isEmpty);
    });

    test('only a non-default wallet exists: completes seeding with cash last', () async {
      final repo = InMemoryWalletRepository({
        'x': const WalletModel(name: 'Savings', icon: 'savings'),
      });
      await WalletMigrationService(repository: repo).runIfNeeded();

      expect(repo.upserts, ['bank', 'paypal', 'other', 'cash']);
      expect(repo.upserts.last, 'cash');
    });

    test('a legacy default wallet with a random id alone: no writes', () async {
      final repo = InMemoryWalletRepository({
        'legacy_id': const WalletModel(name: 'Cash', icon: 'payments', isDefault: true),
      });
      await WalletMigrationService(repository: repo).runIfNeeded();

      expect(repo.upserts, isEmpty);
    });

    test('four wallets: no writes', () async {
      final repo = InMemoryWalletRepository();
      await WalletMigrationService(repository: repo).runIfNeeded();
      repo.upserts.clear();

      await WalletMigrationService(repository: repo).runIfNeeded();

      expect(repo.upserts, isEmpty);
    });

    test('running twice does not duplicate wallets', () async {
      final repo = InMemoryWalletRepository();
      final service = WalletMigrationService(repository: repo);

      await service.runIfNeeded();
      await service.runIfNeeded();

      expect(repo.store.keys, ['bank', 'paypal', 'other', 'cash']);
    });

    test('two concurrent first runs converge on the same four docs', () async {
      final repo = InMemoryWalletRepository();

      await Future.wait([
        WalletMigrationService(repository: repo).runIfNeeded(),
        WalletMigrationService(repository: repo).runIfNeeded(),
      ]);

      expect(repo.store, hasLength(4));
    });

    test('the service depends on the repository only', () async {
      // Compiles only because the Firestore/Auth constructor parameters are
      // gone; the run must not need anything but the repository.
      final service = WalletMigrationService(
        repository: InMemoryWalletRepository(),
      );
      await expectLater(service.runIfNeeded(), completes);
    });

    test('a Firebase error surfaces as a typed WalletException', () async {
      final repo = InMemoryWalletRepository()
        ..upsertError = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );

      await expectLater(
        WalletMigrationService(repository: repo).runIfNeeded(),
        throwsA(
          isA<WalletException>().having(
            (e) => e.type,
            'type',
            WalletErrorType.permissionDenied,
          ),
        ),
      );
    });
  });
}
