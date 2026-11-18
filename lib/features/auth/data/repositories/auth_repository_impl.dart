import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/error/auth_exception.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

class AuthRepository implements AuthRepositoryInterface {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw AppAuthException(AuthErrorType.databaseError, message: e.message);
    } catch (e) {
      throw AppAuthException(AuthErrorType.unknown, message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: '668771022671-ji2qg0jf204t0f5agoigh07b39cgm60d.apps.googleusercontent.com',
      );

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.additionalUserInfo?.isNewUser ?? true) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': userCredential.user!.displayName ?? 'FinTrack User',
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': userCredential.user!.photoURL,
          'uid': userCredential.user!.uid,
          'baseCurrency': 'USD',
        });
      }

      return _mapUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        throw AppAuthException(AuthErrorType.networkRequestFailed);
      }
      throw AppAuthException(
        AuthErrorType.unknown,
        message: '${e.code}: ${e.message}',
      );
    } catch (e) {
      if (e.toString().contains('canceled') ||
          e.toString().contains('Canceled')) {
        throw AppAuthException(AuthErrorType.googleSignInCanceled);
      }

      if (e is AppAuthException) rethrow;
      throw AppAuthException(AuthErrorType.unknown, message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userCredential.user!.uid,
        });
      }

      return _mapUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw AppAuthException(AuthErrorType.databaseError, message: e.message);
    } catch (e) {
      throw AppAuthException(AuthErrorType.unknown, message: e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      throw AppAuthException(AuthErrorType.databaseError, message: e.message);
    } catch (e) {
      throw AppAuthException(AuthErrorType.unknown, message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google sign-out failures
    }
    // Debt: Firebase clearPersistence/terminate should ideally be called, but omitted per instructions.
    return _auth.signOut();
  }

  @override
  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  /// Maps a Firebase [User] (may be null when signed out) onto the pure
  /// domain [UserModel]. No SDK types cross the repository boundary.
  UserModel _mapUser(User? user) {
    if (user == null) {
      throw AppAuthException(AuthErrorType.sessionExpired);
    }
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
      photoUrl: user.photoURL,
    );
  }

  AppAuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppAuthException(AuthErrorType.userNotFound);
      case 'wrong-password':
        return AppAuthException(AuthErrorType.wrongPassword);
      case 'invalid-credential':
        return AppAuthException(AuthErrorType.invalidCredential);
      case 'email-already-in-use':
        return AppAuthException(AuthErrorType.emailAlreadyInUse);
      case 'invalid-email':
        return AppAuthException(AuthErrorType.invalidEmail);
      case 'weak-password':
        return AppAuthException(AuthErrorType.weakPassword);
      case 'user-disabled':
        return AppAuthException(AuthErrorType.userDisabled);
      case 'too-many-requests':
        return AppAuthException(AuthErrorType.tooManyRequests);
      case 'network-request-failed':
        return AppAuthException(AuthErrorType.networkRequestFailed);
      default:
        return AppAuthException(AuthErrorType.unknown, message: e.message);
    }
  }
}
