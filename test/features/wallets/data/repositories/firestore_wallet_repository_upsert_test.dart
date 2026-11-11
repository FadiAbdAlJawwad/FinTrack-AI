import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin_track_ai/core/error/wallet_exception.dart';
import 'package:fin_track_ai/features/wallets/data/datasources/wallet_remote_datasource.dart';
import 'package:fin_track_ai/features/wallets/data/repositories/firestore_wallet_repository.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingWalletDataSource extends Fake implements WalletRemoteDataSource {
  final upserts = <(String, Map<String, dynamic>)>[];
  Object? error;

  @override
  Future<void> upsert(String id, Map<String, dynamic> data) async {
    if (error != null) throw error!;
    upserts.add((id, data));
  }
}

void main() {
  const wallet = WalletModel(name: 'Cash', icon: 'payments', isDefault: true);

  test('upsertWallet passes the id and the wallet document fields', () async {
    final dataSource = RecordingWalletDataSource();
    await FirestoreWalletRepository(dataSource).upsertWallet('cash', wallet);

    final (id, data) = dataSource.upserts.single;
    expect(id, 'cash');
    expect(data['name'], 'Cash');
    expect(data['icon'], 'payments');
    expect(data['isDefault'], isTrue);
    expect(data['type'], 'cash');
    expect(data.keys.toSet(), {'id', 'name', 'icon', 'isDefault', 'type'});
  });

  test('upsertWallet maps Firebase errors to WalletException', () async {
    final dataSource = RecordingWalletDataSource()
      ..error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );

    await expectLater(
      FirestoreWalletRepository(dataSource).upsertWallet('cash', wallet),
      throwsA(
        isA<WalletException>().having(
          (e) => e.type,
          'type',
          WalletErrorType.networkError,
        ),
      ),
    );
  });
}
