import '../models/user_model.dart';

/// Pure-domain contract for authentication.
///
/// Deliberately free of any Firebase/SDK types: implementations are
/// responsible for mapping SDK results onto [UserModel].
abstract class AuthRepositoryInterface {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signUp(String fullName, String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signOut();

  /// The authenticated user, or `null` when signed out.
  ///
  /// Maps a live SDK session onto a domain entity so that neither
  /// presentation nor controllers need to import Firebase.
  UserModel? get currentUser;
}
