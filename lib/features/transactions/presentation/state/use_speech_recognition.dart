import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum VoiceEntryStatus { idle, listening, processing, error }

enum SpeechErrorReason {
  permissionDenied,
  timeout,
  platformError,
}

class SpeechRecognitionState {
  final VoiceEntryStatus status;
  final String transcript;
  final SpeechErrorReason? errorReason;
  final String? rawError;
  final Future<void> Function() startListening;
  final Future<void> Function() stopListening;
  final void Function(VoiceEntryStatus) setStatus;

  SpeechRecognitionState({
    required this.status,
    required this.transcript,
    this.errorReason,
    this.rawError,
    required this.startListening,
    required this.stopListening,
    required this.setStatus,
  });
}

SpeechRecognitionState useSpeechRecognition({required String languageCode}) {
  final speechToText = useMemoized(() => stt.SpeechToText());
  final status = useState(VoiceEntryStatus.idle);
  final transcript = useState('');
  final errorReason = useState<SpeechErrorReason?>(null);
  final rawError = useState<String?>(null);
  final isInitialized = useState(false);

  final startListening = useCallback(() async {
    errorReason.value = null;
    rawError.value = null;
    transcript.value = '';

    try {
      if (!isInitialized.value) {
        isInitialized.value = await speechToText.initialize(
          onError: (error) {
            status.value = VoiceEntryStatus.error;
            errorReason.value = SpeechErrorReason.platformError;
            rawError.value = error.errorMsg;
            if (kDebugMode) {
              final msg = error.errorMsg.replaceAll('\n', ' ');
              final truncated = msg.length > 120 ? msg.substring(0, 120) : msg;
              debugPrint('[SpeechRecognition] platform error: $truncated');
            }
          },
          onStatus: (st) {
            if (st == 'notListening' && status.value == VoiceEntryStatus.listening) {
              status.value = VoiceEntryStatus.idle;
            }
          },
        );
      }

      if (isInitialized.value) {
        String selectedLocaleId = languageCode == 'ar' ? 'ar-SA' : 'en-US';

        try {
          final systemLocales = await speechToText.locales().timeout(const Duration(seconds: 3));

          if (languageCode == 'ar') {
            final match = systemLocales.where((l) => l.localeId.toLowerCase().startsWith('ar')).firstOrNull;
            if (match != null) {
              selectedLocaleId = match.localeId;
            }
          } else {
            final match = systemLocales.where((l) => l.localeId.toLowerCase().startsWith('en')).firstOrNull;
            if (match != null) {
              selectedLocaleId = match.localeId;
            }
          }
        } catch (_) {
          // Silently fallback if locale fetching times out or errors
        }

        status.value = VoiceEntryStatus.listening;
        await speechToText.listen(
          onResult: (result) {
            transcript.value = result.recognizedWords;
          },
          listenOptions: stt.SpeechListenOptions(
            localeId: selectedLocaleId,
            cancelOnError: true,
            partialResults: true,
          ),
        ).timeout(const Duration(seconds: 10));
      } else {
        status.value = VoiceEntryStatus.error;
        errorReason.value = SpeechErrorReason.permissionDenied;
      }
    } on TimeoutException {
      status.value = VoiceEntryStatus.error;
      errorReason.value = SpeechErrorReason.timeout;
    } catch (e) {
      status.value = VoiceEntryStatus.error;
      errorReason.value = SpeechErrorReason.platformError;
      final raw = e.toString();
      rawError.value = raw;
      if (kDebugMode) {
        final msg = raw.replaceAll('\n', ' ');
        final truncated = msg.length > 120 ? msg.substring(0, 120) : msg;
        debugPrint('[SpeechRecognition] platform error: $truncated');
      }
    }
  }, [speechToText, languageCode]);

  final stopListening = useCallback(() async {
    if (status.value == VoiceEntryStatus.listening) {
      await speechToText.stop();
    }
  }, [speechToText]);

  // Clean up
  useEffect(() {
    return () {
      speechToText.cancel();
    };
  }, [speechToText]);

  return SpeechRecognitionState(
    status: status.value,
    transcript: transcript.value,
    errorReason: errorReason.value,
    rawError: rawError.value,
    startListening: startListening,
    stopListening: stopListening,
    setStatus: (newStatus) => status.value = newStatus,
  );
}
