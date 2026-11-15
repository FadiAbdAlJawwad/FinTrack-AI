import 'package:local_auth/local_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  final locale = ref.watch(localeProvider);
  return BiometricService(
    localizedReason: lookupAppLocalizations(locale).biometricReason,
  );
});

class BiometricService {
  final String localizedReason;
  final LocalAuthentication _auth = LocalAuthentication();

  BiometricService({required this.localizedReason});

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
    }
  }
}
