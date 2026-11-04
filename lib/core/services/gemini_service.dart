import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../constant/app_env.dart';
import '../error/ai_parsing_exception.dart';
import '../providers/firebase_providers.dart';

final aiFeatureAvailableProvider = Provider<bool>((ref) {
  return AppEnv.isAiConfigured;
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return GeminiService(
    proxyUrl: AppEnv.appsScriptProxyUrl,
    sharedSecret: AppEnv.appSharedSecret,
    idTokenProvider: () async =>
        ref.read(firebaseAuthProvider).currentUser?.getIdToken(),
    client: client,
  );
});

String _truncate120(String? msg) {
  if (msg == null || msg.isEmpty) return '';
  final singleLine = msg.replaceAll('\n', ' ');
  return singleLine.length > 120 ? singleLine.substring(0, 120) : singleLine;
}

class GeminiService {
  final String proxyUrl;
  final String sharedSecret;
  final Future<String?> Function() idTokenProvider;
  final http.Client _client;

  GeminiService({
    required this.proxyUrl,
    required this.sharedSecret,
    required this.idTokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> parseTransactionText(String input) async {
    try {
      final configured =
          AppEnv.isAiConfigValid(proxyUrl: proxyUrl, secret: sharedSecret);
      if (kDebugMode) {
        debugPrint('[Gemini] stage=config configured=$configured');
      }
      if (!configured) {
        throw AiParsingException(AiParsingErrorType.notConfigured);
      }

      final idToken = await idTokenProvider();
      final tokenPresent = idToken != null && idToken.isNotEmpty;
      if (kDebugMode) {
        debugPrint('[Gemini] stage=token present=$tokenPresent');
      }
      if (!tokenPresent) {
        throw AiParsingException(AiParsingErrorType.unauthorized);
      }

      // The secret and the ID token travel in the body only; the URL carries
      // no query string, so neither can end up in URL logs.
      final postUri = Uri.parse(proxyUrl);
      final response = await _client
          .post(
            postUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'input': input,
              'secret': sharedSecret,
              'idToken': idToken,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint(
          '[Gemini] stage=post host=${postUri.host} status=${response.statusCode}',
        );
      }

      var finalStatusCode = response.statusCode;
      var finalResponseBody = response.body;

      if (response.statusCode >= 300 && response.statusCode < 400) {
        final location =
            response.headers['location'] ?? response.headers['Location'];
        if (location == null || location.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[Gemini] stage=redirect followed=false status=${response.statusCode}',
            );
          }
          throw AiParsingException(
            AiParsingErrorType.unknown,
            message: 'Redirect with no location header',
          );
        }

        final followUpResponse = await _client
            .get(Uri.parse(location))
            .timeout(const Duration(seconds: 20));

        finalStatusCode = followUpResponse.statusCode;
        finalResponseBody = followUpResponse.body;

        if (kDebugMode) {
          debugPrint(
            '[Gemini] stage=redirect followed=true status=$finalStatusCode',
          );
        }
      }

      switch (finalStatusCode) {
        case 200:
          try {
            final decoded = jsonDecode(finalResponseBody);
            if (decoded is Map<String, dynamic>) {
              final errorField = decoded.containsKey('error')
                  ? decoded['error'].toString()
                  : 'none';
              if (kDebugMode) {
                debugPrint('[Gemini] stage=body error=$errorField');
              }

              if (decoded.containsKey('error')) {
                final errorMsg = decoded['error'].toString();
                switch (errorMsg) {
                  case 'unauthorized':
                    throw AiParsingException(AiParsingErrorType.unauthorized);
                  case 'missing or invalid input':
                    throw AiParsingException(AiParsingErrorType.invalidInput);
                  case 'schema validation failed':
                    throw AiParsingException(
                      AiParsingErrorType.schemaValidationFailed,
                    );
                  case 'gemini request failed':
                    throw AiParsingException(
                      AiParsingErrorType.serviceUnavailable,
                    );
                  case 'rate limited':
                    throw AiParsingException(
                      AiParsingErrorType.serviceUnavailable,
                    );
                  default:
                    throw AiParsingException(
                      AiParsingErrorType.unknown,
                      message: errorMsg,
                    );
                }
              }
              return decoded;
            }
            throw AiParsingException(
              AiParsingErrorType.schemaValidationFailed,
              message: 'Response is not a valid JSON object',
            );
          } on FormatException catch (e) {
            throw AiParsingException(
              AiParsingErrorType.schemaValidationFailed,
              message: e.message,
            );
          }
        case 400:
          throw AiParsingException(AiParsingErrorType.invalidInput);
        case 401:
          throw AiParsingException(AiParsingErrorType.unauthorized);
        case 422:
          throw AiParsingException(AiParsingErrorType.schemaValidationFailed);
        case 502:
          throw AiParsingException(AiParsingErrorType.serviceUnavailable);
        default:
          throw AiParsingException(
            AiParsingErrorType.unknown,
            message: finalResponseBody,
          );
      }
    } on AiParsingException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[Gemini] failed type=${e.type} exception=${e.runtimeType} message=${_truncate120(e.message)}',
        );
      }
      rethrow;
    } on TimeoutException catch (e) {
      const type = AiParsingErrorType.networkError;
      const msg = 'Request timed out after 20s';
      if (kDebugMode) {
        debugPrint(
          '[Gemini] failed type=$type exception=${e.runtimeType} message=${_truncate120(msg)}',
        );
      }
      throw AiParsingException(
        type,
        message: msg,
      );
    } on SocketException catch (e) {
      const type = AiParsingErrorType.networkError;
      if (kDebugMode) {
        debugPrint(
          '[Gemini] failed type=$type exception=${e.runtimeType} message=${_truncate120(e.message)}',
        );
      }
      throw AiParsingException(
        type,
        message: e.message,
      );
    } catch (e) {
      const type = AiParsingErrorType.networkError;
      final msg = e is http.ClientException ? e.message : e.toString();
      if (kDebugMode) {
        debugPrint(
          '[Gemini] failed type=$type exception=${e.runtimeType} message=${_truncate120(msg)}',
        );
      }
      if (e is http.ClientException) {
        throw AiParsingException(
          type,
          message: e.message,
        );
      }
      throw AiParsingException(
        type,
        message: e.toString(),
      );
    }
  }
}
