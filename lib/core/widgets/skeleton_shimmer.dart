import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

({Color baseColor, Color highlightColor}) skeletonColors(
  Brightness brightness,
) {
  final isDark = brightness == Brightness.dark;
  return (
    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
    highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
  );
}

class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = skeletonColors(Theme.of(context).brightness);

    return Shimmer.fromColors(
      baseColor: colors.baseColor,
      highlightColor: colors.highlightColor,
      child: child,
    );
  }
}
