import 'package:flutter/material.dart';

import '../../../../core/extension/app_sizes.dart';
import '../../../../core/widgets/skeleton_block.dart';
import '../../../../core/widgets/skeleton_shimmer.dart';

class AnalyticsSkeleton extends StatelessWidget {
  const AnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SkeletonBlock(height: 80, radius: 16)),
                context.addHorizontalSpace(12),
                const Expanded(child: SkeletonBlock(height: 80, radius: 16)),
              ],
            ),
            context.addVerticalSpace(24),
            const SkeletonBlock(width: 160, height: 18, radius: 4),
            context.addVerticalSpace(16),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const SkeletonBlock(width: 36, height: 36, radius: 18),
                    context.addHorizontalSpace(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonBlock(width: 80, height: 14, radius: 4),
                          context.addVerticalSpace(8),
                          const SkeletonBlock(height: 8, radius: 4),
                        ],
                      ),
                    ),
                    context.addHorizontalSpace(12),
                    const SkeletonBlock(width: 50, height: 14, radius: 4),
                  ],
                ),
              ),
            ),
            context.addVerticalSpace(80),
          ],
        ).padSymmetric(20),
      ),
    );
  }
}
