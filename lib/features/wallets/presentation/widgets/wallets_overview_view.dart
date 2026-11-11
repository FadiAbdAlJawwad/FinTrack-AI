import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../transactions/domain/transaction_limits.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/models/wallets_overview.dart';
import '../utils/wallet_display_name.dart';
import '../utils/wallet_icon.dart';
import 'add_wallet_sheet.dart';
import 'wallet_balance_tile.dart';
import 'wallets_total_card.dart';

class WalletsOverviewView extends StatelessWidget {
  final WalletsOverview overview;

  const WalletsOverviewView({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = overview.wallets.isEmpty && !overview.hasUnassigned;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          context.addVerticalSpace(16),
          WalletsTotalCard(
            totalMinor: overview.totalMinor,
            currency: overview.currency,
          ),
          context.addVerticalSpace(16),
          Text(
            context.loc.walletsBalanceWindowNote(transactionWindowMonths),
            style: context.bodyMedium.copyWith(
              color: ColorManager.secondaryColor,
            ),
          ),
          context.addVerticalSpace(24),
          if (isEmpty) ...[
            context.addVerticalSpace(32),
            Center(
              child: Text(
                context.loc.walletsEmpty,
                style: context.bodyMedium.copyWith(
                  color: ColorManager.secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            Text(
              context.loc.walletsYourAccounts,
              style: context.labelLarge,
            ),
            context.addVerticalSpace(12),
            ...overview.wallets.map((wb) {
              final name = walletDisplayName(context.loc, wb.wallet);
              final icon = walletIconData(wb.wallet.icon);
              String typeName = '';
              switch (wb.wallet.type) {
                case WalletType.cash:
                  typeName = context.loc.defaultWalletName;
                  break;
                case WalletType.bank:
                  typeName = context.loc.walletNameBank;
                  break;
                case WalletType.eWallet:
                  typeName = context.loc.walletTypeEWallet;
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WalletBalanceTile(
                  title: name,
                  subtitle: typeName,
                  icon: icon,
                  balanceMinor: wb.balanceMinor,
                  currency: overview.currency,
                  onTap: () => showAddWalletSheet(context, wallet: wb.wallet),
                ),
              );
            }),
            if (overview.hasUnassigned)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WalletBalanceTile(
                  title: context.loc.walletsUnassigned,
                  icon: Icons.help_outline,
                  balanceMinor: overview.unassignedMinor,
                  currency: overview.currency,
                ),
              ),
          ],
          context.addVerticalSpace(80),
        ],
      ).padSymmetric(20),
    );
  }
}
