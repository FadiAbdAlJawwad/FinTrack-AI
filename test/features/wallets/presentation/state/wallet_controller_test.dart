import 'dart:async';

import 'package:fin_track_ai/core/error/wallet_exception.dart';
import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:fin_track_ai/features/wallets/data/repositories/firestore_wallet_repository.dart';
import 'package:fin_track_ai/features/wallets/data/services/wallet_migration_service.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FakeWalletRepo implements WalletRepository {
  WalletModel? lastAdded;
  bool shouldThrow = false;
  String? lastDeleted;
  String? lastUpsertedId;
  WalletModel? lastUpserted;

  @override
  Future<String> addWallet(WalletModel wallet) async {
    if (shouldThrow) throw WalletException(WalletErrorType.networkError);
    lastAdded = wallet;
    return 'id_123';
  }

  @override
  Future<void> deleteWallet(String id) async {
    if (shouldThrow) throw WalletException(WalletErrorType.networkError);
    lastDeleted = id;
  }

  @override
  Future<void> upsertWallet(String id, WalletModel wallet) async {
    if (shouldThrow) throw WalletException(WalletErrorType.networkError);
    lastUpsertedId = id;
    lastUpserted = wallet;
  }

  @override
  Stream<List<WalletModel>> getWalletsStream() => Stream.value([
    const WalletModel(id: 'w1', name: 'Cash', icon: 'payments'),
  ]);
}

class FakeMigration extends Fake implements WalletMigrationService {
  FakeMigration({this.failFirstCalls = 0});

  int failFirstCalls;
  int calls = 0;

  @override
  Future<void> runIfNeeded() async {
    calls++;
    if (calls <= failFirstCalls) {
      throw WalletException(WalletErrorType.networkError);
    }
  }
}

const user = UserModel(uid: 'u1', email: 'a@b.c', fullName: 'A B');

ProviderContainer makeContainer(
  FakeMigration migration, {
  UserModel? who = user,
  FakeWalletRepo? repo,
}) {
  final container = ProviderContainer(
    overrides: [
      currentUserProvider.overrideWithValue(who),
      walletRepositoryProvider.overrideWithValue(repo ?? FakeWalletRepo()),
      walletMigrationProvider.overrideWithValue(migration),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('WalletController migration', () {
    test('emits wallets after the migration completed', () async {
      final migration = FakeMigration();
      final container = makeContainer(migration);
      container.listen(walletControllerProvider, (_, _) {});

      final wallets = await container.read(walletControllerProvider.future);

      expect(wallets.single.id, 'w1');
      expect(migration.calls, 1);
    });

    test(
      'runs exactly once across dispose and re-listen for one uid',
      () async {
        final migration = FakeMigration();
        final container = makeContainer(migration);

        var sub = container.listen(walletControllerProvider, (_, _) {});
        await container.read(walletControllerProvider.future);
        sub.close();
        await settle();

        sub = container.listen(walletControllerProvider, (_, _) {});
        await container.read(walletControllerProvider.future);
        sub.close();
        await settle();

        sub = container.listen(walletControllerProvider, (_, _) {});
        await container.read(walletControllerProvider.future);

        expect(migration.calls, 1);
      },
    );

    test('a failed migration surfaces as AsyncError', () async {
      final migration = FakeMigration(failFirstCalls: 1);
      final container = makeContainer(migration);
      container.listen(walletControllerProvider, (_, _) {});

      await expectLater(
        container.read(walletControllerProvider.future),
        throwsA(isA<WalletException>()),
      );

      final state = container.read(walletControllerProvider);
      expect(state, isA<AsyncError<List<WalletModel>>>());
      expect(
        (state.error! as WalletException).type,
        WalletErrorType.networkError,
      );
    });

    test('a failed migration is retried on the next rebuild', () async {
      final migration = FakeMigration(failFirstCalls: 1);
      final container = makeContainer(migration);

      var sub = container.listen(walletControllerProvider, (_, _) {});
      await expectLater(
        container.read(walletControllerProvider.future),
        throwsA(isA<WalletException>()),
      );
      sub.close();
      await settle();

      sub = container.listen(walletControllerProvider, (_, _) {});
      final wallets = await container.read(walletControllerProvider.future);

      expect(wallets.single.id, 'w1');
      expect(migration.calls, 2);
    });

    test('a different uid runs its own migration', () async {
      final migration = FakeMigration();
      final container = makeContainer(migration);
      container.listen(walletControllerProvider, (_, _) {});
      await container.read(walletControllerProvider.future);

      await container.read(walletMigrationRunProvider('other').future);

      expect(migration.calls, 2);
    });

    test('no current user yields notAuthenticated as AsyncError', () async {
      final migration = FakeMigration();
      final container = makeContainer(migration, who: null);
      container.listen(walletControllerProvider, (_, _) {});

      await expectLater(
        container.read(walletControllerProvider.future),
        throwsA(
          isA<WalletException>().having(
            (e) => e.type,
            'type',
            WalletErrorType.notAuthenticated,
          ),
        ),
      );
      expect(migration.calls, 0);
    });
  });

  group('WalletController.addWallet', () {
    test('addWallet delegates to repository and rethrows translated WalletException on failure', () async {
      final repo = FakeWalletRepo();
      final migration = FakeMigration();
      final container = makeContainer(migration, repo: repo);
      container.listen(walletControllerProvider, (_, _) {});
      await container.read(walletControllerProvider.future);

      const newWallet = WalletModel(name: 'Savings', icon: 'savings');
      await container
          .read(walletControllerProvider.notifier)
          .addWallet(newWallet);

      expect(repo.lastAdded, newWallet);

      repo.shouldThrow = true;
      await expectLater(
        container.read(walletControllerProvider.notifier).addWallet(newWallet),
        throwsA(isA<WalletException>()),
      );
    });

    test('updateWallet delegates to repository with wallet id', () async {
      final repo = FakeWalletRepo();
      final migration = FakeMigration();
      final container = makeContainer(migration, repo: repo);
      container.listen(walletControllerProvider, (_, _) {});
      await container.read(walletControllerProvider.future);

      const updatedWallet = WalletModel(
        id: 'w2',
        name: 'Savings',
        icon: 'savings',
      );
      await container
          .read(walletControllerProvider.notifier)
          .updateWallet(updatedWallet);

      expect(repo.lastUpsertedId, 'w2');
      expect(repo.lastUpserted, updatedWallet);

      repo.shouldThrow = true;
      await expectLater(
        container
            .read(walletControllerProvider.notifier)
            .updateWallet(updatedWallet),
        throwsA(isA<WalletException>()),
      );
    });

    test(
      'updateWallet with null id throws invalidData and writes nothing',
      () async {
        final repo = FakeWalletRepo();
        final migration = FakeMigration();
        final container = makeContainer(migration, repo: repo);
        container.listen(walletControllerProvider, (_, _) {});
        await container.read(walletControllerProvider.future);

        const invalidWallet = WalletModel(name: 'Savings', icon: 'savings');
        await expectLater(
          container
              .read(walletControllerProvider.notifier)
              .updateWallet(invalidWallet),
          throwsA(
            isA<WalletException>().having(
              (e) => e.type,
              'type',
              WalletErrorType.invalidData,
            ),
          ),
        );

        expect(repo.lastUpsertedId, isNull);
      },
    );

    test('deleteWallet delegates to repository', () async {
      final repo = FakeWalletRepo();
      final migration = FakeMigration();
      final container = makeContainer(migration, repo: repo);
      container.listen(walletControllerProvider, (_, _) {});
      await container.read(walletControllerProvider.future);

      await container
          .read(walletControllerProvider.notifier)
          .deleteWallet('w3');
      expect(repo.lastDeleted, 'w3');
    });

    test(
      'deleteWallet rethrows repository exception as WalletException',
      () async {
        final repo = FakeWalletRepo();
        repo.shouldThrow = true;
        final migration = FakeMigration();
        final container = makeContainer(migration, repo: repo);
        container.listen(walletControllerProvider, (_, _) {});
        await container.read(walletControllerProvider.future);

        await expectLater(
          container.read(walletControllerProvider.notifier).deleteWallet('w4'),
          throwsA(isA<WalletException>()),
        );
      },
    );
  });
}
