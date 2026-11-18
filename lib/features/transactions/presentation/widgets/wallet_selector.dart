import 'package:flutter/material.dart';

import '../../../../core/extension/app_sizes.dart';
import '../../../../core/widgets/app_chip_selector.dart';
import '../../../wallets/domain/models/wallet_model.dart';
import '../../../wallets/presentation/utils/wallet_display_name.dart';

class WalletSelector extends StatelessWidget {
  final List<WalletModel> wallets;
  final String? selectedWalletId;
  final Function(String) onSelect;

  const WalletSelector({
    super.key,
    required this.wallets,
    this.selectedWalletId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AppChipSelector<WalletModel>(
      items: wallets,
      isSelected: (wallet) => selectedWalletId == wallet.id,
      labelBuilder: (wallet) => walletDisplayName(context.loc, wallet),
      onSelect: (wallet) => onSelect(wallet.id!),
    );
  }
}
