import 'dart:convert';
import 'dart:io';

import 'package:fin_track_ai/core/constant/shared_prefs_keys.dart';
import 'package:fin_track_ai/core/error/currency_exception.dart';
import 'package:fin_track_ai/features/currency/data/services/exchange_rate_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  final today = formatDate(DateTime.now());
  final yesterday = formatDate(
    DateTime.now().subtract(const Duration(days: 1)),
  );

  final successResponseBody = jsonEncode([
    {'date': today, 'base': 'USD', 'quote': 'JOD', 'rate': 0.71},
    {'date': today, 'base': 'USD', 'quote': 'ILS', 'rate': 3.6},
  ]);

  group('ExchangeRateService - cache corruption resilience', () {
    test('Corrupted JSON string + date == today + fetch succeeds -> completes and persists valid rates', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: today,
        SharedPrefsKeys.exchangeRatesKey: 'invalid json{',
      });
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((request) async {
        return http.Response(successResponseBody, 200);
      });
      final service = ExchangeRateService(client, prefs);

      await service.ensureLoaded();

      expect(service.rateBetween('USD', 'JOD'), closeTo(0.71, 0.0001));
      final storedJson = prefs.getString(SharedPrefsKeys.exchangeRatesKey);
      expect(storedJson, isNotNull);
      expect(jsonDecode(storedJson!), isA<Map<String, dynamic>>());
    });

    test('Valid JSON list + date == today + fetch succeeds -> treated as corrupted cache and refreshed', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: today,
        SharedPrefsKeys.exchangeRatesKey: '[1, 2, 3]',
      });
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((request) async {
        return http.Response(successResponseBody, 200);
      });
      final service = ExchangeRateService(client, prefs);

      await service.ensureLoaded();

      expect(service.rateBetween('USD', 'JOD'), closeTo(0.71, 0.0001));
      final storedJson = prefs.getString(SharedPrefsKeys.exchangeRatesKey);
      expect(storedJson, isNotNull);
      expect(jsonDecode(storedJson!), isA<Map<String, dynamic>>());
    });

    test('JSON object with non-numeric value + date == today + fetch succeeds -> treated as corrupted cache and refreshed', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: today,
        SharedPrefsKeys.exchangeRatesKey: jsonEncode({'JOD': 'not_a_number'}),
      });
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((request) async {
        return http.Response(successResponseBody, 200);
      });
      final service = ExchangeRateService(client, prefs);

      await service.ensureLoaded();

      expect(service.rateBetween('USD', 'JOD'), closeTo(0.71, 0.0001));
      final storedJson = prefs.getString(SharedPrefsKeys.exchangeRatesKey);
      expect(storedJson, isNotNull);
      expect(jsonDecode(storedJson!), isA<Map<String, dynamic>>());
    });

    test('Corrupted cache + fetch throws SocketException -> throws NoExchangeRatesAvailableException', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: today,
        SharedPrefsKeys.exchangeRatesKey: 'corrupted{',
      });
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((request) async {
        throw const SocketException('Failed host lookup');
      });
      final service = ExchangeRateService(client, prefs);

      expect(
        () => service.ensureLoaded(),
        throwsA(isA<NoExchangeRatesAvailableException>()),
      );
    });

    test('Corrupted cache + fetch returns HTTP 500 -> throws ExchangeRateServiceException', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: today,
        SharedPrefsKeys.exchangeRatesKey: 'corrupted{',
      });
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((request) async {
        return http.Response('Server error', 500);
      });
      final service = ExchangeRateService(client, prefs);

      expect(
        () => service.ensureLoaded(),
        throwsA(isA<ExchangeRateServiceException>()),
      );
    });

    test('Valid cache with date == today -> completes without HTTP call and rateBetween works', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: today,
        SharedPrefsKeys.exchangeRatesKey: jsonEncode({'JOD': 0.71, 'ILS': 3.6}),
      });
      final prefs = await SharedPreferences.getInstance();
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        fail('HTTP call should not be made when valid cache for today exists');
      });
      final service = ExchangeRateService(client, prefs);

      await service.ensureLoaded();

      expect(service.rateBetween('USD', 'JOD'), closeTo(0.71, 0.0001));
      expect(calls, 0);
    });

    test('Valid STALE cache (yesterday date) + fetch fails -> completes using stale cache', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: yesterday,
        SharedPrefsKeys.exchangeRatesKey: jsonEncode({'JOD': 0.71, 'ILS': 3.6}),
      });
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((request) async {
        throw const SocketException('No internet');
      });
      final service = ExchangeRateService(client, prefs);

      await service.ensureLoaded();

      expect(service.rateBetween('USD', 'JOD'), closeTo(0.71, 0.0001));
    });

    test('Empty-map cache {} + date == today + fetch succeeds -> treated as no cache and refreshed', () async {
      SharedPreferences.setMockInitialValues({
        SharedPrefsKeys.exchangeRatesFetchDateKey: today,
        SharedPrefsKeys.exchangeRatesKey: '{}',
      });
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((request) async {
        return http.Response(successResponseBody, 200);
      });
      final service = ExchangeRateService(client, prefs);

      await service.ensureLoaded();

      expect(service.rateBetween('USD', 'JOD'), closeTo(0.71, 0.0001));
      final storedJson = prefs.getString(SharedPrefsKeys.exchangeRatesKey);
      expect(storedJson, isNotNull);
      expect(jsonDecode(storedJson!), isA<Map<String, dynamic>>());
    });
  });
}
