import 'package:flutter/material.dart';

class BottomSheetDragHandle extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  const BottomSheetDragHandle({
    super.key,
    this.width = 40,
    this.height = 4,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color:
              color ??
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: borderRadius ?? BorderRadius.circular(2),
        ),
      ),
    );
  }
}
