import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/utils/money_format.dart';
import '../../../transactions/presentation/utils/transaction_category_extension.dart';
import '../../domain/models/analytics_summary.dart';

class CategoryExpenseTile extends StatelessWidget {
  final CategoryExpense item;
  final AppCurrency currency;

  const CategoryExpenseTile({
    super.key,
    required this.item,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final amountText = item.amountMinor == null
        ? '—'
        : formatMoney(item.amountMinor!, currency);

    return Card(
      child: ListTile(
        leading: Card(
          color: ColorManager.primaryBlue.withValues(alpha: 0.1),
          shape: const StadiumBorder(),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(item.category.icon, color: ColorManager.primaryBlue),
          ),
        ),
        title: Text(
          item.category.getLocalizedName(context),
          style: context.labelMedium,
        ),
        subtitle: item.share == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: item.share,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(4),
                        color: ColorManager.primaryBlue,
                        backgroundColor: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    context.addHorizontalSpace(12),
                    Text(
                      '${(item.share! * 100).round()}%',
                      textDirection: TextDirection.ltr,
                      style: context.labelSmall.copyWith(
                        color: ColorManager.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
        trailing: Text(
          amountText,
          textDirection: TextDirection.ltr,
          style: context.labelMedium,
        ),
      ),
    );
  }
}
