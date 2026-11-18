import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Unified DI registers for Firebase singletons.
///
/// Providers are overridable in tests (`overrideWithValue(fake)`) and
/// consumed by data-layer constructors instead of raw `.instance` reads
/// scattered across the codebase.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Emits the signed-in user on every auth state change.
///
/// Watched by providers whose value must recompute when the session changes
/// (e.g. current-user display state, redirect guards).
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
