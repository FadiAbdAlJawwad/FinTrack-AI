import 'package:flutter/material.dart';

import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/utils/money_format.dart';

class AnalyticsAmountCard extends StatelessWidget {
  final String label;
  final int? amountMinor;
  final AppCurrency currency;
  final String sign;
  final Color color;

  const AnalyticsAmountCard({
    super.key,
    required this.label,
    required this.amountMinor,
    required this.currency,
    required this.sign,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final amountText = amountMinor == null
        ? '—'
        : '$sign${formatMoney(amountMinor!, currency)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.bodyMedium),
            context.addVerticalSpace(8),
            Text(
              amountText,
              textDirection: TextDirection.ltr,
              style: context.labelLarge.copyWith(
                color: amountMinor == null ? null : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
