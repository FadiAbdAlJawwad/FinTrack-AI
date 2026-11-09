import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/error/transaction_exception.dart';
import '../../../../core/utils/acknowledged_write.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/transaction_limits.dart';
import '../datasources/tx_remote_datasource.dart';
import '../models/transaction_dto.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return FirestoreTransactionRepository(ref.watch(txRemoteDataSourceProvider));
});

/// Translates any error into a [TransactionException].
///
/// An already typed exception is returned as-is (never re-wrapped).
/// `FirebaseException.message` is kept for debugging only; it is never shown
/// to users.
TransactionException translateTransactionError(Object error) {
  if (error is TransactionException) return error;
  if (error is FirebaseException) {
    return TransactionException(
      _typeForCode(error.code),
      message: error.message,
    );
  }
  return TransactionException(
    TransactionErrorType.unknown,
    message: error.toString(),
  );
}

TransactionErrorType _typeForCode(String code) {
  switch (code) {
    case 'permission-denied':
      return TransactionErrorType.permissionDenied;
    case 'unavailable':
    case 'deadline-exceeded':
      return TransactionErrorType.networkError;
    case 'not-found':
      return TransactionErrorType.notFound;
    case 'unauthenticated':
      return TransactionErrorType.notAuthenticated;
    case 'invalid-argument':
    case 'failed-precondition':
      return TransactionErrorType.invalidData;
    default:
      return TransactionErrorType.unknown;
  }
}

/// Implements [TransactionRepository] on top of [TxRemoteDataSource].
///
/// Owns exception translation and domain-model mapping; Firestore specifics
/// (queries, DocReferences, ordering) live in the data source.
class FirestoreTransactionRepository implements TransactionRepository {
  FirestoreTransactionRepository(
    this._dataSource, {
    this.writeTimeout = const Duration(seconds: 3),
    this.windowMonths = transactionWindowMonths,
    this.maxDocuments = 1000,
    this.clock = DateTime.now,
  });

  final TxRemoteDataSource _dataSource;

  /// Time source for the listener window (injectable for tests).
  final DateTime Function() clock;

  /// Number of calendar months (including the current one) the listener
  /// covers. Older transactions are not streamed.
  final int windowMonths;

  /// Hard cap on streamed documents, protecting the Spark read quota.
  /// In production: expose a "truncated" flag to the UI instead of only logging.
  final int maxDocuments;

  /// First day of the month `windowMonths - 1` months before the current
  /// month, at 00:00 local time, as an ISO-8601 string.
  String get windowStartIsoDate {
    final now = clock();
    return DateTime(
      now.year,
      now.month - (windowMonths - 1),
      1,
    ).toIso8601String();
  }

  /// Upper bound for waiting on server acknowledgement of a write.
  ///
  /// Firestore applies writes to its local cache immediately, but the write
  /// Future completes only on server acknowledgement, which never happens
  /// offline. Fast failures (invalid data, auth) still surface as typed
  /// errors; a timeout means the write is queued locally and will sync.
  final Duration writeTimeout;

  Future<void> _awaitWrite(Future<void> Function() write) {
    return awaitWriteAck(
      write,
      timeout: writeTimeout,
      translateError: translateTransactionError,
      logTag: 'TransactionRepository',
    );
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _awaitWrite(
      () => _dataSource.create(TransactionDto.fromModel(transaction).toMap()),
    );
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw TransactionException(
        TransactionErrorType.invalidData,
        message: 'Transaction ID is required for updates.',
      );
    }
    final data = TransactionDto.fromModel(transaction).toMap();
    await _awaitWrite(() => _dataSource.update(id, data));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _awaitWrite(() => _dataSource.delete(id));
  }

  @override
  Stream<List<TransactionModel>> getTransactionsStream() {
    try {
      return _dataSource
          .watchAll(fromIsoDate: windowStartIsoDate, limit: maxDocuments)
          .map(_decodeCapped)
          .transform(
            StreamTransformer<
              List<TransactionModel>,
              List<TransactionModel>
            >.fromHandlers(
              handleError: (error, stackTrace, sink) {
                sink.addError(translateTransactionError(error), stackTrace);
              },
            ),
          );
    } catch (e, st) {
      Error.throwWithStackTrace(translateTransactionError(e), st);
    }
  }

  List<TransactionModel> _decodeCapped(List<Map<String, dynamic>> docs) {
    if (docs.length >= maxDocuments) {
      if (kDebugMode) {
        debugPrint(
          '[TransactionRepository] listener hit the document cap '
          '($maxDocuments); older transactions are not included',
        );
      }
    }
    return _decodeAll(docs);
  }

  /// Decodes documents one by one; a malformed document is skipped (and
  /// logged) so a single bad document never kills the stream.
  static List<TransactionModel> _decodeAll(List<Map<String, dynamic>> docs) {
    final models = <TransactionModel>[];
    for (final doc in docs) {
      try {
        models.add(TransactionDto.fromMap(doc).toModel());
      } on FormatException catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[TransactionRepository] skipped malformed transaction '
            '${doc['id'] ?? '<no id>'}: ${e.message}',
          );
        }
      }
    }
    return models;
  }
}
