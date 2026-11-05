import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin_track_ai/core/error/currency_write_exception.dart';
import 'package:fin_track_ai/features/currency/data/datasources/currency_remote_datasource.dart';
import 'package:fin_track_ai/features/currency/data/repositories/firestore_currency_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledCurrencyDataSource implements CurrencyRemoteDataSource {
  Completer<void> setBaseCurrencyCompleter = Completer<void>();
  StreamController<String> watchBaseCurrencyController =
      StreamController<String>();

  Object? syncSetBaseCurrencyError;

  @override
  Future<void> setBaseCurrency(String currency) {
    if (syncSetBaseCurrencyError != null) throw syncSetBaseCurrencyError!;
    return setBaseCurrencyCompleter.future;
  }

  @override
  Stream<String> watchBaseCurrency() => watchBaseCurrencyController.stream;
}

const shortTimeout = Duration(milliseconds: 50);

FirebaseException firebaseError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  late ControlledCurrencyDataSource dataSource;
  late FirestoreCurrencyRepository repo;

  setUp(() {
    dataSource = ControlledCurrencyDataSource();
    repo = FirestoreCurrencyRepository(dataSource, writeTimeout: shortTimeout);
  });

  group('translateCurrencyError', () {
    test('maps FirebaseException codes to appropriate CurrencyErrorType', () {
      expect(
        translateCurrencyError(firebaseError('permission-denied')).type,
        CurrencyErrorType.permissionDenied,
      );
      expect(
        translateCurrencyError(firebaseError('unavailable')).type,
        CurrencyErrorType.networkError,
      );
      expect(
        translateCurrencyError(firebaseError('deadline-exceeded')).type,
        CurrencyErrorType.networkError,
      );
      expect(
        translateCurrencyError(firebaseError('unauthenticated')).type,
        CurrencyErrorType.notAuthenticated,
      );
      expect(
        translateCurrencyError(firebaseError('unknown-code')).type,
        CurrencyErrorType.unknown,
      );
    });

    test('returns existing CurrencyException as-is', () {
      final existing = CurrencyException(CurrencyErrorType.permissionDenied);
      expect(translateCurrencyError(existing), same(existing));
    });

    test('maps non-Firebase error to unknown and asserts type only', () {
      final nonFirebaseError = StateError('internal detail error');
      final result = translateCurrencyError(nonFirebaseError);
      expect(result.type, CurrencyErrorType.unknown);
    });
  });

  group('FirestoreCurrencyRepository write timeout & acknowledgement', () {
    test('setBaseCurrency completes normally when write never completes (writeTimeout 0s)', () async {
      final zeroTimeoutRepo = FirestoreCurrencyRepository(
        dataSource,
        writeTimeout: Duration.zero,
      );
      await zeroTimeoutRepo.setBaseCurrency('EUR');
    });

    test('setBaseCurrency throws CurrencyException(permissionDenied) when write throws FirebaseException(permission-denied)', () async {
      dataSource.setBaseCurrencyCompleter.completeError(
        firebaseError('permission-denied'),
      );
      await expectLater(
        repo.setBaseCurrency('EUR'),
        throwsA(
          isA<CurrencyException>().having(
            (e) => e.type,
            'type',
            CurrencyErrorType.permissionDenied,
          ),
        ),
      );
    });

    test('stream error is delivered as CurrencyException', () async {
      final stream = repo.watchBaseCurrency();
      final streamExpectation = expectLater(
        stream,
        emitsError(
          isA<CurrencyException>().having(
            (e) => e.type,
            'type',
            CurrencyErrorType.permissionDenied,
          ),
        ),
      );

      dataSource.watchBaseCurrencyController.addError(
        firebaseError('permission-denied'),
      );

      await streamExpectation;
    });

    test('an error arriving after timeout is not an uncaught error', () async {
      final uncaught = <Object>[];
      await runZonedGuarded(() async {
        final lateDs = ControlledCurrencyDataSource();
        final lateRepo = FirestoreCurrencyRepository(
          lateDs,
          writeTimeout: shortTimeout,
        );

        await lateRepo.setBaseCurrency('EUR');
        lateDs.setBaseCurrencyCompleter.completeError(
          firebaseError('permission-denied'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }, (error, stack) => uncaught.add(error));

      expect(uncaught, isEmpty);
    });

    test('a synchronous throw from datasource setBaseCurrency is rethrown as CurrencyException', () async {
      final original = CurrencyException(CurrencyErrorType.notAuthenticated);
      dataSource.syncSetBaseCurrencyError = original;
      await expectLater(repo.setBaseCurrency('EUR'), throwsA(same(original)));
    });
  });
}
