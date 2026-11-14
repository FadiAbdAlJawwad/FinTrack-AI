import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/presentation/utils/money_format.dart';

class WalletBalanceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final int? balanceMinor;
  final AppCurrency currency;
  final VoidCallback? onTap;

  const WalletBalanceTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.balanceMinor,
    required this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = balanceMinor != null && balanceMinor! < 0;
    final amountText = balanceMinor == null
        ? '—'
        : formatMoney(balanceMinor!, currency);

    final amountStyle = context.labelMedium.copyWith(
      color: isNegative ? ColorManager.errorColor : null,
    );

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Card(
          color: ColorManager.primaryBlue.withValues(alpha: 0.1),
          shape: const StadiumBorder(),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, color: ColorManager.primaryBlue),
          ),
        ),
        title: Text(
          title,
          style: context.labelMedium,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: context.labelSmall.copyWith(
                  color: ColorManager.secondaryColor,
                ),
              )
            : null,
        trailing: Text(
          amountText,
          textDirection: TextDirection.ltr,
          style: amountStyle,
        ),
      ),
    );
  }
}
