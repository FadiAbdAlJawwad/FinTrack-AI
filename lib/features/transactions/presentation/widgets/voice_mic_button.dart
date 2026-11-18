import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../state/use_speech_recognition.dart';

class VoiceMicButton extends StatelessWidget {
  final VoiceEntryStatus status;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const VoiceMicButton({
    super.key,
    required this.status,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (status == VoiceEntryStatus.listening)
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120 + (pulseAnimation.value * 40),
                    height: 120 + (pulseAnimation.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorManager.primaryBlue.withValues(
                        alpha: 0.2 * (1 - pulseAnimation.value),
                      ),
                    ),
                  );
                },
              ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.primaryBlue,
                ),
                child: Icon(
                  status == VoiceEntryStatus.listening
                      ? Icons.mic
                      : status == VoiceEntryStatus.error
                      ? Icons.mic_off
                      : Icons.mic_none,
                  color: ColorManager.white,
                  size: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
