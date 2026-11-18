import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/widgets/app_chip_selector.dart';
import '../../domain/models/transaction_model.dart';
import '../utils/transaction_category_extension.dart';

class CategorySelector extends StatelessWidget {
  final List<TransactionCategory> categories;
  final TransactionCategory? selectedCategory;
  final Function(TransactionCategory) onSelect;

  const CategorySelector({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AppChipSelector<TransactionCategory>(
      items: categories,
      isSelected: (cat) => selectedCategory == cat,
      labelBuilder: (cat) => cat.getLocalizedName(context),
      onSelect: onSelect,
      trailing: ActionChip(
        label: Text(context.loc.more),
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.onSurface
            .withValues(alpha: 0.05),
        labelStyle: context.labelSmall.copyWith(
          color: ColorManager.secondaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
