import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/error/currency_write_exception.dart';
import '../../../../core/utils/acknowledged_write.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_remote_datasource.dart';

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return FirestoreCurrencyRepository(
    ref.watch(currencyRemoteDataSourceProvider),
  );
});

/// Translates any error into a [CurrencyException].
///
/// An already typed exception is returned as-is (never re-wrapped).
/// `FirebaseException.message` is kept for debugging only; it is never shown
/// to users.
CurrencyException translateCurrencyError(Object error) {
  if (error is CurrencyException) return error;
  if (error is FirebaseException) {
    if (kDebugMode) {
      debugPrint('[CurrencyRepository] code=${error.code}');
    }
    return CurrencyException(_typeForCode(error.code), message: error.message);
  }
  return CurrencyException(
    CurrencyErrorType.unknown,
    message: error.toString(),
  );
}

CurrencyErrorType _typeForCode(String code) {
  switch (code) {
    case 'permission-denied':
      return CurrencyErrorType.permissionDenied;
    case 'unavailable':
    case 'deadline-exceeded':
      return CurrencyErrorType.networkError;
    case 'unauthenticated':
      return CurrencyErrorType.notAuthenticated;
    default:
      return CurrencyErrorType.unknown;
  }
}

/// Implements [CurrencyRepository] on top of [CurrencyRemoteDataSource].
///
/// Owns exception translation; Firestore specifics (DocRefs) live in the
/// data source.
class FirestoreCurrencyRepository implements CurrencyRepository {
  FirestoreCurrencyRepository(
    this._dataSource, {
    this.writeTimeout = const Duration(seconds: 3),
  });

  final CurrencyRemoteDataSource _dataSource;
  final Duration writeTimeout;

  Future<void> _awaitWrite(Future<void> Function() write) {
    return awaitWriteAck(
      write,
      timeout: writeTimeout,
      translateError: translateCurrencyError,
      logTag: 'CurrencyRepository',
    );
  }

  @override
  Stream<String> watchBaseCurrency() {
    try {
      return _dataSource.watchBaseCurrency().transform(
        StreamTransformer<String, String>.fromHandlers(
          handleError: (error, stackTrace, sink) {
            sink.addError(translateCurrencyError(error), stackTrace);
          },
        ),
      );
    } catch (e, st) {
      Error.throwWithStackTrace(translateCurrencyError(e), st);
    }
  }

  @override
  Future<void> setBaseCurrency(String currency) async {
    try {
      await _awaitWrite(() => _dataSource.setBaseCurrency(currency));
    } catch (e, st) {
      Error.throwWithStackTrace(translateCurrencyError(e), st);
    }
  }
}

