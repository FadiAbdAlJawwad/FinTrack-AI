import 'package:flutter/material.dart';

import '../../../../core/extension/app_sizes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/transaction_model.dart';

extension TransactionCategoryExtension on TransactionCategory {
  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.salary:
        return Icons.attach_money;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.other:
        return Icons.category;
    }
  }

  String localizedNameFor(AppLocalizations loc) {
    switch (this) {
      case TransactionCategory.food:
        return loc.catFood;
      case TransactionCategory.transport:
        return loc.catTransport;
      case TransactionCategory.shopping:
        return loc.catShopping;
      case TransactionCategory.salary:
        return loc.catSalary;
      case TransactionCategory.entertainment:
        return loc.catEntertainment;
      case TransactionCategory.other:
        return loc.catOther;
    }
  }

  String getLocalizedName(BuildContext context) {
    return localizedNameFor(context.loc);
  }
}
