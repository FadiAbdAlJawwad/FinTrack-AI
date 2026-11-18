import 'package:fin_track_ai/core/routing/app_lock_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin_track_ai/core/constant/shared_prefs_keys.dart';
import 'package:fin_track_ai/core/providers/shared_prefs_provider.dart';
import 'package:fin_track_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:fin_track_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';

class MockAuthRepository extends Fake implements AuthRepositoryInterface {
  AppLockNotifier? appLockNotifierToVerify;
  bool wasLockedDuringSignOut = false;
  bool shouldThrowOnSignOut = false;

  @override
  UserModel? get currentUser =>
      const UserModel(uid: '123', email: 'test@test.com', fullName: 'Test');

  @override
  Future<void> signOut() async {
    if (shouldThrowOnSignOut) throw Exception('Sign out failed');
    if (appLockNotifierToVerify != null) {
      wasLockedDuringSignOut = appLockNotifierToVerify!.isLocked;
    }
  }
}

void main() {
  late MockAuthRepository mockRepo;
  late SharedPreferences prefs;
  late ProviderContainer container;
  late AppLockNotifier appLockNotifier;

  setUp(() async {
    mockRepo = MockAuthRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    appLockNotifier = AppLockNotifier(initialLocked: true);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        sharedPrefsProvider.overrideWithValue(prefs),
        appLockNotifierProvider.overrideWithValue(appLockNotifier),
      ],
    );
  });

  test('12. signOut unlocks and clears the biometric preference', () async {
    mockRepo.appLockNotifierToVerify = appLockNotifier;
    await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);
    expect(appLockNotifier.isLocked, isTrue);

    await container.read(authControllerProvider.notifier).signOut();

    expect(
      mockRepo.wasLockedDuringSignOut,
      isTrue,
      reason: 'Lock should still be locked when repo sign out starts',
    );
    expect(appLockNotifier.isLocked, isFalse);
    expect(prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey), isFalse);
  });

  test('13. signOut throws -> lock stays locked and biometric preference is unchanged', () async {
    mockRepo.shouldThrowOnSignOut = true;
    await prefs.setBool(SharedPrefsKeys.isBiometricEnabledKey, true);
    expect(appLockNotifier.isLocked, isTrue);

    await expectLater(
      () => container.read(authControllerProvider.notifier).signOut(),
      throwsException,
    );

    expect(appLockNotifier.isLocked, isTrue);
    expect(prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey), isTrue);
  });
}
