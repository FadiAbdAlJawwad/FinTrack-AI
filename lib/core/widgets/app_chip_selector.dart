import 'package:flutter/material.dart';

import '../constant/color_manager.dart';
import '../extension/text_style_extension.dart';

class AppChipSelector<T> extends StatelessWidget {
  final List<T> items;
  final bool Function(T item) isSelected;
  final String Function(T item) labelBuilder;
  final void Function(T item) onSelect;
  final Widget? trailing;

  const AppChipSelector({
    super.key,
    required this.items,
    required this.isSelected,
    required this.labelBuilder,
    required this.onSelect,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && trailing == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...items.map((item) {
            final selected = isSelected(item);
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(labelBuilder(item)),
                selected: selected,
                onSelected: (_) => onSelect(item),
                selectedColor: ColorManager.primaryBlue,
                backgroundColor: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.05),
                labelStyle: context.labelSmall.copyWith(
                  color: selected
                      ? ColorManager.white
                      : ColorManager.secondaryColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide.none,
                ),
                showCheckmark: false,
              ),
            );
          }),
          ?trailing,
        ],
      ),
    );
  }
}
