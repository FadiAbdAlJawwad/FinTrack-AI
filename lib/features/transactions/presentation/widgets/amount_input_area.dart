import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../domain/models/transaction_model.dart';

class AmountInputArea extends StatelessWidget {
  final TextEditingController controller;
  final TransactionType type;
  final AppCurrency currency;
  final ValueChanged<AppCurrency> onCurrencyChanged;

  const AmountInputArea({
    super.key,
    required this.controller,
    required this.type,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = type == TransactionType.expense;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PopupMenuButton<AppCurrency>(
          onSelected: onCurrencyChanged,
          itemBuilder: (context) => AppCurrency.values
              .map(
                (c) => PopupMenuItem(
                  value: c,
                  child: Text('${c.code} (${c.symbol})'),
                ),
              )
              .toList(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpense ? '- ${currency.symbol}' : '+ ${currency.symbol}',
                style: context.headlineLarge.copyWith(
                  color: isExpense
                      ? ColorManager.errorColor
                      : ColorManager.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: ColorManager.secondaryColor,
                size: 18,
              ),
            ],
          ),
        ),
        context.addHorizontalSpace(8),
        IntrinsicWidth(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp('^\\d*\\.?\\d{0,${currency.decimals}}'),
              ),
            ],
            style: context.displayLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              fillColor: Colors.transparent,
              hintText: context.loc.all.contains('All')
                  ? '0.00'
                  : '0.00', // Small trick for placeholder
              hintStyle: TextStyle(
                color: ColorManager.secondaryColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.transparent,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
