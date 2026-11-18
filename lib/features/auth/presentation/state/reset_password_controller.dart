import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';

final resetPasswordControllerProvider =
    AutoDisposeAsyncNotifierProvider<ResetPasswordController, void>(
      ResetPasswordController.new,
    );

class ResetPasswordController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).resetPassword(email),
    );
  }
}
