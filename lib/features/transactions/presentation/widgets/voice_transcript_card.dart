import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../state/use_speech_recognition.dart';

class VoiceTranscriptCard extends StatelessWidget {
  final VoiceEntryStatus status;
  final String transcript;

  const VoiceTranscriptCard({
    super.key,
    required this.status,
    required this.transcript,
  });

  @override
  Widget build(BuildContext context) {
    if (transcript.isEmpty && status != VoiceEntryStatus.error) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: context.spaceAroundAll(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: context.circularRadius(16),
        border: Border.all(
          color: status == VoiceEntryStatus.error
              ? ColorManager.errorColor.withValues(alpha: 0.5)
              : ColorManager.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        status == VoiceEntryStatus.error
            ? context.loc.tryAgainVoice
            : transcript,
        style: context.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
