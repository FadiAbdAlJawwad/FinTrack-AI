import 'dart:async';
import 'package:fin_track_ai/features/wallets/data/services/wallet_migration_service.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWalletRepository implements WalletRepository {
  final Map<String, WalletModel> _wallets = {};

  @override
  Stream<List<WalletModel>> getWalletsStream() {
    return Stream.value(_wallets.values.toList());
  }

  @override
  Future<String> addWallet(WalletModel wallet) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _wallets[id] = wallet;
    return id;
  }

  @override
  Future<void> upsertWallet(String id, WalletModel wallet) async {
    _wallets[id] = wallet;
  }

  @override
  Future<void> deleteWallet(String id) async {
    _wallets.remove(id);
  }
}

void main() {
  test('seeds wallets with correct types', () async {
    final repository = FakeWalletRepository();
    final service = WalletMigrationService(repository: repository);
    await service.runIfNeeded();

    final bank = repository._wallets['bank'];
    expect(bank?.type, WalletType.bank);

    final paypal = repository._wallets['paypal'];
    expect(paypal?.type, WalletType.eWallet);

    final other = repository._wallets['other'];
    expect(other?.type, WalletType.cash);
  });
}
