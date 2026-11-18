import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/utils/money_format.dart';

class WalletsTotalCard extends StatelessWidget {
  final int? totalMinor;
  final AppCurrency currency;

  const WalletsTotalCard({
    super.key,
    required this.totalMinor,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final amountText = totalMinor == null
        ? '—'
        : formatMoney(totalMinor!, currency);

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: ColorManager.primaryBlue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.loc.totalBalance,
              style: context.bodyMedium.copyWith(
                color: ColorManager.white.withValues(alpha: 0.8),
              ),
            ),
            context.addVerticalSpace(8),
            Text(
              amountText,
              textDirection: TextDirection.ltr,
              style: context.displayLarge.copyWith(
                color: ColorManager.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ).pad(24),
      ),
    );
  }
}
