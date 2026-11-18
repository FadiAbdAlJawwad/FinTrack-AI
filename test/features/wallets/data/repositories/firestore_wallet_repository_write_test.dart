import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin_track_ai/core/error/wallet_exception.dart';
import 'package:fin_track_ai/features/wallets/data/datasources/wallet_remote_datasource.dart';
import 'package:fin_track_ai/features/wallets/data/repositories/firestore_wallet_repository.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledWalletDataSource implements WalletRemoteDataSource {
  Completer<void> createCompleter = Completer<void>();
  Completer<void> upsertCompleter = Completer<void>();
  Completer<void> deleteCompleter = Completer<void>();

  List<({String id, bool isDefault})> fetchAllResult = [
    (id: 'default_w', isDefault: true),
    (id: 'secondary_w', isDefault: false),
  ];

  Object? syncCreateError;

  @override
  ({String id, Future<void> write}) create(Map<String, dynamic> data) {
    if (syncCreateError != null) throw syncCreateError!;
    return (id: 'generated_id', write: createCompleter.future);
  }

  @override
  Future<void> upsert(String id, Map<String, dynamic> data) =>
      upsertCompleter.future;

  @override
  Future<void> delete(String id) => deleteCompleter.future;

  @override
  Future<List<({String id, bool isDefault})>> fetchAll() async =>
      fetchAllResult;

  @override
  Stream<List<Map<String, dynamic>>> watchAll() => const Stream.empty();
}

const shortTimeout = Duration(milliseconds: 50);

const sampleWallet = WalletModel(name: 'Cash', icon: 'payments');

FirebaseException firebaseError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  late ControlledWalletDataSource dataSource;
  late FirestoreWalletRepository repo;

  setUp(() {
    dataSource = ControlledWalletDataSource();
    repo = FirestoreWalletRepository(dataSource, writeTimeout: shortTimeout);
  });

  group('FirestoreWalletRepository write timeout & acknowledgement', () {
    test('addWallet completes and RETURNS the generated id when write is never acknowledged', () async {
      final id = await repo.addWallet(sampleWallet);
      expect(id, 'generated_id');
    });

    test(
      'addWallet error before timeout becomes WalletException permissionDenied',
      () async {
        dataSource.createCompleter.completeError(
          firebaseError('permission-denied'),
        );
        await expectLater(
          repo.addWallet(sampleWallet),
          throwsA(
            isA<WalletException>().having(
              (e) => e.type,
              'type',
              WalletErrorType.permissionDenied,
            ),
          ),
        );
      },
    );

    test('upsertWallet completes when never acknowledged', () async {
      await repo.upsertWallet('w1', sampleWallet);
    });

    test(
      'upsertWallet immediate unavailable error becomes networkError',
      () async {
        dataSource.upsertCompleter.completeError(firebaseError('unavailable'));
        await expectLater(
          repo.upsertWallet('w1', sampleWallet),
          throwsA(
            isA<WalletException>().having(
              (e) => e.type,
              'type',
              WalletErrorType.networkError,
            ),
          ),
        );
      },
    );

    test('deleteWallet completes when never acknowledged (two wallets, target non-default)', () async {
      await repo.deleteWallet('secondary_w');
    });

    group('deleteWallet guards still throw before any write', () {
      test('only one wallet -> invalidData', () async {
        dataSource.fetchAllResult = [(id: 'w1', isDefault: true)];
        await expectLater(
          repo.deleteWallet('w1'),
          throwsA(
            isA<WalletException>().having(
              (e) => e.type,
              'type',
              WalletErrorType.invalidData,
            ),
          ),
        );
      });

      test('target is default -> invalidData', () async {
        await expectLater(
          repo.deleteWallet('default_w'),
          throwsA(
            isA<WalletException>().having(
              (e) => e.type,
              'type',
              WalletErrorType.invalidData,
            ),
          ),
        );
      });

      test('unknown id -> notFound', () async {
        await expectLater(
          repo.deleteWallet('unknown'),
          throwsA(
            isA<WalletException>().having(
              (e) => e.type,
              'type',
              WalletErrorType.notFound,
            ),
          ),
        );
      });
    });

    test('an error arriving after the timeout is not an uncaught error (all three operations)', () async {
      final uncaught = <Object>[];
      await runZonedGuarded(() async {
        final late = ControlledWalletDataSource();
        final lateRepo = FirestoreWalletRepository(
          late,
          writeTimeout: shortTimeout,
        );

        await lateRepo.addWallet(sampleWallet);
        await lateRepo.upsertWallet('w1', sampleWallet);
        await lateRepo.deleteWallet('secondary_w');

        late.createCompleter.completeError(firebaseError('permission-denied'));
        late.upsertCompleter.completeError(firebaseError('unavailable'));
        late.deleteCompleter.completeError(StateError('late'));

        await Future<void>.delayed(const Duration(milliseconds: 100));
      }, (error, stack) => uncaught.add(error));

      expect(uncaught, isEmpty);
    });

    test('a synchronous throw from data source create is rethrown as same typed exception', () async {
      final original = WalletException(WalletErrorType.notAuthenticated);
      dataSource.syncCreateError = original;
      await expectLater(repo.addWallet(sampleWallet), throwsA(same(original)));
    });
  });
}
