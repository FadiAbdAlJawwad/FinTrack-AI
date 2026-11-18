import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../utils/wallet_icon.dart';

class WalletIconSelector extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onSelect;

  const WalletIconSelector({
    super.key,
    required this.selectedIcon,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: walletIconChoices.map((iconName) {
        final isSelected = selectedIcon == iconName;
        final iconData = walletIconData(iconName);
        return InkWell(
          key: ValueKey('wallet_icon_$iconName'),
          onTap: () => onSelect(iconName),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? ColorManager.primaryBlue.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.05),
              border: isSelected
                  ? Border.all(color: ColorManager.primaryBlue, width: 2)
                  : null,
            ),
            child: Icon(
              iconData,
              color: isSelected
                  ? ColorManager.primaryBlue
                  : ColorManager.secondaryColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}
