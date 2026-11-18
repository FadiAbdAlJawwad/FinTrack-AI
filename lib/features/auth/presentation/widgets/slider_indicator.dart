import '../../../../core/constant/color_manager.dart';

import 'package:flutter/material.dart';

class SliderIndicator extends StatelessWidget {
  final bool selected;
  final int currentPage;

  const SliderIndicator({
    super.key,
    this.selected = false,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 9,
      width: selected ? 35 : 9,
      decoration: BoxDecoration(
        color: selected
            ? ColorManager.primaryBlue
            : ColorManager.secondaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }
}
