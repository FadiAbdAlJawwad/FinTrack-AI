import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../repositories/firestore_wallet_repository.dart';

final walletMigrationProvider = Provider<WalletMigrationService>((ref) {
  return WalletMigrationService(
    repository: ref.watch(walletRepositoryProvider),
  );
});

/// Runs [WalletMigrationService.runIfNeeded] at most once per uid per app
/// process.
///
/// Deliberately not autoDispose: the result must survive controller dispose
/// and rebuild. Consumers must `ref.read(provider(uid).future)` and, on
/// failure, `ref.invalidate(provider(uid))` so the next rebuild retries.
final walletMigrationRunProvider = FutureProvider.family<void, String>((
  ref,
  uid,
) {
  return ref.read(walletMigrationProvider).runIfNeeded();
});

/// Seeds default wallets on first launch when no default wallet exists.
///
/// Stateless invariant: if any wallet has `isDefault == true`, seeding is
/// considered complete and deleted wallets are not re-seeded.
/// Idempotent: every default wallet has a deterministic document id. Talks
/// only to [WalletRepository]; no Firestore or Auth types.
class WalletMigrationService {
  WalletMigrationService({required this.repository});

  final WalletRepository repository;

  static const String cashWalletId = 'cash';

  static const WalletModel _cashWallet = WalletModel(
    name: 'Cash',
    icon: 'payments',
    isDefault: true,
    type: WalletType.cash,
  );

  static const Map<String, WalletModel> _defaultSecondaryWallets = {
    'bank': WalletModel(
      name: 'Bank Account',
      icon: 'account_balance',
      isDefault: false,
      type: WalletType.bank,
    ),
    'paypal': WalletModel(
      name: 'PayPal',
      icon: 'account_balance_wallet',
      isDefault: false,
      type: WalletType.eWallet,
    ),
    'other': WalletModel(name: 'Other', icon: 'more_horiz', isDefault: false, type: WalletType.cash),
  };

  /// Wraps [_seed] so Firebase errors surface as typed wallet exceptions.
  Future<void> runIfNeeded() async {
    try {
      await _seed();
    } catch (e, st) {
      Error.throwWithStackTrace(translateWalletError(e), st);
    }
  }

  Future<void> _seed() async {
    final wallets = await repository.getWalletsStream().first;

    if (wallets.any((w) => w.isDefault)) {
      return;
    }

    await _upsertSecondaryWallets();
    await repository.upsertWallet(cashWalletId, _cashWallet);
  }

  Future<void> _upsertSecondaryWallets() async {
    for (final MapEntry(key: id, value: wallet)
        in _defaultSecondaryWallets.entries) {
      await repository.upsertWallet(id, wallet);
    }
  }
}
