import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/models/transaction_model.dart';
import '../utils/transaction_display_title.dart';
import '../utils/transaction_ui_extension.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionListTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (transaction.id != null) {
              context.pushNamed(
                AppRoutes.transactionDetailsName,
                pathParameters: {'id': transaction.id!},
              );
            }
          },
      child: Card(
        child: ListTile(
          leading: Card(
            color: ColorManager.primaryBlue.withValues(alpha: 0.1),
            shape: const StadiumBorder(),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(transaction.categoryIcon),
            ),
          ),
          title: Text(
            transactionDisplayTitle(context, transaction),
            style: context.labelMedium,
          ),
          subtitle: Text(
            transaction.formattedDate(context),
            style: context.labelSmall.copyWith(
              color: ColorManager.secondaryColor,
            ),
          ),
          trailing: Text(
            transaction.formattedAmount,
            textDirection: TextDirection.ltr,
            style: context.labelMedium.copyWith(color: transaction.amountColor),
          ),
        ),
      ),
    );
  }
}
