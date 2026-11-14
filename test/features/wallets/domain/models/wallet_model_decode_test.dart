import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing type decodes to cash', () {
    final json = {
      'id': '1',
      'name': 'Cash',
      'icon': 'payments',
      'isDefault': false,
    };
    final model = WalletModel.fromJson(json);
    expect(model.type, WalletType.cash);
  });

  test('unknown type decodes to cash', () {
    final json = {
      'id': '1',
      'name': 'Cash',
      'icon': 'payments',
      'isDefault': false,
      'type': 'crypto',
    };
    final model = WalletModel.fromJson(json);
    expect(model.type, WalletType.cash);
  });

  test('eWallet round trips correctly', () {
    const model = WalletModel(
      id: '1',
      name: 'PayPal',
      icon: 'paypal',
      isDefault: false,
      type: WalletType.eWallet,
    );
    final json = model.toJson();
    expect(json['type'], 'eWallet');
    final restored = WalletModel.fromJson(json);
    expect(restored.type, WalletType.eWallet);
  });
}
