import 'package:flutter/material.dart';
import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/widgets/skeleton_shimmer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.addVerticalSpace(16),
            // Balance Card Skeleton
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            context.addVerticalSpace(24),
            // Action Cards Skeleton
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
                    height: 100,
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            context.addVerticalSpace(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 20, width: 150, color: ColorManager.white),
                Container(height: 16, width: 60, color: ColorManager.white),
              ],
            ),
            context.addVerticalSpace(16),

            ListView.separated(
              itemCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => context.addVerticalSpace(8),
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: ColorManager.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    trailing: Container(
                      height: 16,
                      width: 60,
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ).padSymmetric(20).padVerticalSymmetric(15),
      ),
    );
  }
}
