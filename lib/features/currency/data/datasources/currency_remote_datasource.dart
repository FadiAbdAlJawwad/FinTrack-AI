import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';

/// Owns all direct Firestore reads/writes for the user's base currency.
final currencyRemoteDataSourceProvider = Provider<CurrencyRemoteDataSource>((
  ref,
) {
  return CurrencyRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

class CurrencyRemoteDataSource {
  CurrencyRemoteDataSource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to perform currency operations.');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_userId);

  Stream<String> watchBaseCurrency() {
    if (kDebugMode) {
      debugPrint(
        '[CurrencyDataSource] watchBaseCurrency: attaching listener',
      );
    }
    final baseCurrency = _userDoc.snapshots().map(
      (snap) => (snap.data()?['baseCurrency'] as String?) ?? 'USD',
    );
    // Listener failures (e.g. PERMISSION_DENIED) arrive asynchronously on the
    // stream, so they are logged here and re-emitted to keep the error visible
    // to Riverpod.
    return baseCurrency.transform(
      StreamTransformer<String, String>.fromHandlers(
        handleError: (error, stackTrace, sink) {
          if (kDebugMode) {
            debugPrint(
              '[CurrencyDataSource] watchBaseCurrency: listener error '
              'code=${error is FirebaseException ? error.code : 'n/a'}',
            );
          }
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  Future<void> setBaseCurrency(String currency) {
    if (kDebugMode) {
      debugPrint('[CurrencyDataSource] setBaseCurrency: writing baseCurrency');
    }
    return _userDoc.set({'baseCurrency': currency}, SetOptions(merge: true));
  }
}
