import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constant/color_manager.dart';
import '../../../../core/error/ai_parsing_exception.dart';
import '../../../../core/error/ai_parsing_exception_extension.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/usecases/parse_gemini_transaction_usecase.dart';
import '../state/use_speech_recognition.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import '../widgets/voice_action_button.dart';
import '../widgets/voice_mic_button.dart';
import '../widgets/voice_transcript_card.dart';

class VoiceEntryScreen extends StatefulHookConsumerWidget {
  const VoiceEntryScreen({super.key});

  @override
  ConsumerState<VoiceEntryScreen> createState() => _VoiceEntryScreenState();
}

class _VoiceEntryScreenState extends ConsumerState<VoiceEntryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = ref.watch(localeProvider);
    final speechState = useSpeechRecognition(languageCode: appLocale.languageCode);
    final errorMessage = useState<String?>(null);


    useEffect(() {
      if (speechState.status == VoiceEntryStatus.error) {
        switch (speechState.errorReason) {
          case SpeechErrorReason.permissionDenied:
            errorMessage.value = context.loc.micPermissionDenied;
            break;
          case SpeechErrorReason.timeout:
            errorMessage.value = context.loc.speechTimeout;
            break;
          case SpeechErrorReason.platformError:
            errorMessage.value = context.loc.aiUnknown;
            break;
          default:
            break;
        }
      }
      return null;
    }, [speechState.status, speechState.errorReason, speechState.rawError]);

    final processTranscript = useCallback(() async {
      if (speechState.transcript.trim().isEmpty) {
        speechState.setStatus(VoiceEntryStatus.error);
        if (context.mounted) {
          errorMessage.value = context.loc.aiInvalidInput;
        }
        return;
      }

      speechState.setStatus(VoiceEntryStatus.processing);

      try {
        final result = await ref
            .read(geminiServiceProvider)
            .parseTransactionText(speechState.transcript);

        final draft = parseGeminiTransaction(result);

        if (!context.mounted) return;

        final parentContext = Navigator.of(context).context;
        context.pop();

        showModalBottomSheet(
          context: parentContext,
          isScrollControlled: true,
            backgroundColor: Colors.transparent,
          builder: (context) => AddTransactionBottomSheet(
            prefillDraft: draft,
          ),
        );
      } on AiParsingException catch (e) {
        if (!context.mounted) return;
        speechState.setStatus(VoiceEntryStatus.error);
        errorMessage.value = e.getLocalizedMessage(context);
      } catch (e) {
        if (kDebugMode) {
          final msg = e.toString().replaceAll('\n', ' ');
          final truncated = msg.length > 120 ? msg.substring(0, 120) : msg;
          debugPrint('[VoiceEntry] unexpected ${e.runtimeType}: $truncated');
        }
        if (!context.mounted) return;
        speechState.setStatus(VoiceEntryStatus.error);
        errorMessage.value = context.loc.aiUnknown;
      }
    }, [speechState.transcript, speechState.setStatus]);

    final stopSession = useCallback(() async {
      await speechState.stopListening();
      await processTranscript();
    }, [speechState.stopListening, processTranscript]);

    useEffect(() {
      speechState.startListening();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: context.spaceAroundAll(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    context.loc.voiceEntryTitle,
                    style: context.headlineMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface, size: 28),
                    onPressed: () {
                      speechState.stopListening();
                      context.pop();
                    },
                  ),
                ],
              ),
              context.addVerticalSpace(40),

              Text(
                speechState.status == VoiceEntryStatus.error
                    ? (errorMessage.value ?? context.loc.aiUnknown)
                    : speechState.status == VoiceEntryStatus.listening
                        ? context.loc.listeningStatus
                        : speechState.status == VoiceEntryStatus.processing
                            ? context.loc.processingStatus
                            : context.loc.tapToSpeak,
                textAlign: TextAlign.center,
                style: context.bodyMedium.copyWith(
                  color: speechState.status == VoiceEntryStatus.error
                      ? ColorManager.errorColor
                      : ColorManager.secondaryColor,
                ),
              ),
              
              context.addVerticalSpace(40),

              VoiceMicButton(
                status: speechState.status,
                pulseAnimation: _pulseController,
                onTap: () {
                  if (speechState.status == VoiceEntryStatus.listening) {
                    stopSession();
                  } else if (speechState.status == VoiceEntryStatus.error ||
                      speechState.status == VoiceEntryStatus.idle) {
                    speechState.startListening();
                  }
                },
              ),
              
              context.addVerticalSpace(40),

              VoiceTranscriptCard(
                status: speechState.status,
                transcript: speechState.transcript,
              ),
                
              context.addVerticalSpace(40),
              
              VoiceActionButton(
                status: speechState.status,
                transcript: speechState.transcript,
                onTap: () {
                  if (speechState.status == VoiceEntryStatus.listening) {
                    stopSession();
                  } else if (speechState.status == VoiceEntryStatus.idle) {
                    processTranscript();
                  } else if (speechState.status == VoiceEntryStatus.error) {
                    speechState.startListening();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}