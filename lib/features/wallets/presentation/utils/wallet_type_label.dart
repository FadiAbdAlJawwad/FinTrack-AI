import '../../../../l10n/app_localizations.dart';
import '../../domain/models/wallet_model.dart';

String walletTypeLabel(AppLocalizations loc, WalletType type) {
  switch (type) {
    case WalletType.cash:
      return loc.defaultWalletName;
    case WalletType.bank:
      return loc.walletNameBank;
    case WalletType.eWallet:
      return loc.walletTypeEWallet;
  }
}
