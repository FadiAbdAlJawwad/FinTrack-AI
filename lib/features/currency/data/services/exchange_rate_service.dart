import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constant/shared_prefs_keys.dart';
import '../../../../core/error/currency_exception.dart';
import '../../../../core/providers/shared_prefs_provider.dart';

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService(http.Client(), ref.watch(sharedPrefsProvider));
});

/// Runs once at app start (and on retry) to make sure today's exchange
/// rates are available before the app is usable. See [ExchangeRateService].
final exchangeRatesBootstrapProvider = FutureProvider<void>((ref) {
  return ref.watch(exchangeRateServiceProvider).ensureLoaded();
});

/// Fetches USD-based exchange rates from Frankfurter v2 once a day and
/// caches them in [SharedPreferences], computing cross-rates client-side.
///
/// Uses api.frankfurter.dev/v2 specifically — the older v1/frankfurter.app
/// API does not support JOD.
class ExchangeRateService {
  ExchangeRateService(this._client, this._prefs);

  final http.Client _client;
  final SharedPreferences _prefs;

  static const String baseCurrency = 'USD';

  Map<String, double>? _cachedRates;
  String? _cachedDate;

  /// Loads today's rates, preferring cache, then a live fetch, then a stale
  /// cache as a last resort. Throws [NoExchangeRatesAvailableException] only
  /// when neither a live fetch nor any cache is available.
  Future<void> ensureLoaded() async {
    final today = _todayString();
    if (_cachedRates != null && _cachedDate == today) return;

    final storedDate = _prefs.getString(
      SharedPrefsKeys.exchangeRatesFetchDateKey,
    );
    if (storedDate == today) {
      final stored = _readStoredRates();
      if (stored != null) {
        _cachedRates = stored;
        _cachedDate = today;
        return;
      }
    }

    try {
      final fetched = await _fetchLatest();
      await _persist(fetched, today);
      _cachedRates = fetched;
      _cachedDate = today;
    } on Object catch (e) {
      // Classify the raw exception so the gate screen shows the correct
      // icon/message in the no-cache path (wifi_off vs cloud_off).
      final typed = switch (e) {
        ExchangeRateServiceException() => e, // already typed, keep as-is
        SocketException() ||
        TimeoutException() => NoExchangeRatesAvailableException(),
        _ => ExchangeRateServiceException(e.toString()),
      };

      // Regardless of failure type, prefer a stale cache over blocking the
      // user — only escalate to the gate screen when no cache exists at all.
      final stored = _readStoredRates();
      if (stored != null) {
        _cachedRates = stored;
        _cachedDate = storedDate;
        debugPrint(
          '[ExchangeRateService] fetch failed, using stale cache. '
          'Reason: $e',
        );
        return;
      }

      // No cache — surface the typed exception to the gate screen.
      throw typed;
    }
  }

  /// Rate to multiply a [from]-denominated amount by to express it in [to].
  double rateBetween(String from, String to) {
    if (from == to) return 1.0;
    final rates = _cachedRates;
    if (rates == null) {
      throw NoExchangeRatesAvailableException();
    }
    final fromRate = from == baseCurrency ? 1.0 : rates[from];
    final toRate = to == baseCurrency ? 1.0 : rates[to];
    if (fromRate == null || toRate == null) {
      throw Exception('Unsupported currency conversion: $from -> $to');
    }
    return toRate / fromRate;
  }

  Future<Map<String, double>> _fetchLatest() async {
    // The v2 API endpoint for latest rates is /v2/rates (not /v2/latest).
    // It returns a JSON array: [{date, base, quote, rate}, ...]
    final uri = Uri.parse(
      'https://api.frankfurter.dev/v2/rates?base=$baseCurrency',
    );
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Exchange rate request failed: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return {
      for (final entry in list)
        (entry as Map<String, dynamic>)['quote'] as String:
            ((entry)['rate'] as num).toDouble(),
    };
  }

  Map<String, double>? _readStoredRates() {
    try {
      final raw = _prefs.getString(SharedPrefsKeys.exchangeRatesKey);
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded.isEmpty) return null;
      return decoded.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } on Object catch (e) {
      debugPrint('[ExchangeRateService] corrupted rates cache ignored: $e');
      return null;
    }
  }

  Future<void> _persist(Map<String, double> rates, String date) async {
    await _prefs.setString(SharedPrefsKeys.exchangeRatesKey, jsonEncode(rates));
    await _prefs.setString(SharedPrefsKeys.exchangeRatesFetchDateKey, date);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
