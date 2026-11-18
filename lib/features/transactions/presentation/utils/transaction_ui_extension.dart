import '../../../../core/constant/color_manager.dart';

import 'package:flutter/material.dart';

import '../../../currency/presentation/utils/money_format.dart';
import '../../domain/models/transaction_model.dart';
import 'localized_date_format.dart';
import 'transaction_category_extension.dart';

extension TransactionUIExtension on TransactionModel {
  Color get amountColor => type == TransactionType.income
      ? ColorManager.successColor
      : ColorManager.errorColor;

  String get formattedAmount {
    final money = formatMoney(amountMinor, currency);
    return type == TransactionType.income ? '+ $money' : '- $money';
  }

  String formattedDate(BuildContext context) =>
      formatLocalizedDate(context, 'MMM dd, hh:mm a', date);

  IconData get categoryIcon => category.icon;
}
