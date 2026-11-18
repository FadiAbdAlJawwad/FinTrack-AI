import 'package:fin_track_ai/core/constant/shared_prefs_keys.dart';
import 'package:fin_track_ai/core/providers/shared_prefs_provider.dart';
import 'package:fin_track_ai/core/services/biometric_service.dart';
import 'package:fin_track_ai/features/settings/presentation/state/biometric_setting_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

class FakeBiometricService extends Fake implements BiometricService {
  bool shouldAuthenticate = true;
  bool shouldThrow = false;
  int authenticateCalls = 0;
  Completer<bool>? authenticateCompleter;

  @override
  Future<bool> authenticate() async {
    authenticateCalls++;
    if (authenticateCompleter != null) {
      return authenticateCompleter!.future;
    }
    if (shouldThrow) {
      throw Exception('Biometric failure');
    }
    return shouldAuthenticate;
  }
}

void main() {
  late SharedPreferences prefs;
  late FakeBiometricService fakeBiometric;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    fakeBiometric = FakeBiometricService();
    container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        biometricServiceProvider.overrideWithValue(fakeBiometric),
      ],
    );
    addTearDown(container.dispose);
  });

  test('6. Biometric controller: enabling with authenticate()=true stores true and returns true', () async {
    fakeBiometric.shouldAuthenticate = true;
    final controller = container.read(biometricSettingProvider.notifier);

    final result = await controller.setEnabled(true);

    expect(result, isTrue);
    expect(container.read(biometricSettingProvider), isTrue);
    expect(prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey), isTrue);
  });

  test('7. Biometric controller: enabling with authenticate()=false stores nothing as true, returns false', () async {
    fakeBiometric.shouldAuthenticate = false;
    final controller = container.read(biometricSettingProvider.notifier);

    final result = await controller.setEnabled(true);

    expect(result, isFalse);
    expect(container.read(biometricSettingProvider), isFalse);
    expect(prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey), isFalse);
  });

  test('8. Biometric controller: authenticate() throwing is treated as not enabled; disabling never calls authenticate()', () async {
    fakeBiometric.shouldThrow = true;
    final controller = container.read(biometricSettingProvider.notifier);

    final resultEnable = await controller.setEnabled(true);

    expect(resultEnable, isFalse);
    expect(container.read(biometricSettingProvider), isFalse);
    expect(prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey), isFalse);

    fakeBiometric.authenticateCalls = 0;
    final resultDisable = await controller.setEnabled(false);

    expect(resultDisable, isFalse);
    expect(container.read(biometricSettingProvider), isFalse);
    expect(fakeBiometric.authenticateCalls, equals(0));
    expect(prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey), isFalse);
  });

  test(
    '14. disposed before await completes does not throw or write state',
    () async {
      final completer = Completer<bool>();
      fakeBiometric.authenticateCompleter = completer;

      final controller = container.read(biometricSettingProvider.notifier);
      final future = controller.setEnabled(true);

      container.dispose();

      completer.complete(true);
      final result = await future;

      expect(result, isTrue);
      expect(
        controller.state,
        isFalse,
        reason: 'State should not be updated on disposed controller',
      );
      expect(
        prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey),
        isTrue,
      ); // prefs is a side effect that occurs before state set
    },
  );
}
