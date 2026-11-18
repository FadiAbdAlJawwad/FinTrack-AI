import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../state/use_speech_recognition.dart';

class VoiceActionButton extends StatelessWidget {
  final VoiceEntryStatus status;
  final String transcript;
  final VoidCallback onTap;

  const VoiceActionButton({
    super.key,
    required this.status,
    required this.transcript,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        status != VoiceEntryStatus.processing &&
        (status == VoiceEntryStatus.listening ||
            status == VoiceEntryStatus.error ||
            (status == VoiceEntryStatus.idle && transcript.isNotEmpty));

    return ElevatedButton(
      onPressed: isEnabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primaryBlue,
        disabledBackgroundColor: ColorManager.primaryBlue.withValues(
          alpha: 0.3,
        ),
        padding: context.spaceVertical(16),
        shape: RoundedRectangleBorder(borderRadius: context.circularRadius(12)),
      ),
      child: status == VoiceEntryStatus.processing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorManager.secondaryColor,
                  ),
                ),
                context.addHorizontalSpace(12),
                Text(
                  context.loc.processingButton,
                  style: context.labelLarge.copyWith(
                    color: ColorManager.secondaryColor,
                  ),
                ),
              ],
            )
          : Text(
              status == VoiceEntryStatus.error
                  ? context.loc.tryAgainButton
                  : context.loc.stopAndProcess,
              style: context.labelLarge.copyWith(color: ColorManager.white),
            ),
    );
  }
}
