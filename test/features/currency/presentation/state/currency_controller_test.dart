import 'dart:async';

import 'package:fin_track_ai/features/currency/data/repositories/firestore_currency_repository.dart';
import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:fin_track_ai/features/currency/domain/repositories/currency_repository.dart';
import 'package:fin_track_ai/features/currency/presentation/state/currency_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fin_track_ai/features/auth/presentation/state/auth_controller.dart';
import 'package:fin_track_ai/features/auth/domain/models/user_model.dart';

class RecordingCurrencyRepository implements CurrencyRepository {
  RecordingCurrencyRepository(this.base);

  final String base;
  final writes = <String>[];

  @override
  Stream<String> watchBaseCurrency() => Stream.value(base);

  @override
  Future<void> setBaseCurrency(String currency) async => writes.add(currency);
}

/// Any use of the rate service fails the test: changing currency must not
/// load or read rates any more.
class UntouchableRateService extends Fake implements ExchangeRateService {}

void main() {
  late RecordingCurrencyRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = RecordingCurrencyRepository('USD');
    container = ProviderContainer(
      overrides: [
        currencyRepositoryProvider.overrideWithValue(repo),
        exchangeRateServiceProvider.overrideWithValue(UntouchableRateService()),
        currentUserProvider.overrideWithValue(
          UserModel(uid: 'u', email: '', fullName: ''),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(currencyControllerProvider, (_, _) {});
    await container.read(currencyControllerProvider.future);
  });

  test('13. yields default state without calling repository when currentUserProvider is null', () async {
    final verifyRepo = RecordingCurrencyRepository('EUR');

    final c = ProviderContainer(
      overrides: [
        currencyRepositoryProvider.overrideWithValue(verifyRepo),
        exchangeRateServiceProvider.overrideWithValue(UntouchableRateService()),
        currentUserProvider.overrideWithValue(null),
      ],
    );
    addTearDown(c.dispose);
    c.listen(currencyControllerProvider, (_, _) {});

    final state = await c.read(currencyControllerProvider.future);
    expect(
      state,
      'USD',
    ); // Default value from controller, not from verifyRepo's 'EUR'
  });

  test('changeCurrency writes only the base currency, once', () async {
    await container
        .read(currencyControllerProvider.notifier)
        .changeCurrency('JOD');
    expect(repo.writes, ['JOD']);
  });

  test('changeCurrency to the current value writes nothing', () async {
    await container
        .read(currencyControllerProvider.notifier)
        .changeCurrency('USD');
    expect(repo.writes, isEmpty);
  });
}
