import 'dart:async';

import 'package:fin_track_ai/core/error/transaction_exception.dart';
import 'package:fin_track_ai/features/transactions/data/repositories/firestore_transaction_repository.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';

class ThrowingRepo implements TransactionRepository {
  ThrowingRepo(this.error);

  final TransactionException error;
  Object? buildError;
  final StreamController<List<TransactionModel>> controller =
      StreamController<List<TransactionModel>>();

  @override
  Future<void> addTransaction(TransactionModel transaction) async =>
      throw error;

  @override
  Future<void> updateTransaction(TransactionModel transaction) async =>
      throw error;

  @override
  Future<void> deleteTransaction(String id) async => throw error;

  @override
  Stream<List<TransactionModel>> getTransactionsStream() {
    if (buildError != null) throw buildError!;
    return controller.stream;
  }
}

TransactionModel tx() => TransactionModel(
  id: 't1',
  amountMinor: 1000,
  currency: AppCurrency.usd,
  type: TransactionType.expense,
  category: TransactionCategory.food,
  title: 'Lunch',
  date: DateTime(2024, 5, 15),
  walletId: 'w',
);

void main() {
  late TransactionException error;
  late ThrowingRepo repo;
  late ProviderContainer container;

  setUp(() {
    error = TransactionException(TransactionErrorType.permissionDenied);
    repo = ThrowingRepo(error);
    container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repo),
        currentUserProvider.overrideWithValue(
          UserModel(uid: 'u', email: '', fullName: ''),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(() => unawaited(repo.controller.close()));
    container.listen(transactionControllerProvider, (_, _) {});
  });

  group('TransactionController', () {
    test('13. yields empty state without calling repository when currentUserProvider is null', () async {
      var callCount = 0;
      final verifyRepo = ThrowingRepo(error);
      verifyRepo.controller.onListen = () => callCount++;
      final c = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(verifyRepo),
          currentUserProvider.overrideWithValue(null),
        ],
      );
      addTearDown(c.dispose);
      addTearDown(() => unawaited(verifyRepo.controller.close()));
      c.listen(transactionControllerProvider, (_, _) {});

      final state = await c.read(transactionControllerProvider.future);
      expect(state, isEmpty);
      expect(callCount, 0); // Repository stream was not accessed
    });

    test('addTransaction propagates the typed exception unchanged', () {
      expect(
        container
            .read(transactionControllerProvider.notifier)
            .addTransaction(tx()),
        throwsA(same(error)),
      );
    });

    test('updateTransaction propagates the typed exception unchanged', () {
      expect(
        container
            .read(transactionControllerProvider.notifier)
            .updateTransaction(tx()),
        throwsA(same(error)),
      );
    });

    test('deleteTransaction propagates the typed exception unchanged', () {
      expect(
        container
            .read(transactionControllerProvider.notifier)
            .deleteTransaction('t1'),
        throwsA(same(error)),
      );
    });

    test('a stream error surfaces as AsyncError', () async {
      repo.controller.addError(error);
      await Future<void>.delayed(Duration.zero);
      final state = container.read(transactionControllerProvider);
      expect(state, isA<AsyncError<List<TransactionModel>>>());
      expect(state.error, same(error));
    });

    test('a synchronous build failure surfaces as AsyncError', () {
      final failing = ThrowingRepo(error)..buildError = error;
      final c = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(failing),
          currentUserProvider.overrideWithValue(
            UserModel(uid: 'u', email: '', fullName: ''),
          ),
        ],
      );
      addTearDown(c.dispose);
      addTearDown(() => unawaited(failing.controller.close()));
      c.listen(transactionControllerProvider, (_, _) {});
      final state = c.read(transactionControllerProvider);
      expect(state, isA<AsyncError<List<TransactionModel>>>());
      expect(state.error, same(error));
    });
  });
}
