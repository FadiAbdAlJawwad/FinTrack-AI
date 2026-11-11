import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/widgets/app_chip_selector.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/domain/usecases/money.dart';
import '../../../currency/presentation/state/currency_controller.dart';
import '../../../transactions/presentation/utils/error_message.dart';
import '../../../transactions/presentation/state/transaction_controller.dart';
import '../../../transactions/domain/transaction_limits.dart';
import '../../domain/usecases/wallet_has_transactions.dart';
import '../../domain/models/wallet_model.dart';
import '../state/wallet_controller.dart';
import '../utils/wallet_display_name.dart';
import '../utils/wallet_icon.dart';
import '../utils/wallet_type_label.dart';
import 'wallet_icon_selector.dart';

Future<void> showAddWalletSheet(BuildContext context, {WalletModel? wallet}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddWalletSheet(wallet: wallet),
  );
}

class AddWalletSheet extends HookConsumerWidget {
  final WalletModel? wallet;
  const AddWalletSheet({super.key, this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = wallet != null;
    final initialDisplayName =
        isEditMode ? walletDisplayName(context.loc, wallet!) : '';
    final nameController = useTextEditingController(text: initialDisplayName);
    useValueListenable(nameController);
    final selectedIcon = useState<String>(wallet?.icon ?? walletIconChoices.first);
    final selectedType = useState<WalletType>(wallet?.type ?? WalletType.cash);
    final isLoading = useState(false);

    final baseCurrencyCode = ref.watch(currencyControllerProvider).valueOrNull ?? 'USD';
    final initialCurrency = isEditMode && wallet!.openingBalanceCurrency != null
        ? wallet!.openingBalanceCurrency!
        : appCurrencyFromCode(baseCurrencyCode);
    final selectedCurrency = useState<AppCurrency>(initialCurrency);

    final initialBalanceText = isEditMode && wallet!.openingBalanceMinor != null
        ? minorToPlainText(wallet!.openingBalanceMinor!, wallet!.openingBalanceCurrency!)
        : '';
    final balanceController = useTextEditingController(text: initialBalanceText);
    useValueListenable(balanceController);

    final wallets = ref.watch(walletControllerProvider).valueOrNull ?? [];
    final transactions = ref.watch(transactionControllerProvider).valueOrNull ?? [];
    final trimmedName = nameController.text.trim();
    final trimmedBalance = balanceController.text.trim();
    
    int? parsedOpeningBalance;
    bool isBalanceValid = true;
    if (trimmedBalance.isNotEmpty) {
      parsedOpeningBalance = parseMinorUnits(trimmedBalance, selectedCurrency.value);
      if (parsedOpeningBalance == null) {
        isBalanceValid = false;
      }
    }

    final isDuplicate = trimmedName.isNotEmpty &&
        wallets.any((w) {
          if (isEditMode && w.id == wallet!.id) return false;
          final storedName = w.name.trim().toLowerCase();
          final localizedName =
              walletDisplayName(context.loc, w).trim().toLowerCase();
          final target = trimmedName.toLowerCase();
          return storedName == target || localizedName == target;
        });

    final hasChanged = !isEditMode ||
        trimmedName != initialDisplayName ||
        selectedIcon.value != wallet!.icon ||
        selectedType.value != wallet!.type ||
        parsedOpeningBalance != wallet!.openingBalanceMinor ||
        (parsedOpeningBalance != null && selectedCurrency.value != wallet!.openingBalanceCurrency);

    final isFormValid = trimmedName.isNotEmpty &&
        trimmedName.length <= 50 &&
        !isDuplicate &&
        isBalanceValid &&
        !isLoading.value &&
        hasChanged;

    Future<void> handleSave() async {
      if (!isFormValid) return;
      isLoading.value = true;
      try {
        if (isEditMode) {
          final nameToStore =
              trimmedName == initialDisplayName ? wallet!.name : trimmedName;
          await ref.read(walletControllerProvider.notifier).updateWallet(
                wallet!.copyWith(
                  name: nameToStore,
                  icon: selectedIcon.value,
                  type: selectedType.value,
                  openingBalanceMinor: parsedOpeningBalance,
                  openingBalanceCurrency: parsedOpeningBalance != null ? selectedCurrency.value : null,
                ),
              );
        } else {
          await ref.read(walletControllerProvider.notifier).addWallet(
                WalletModel(
                  name: trimmedName,
                  icon: selectedIcon.value,
                  isDefault: false,
                  type: selectedType.value,
                  openingBalanceMinor: parsedOpeningBalance,
                  openingBalanceCurrency: parsedOpeningBalance != null ? selectedCurrency.value : null,
                ),
              );
        }
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage(context, e))),
          );
        }
      } finally {
        if (context.mounted) isLoading.value = false;
      }
    }

    Future<void> handleDelete() async {
      if (walletHasTransactions(transactions, wallet!.id!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.walletHasTransactionsMessage(transactionWindowMonths)),
          ),
        );
        return;
      }
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.loc.deleteWalletConfirmTitle),
          content: Text(context.loc.deleteWalletConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.loc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: ColorManager.errorColor),
              child: Text(context.loc.delete),
            ),
          ],
        ),
      );
      if (confirm == true) {
        isLoading.value = true;
        try {
          await ref.read(walletControllerProvider.notifier).deleteWallet(wallet!.id!);
          if (context.mounted) Navigator.pop(context);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage(context, e))),
            );
          }
        } finally {
          if (context.mounted) isLoading.value = false;
        }
      }
    }

    final outlineColor = Theme.of(context).colorScheme.outlineVariant;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: outlineColor),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetDragHandle(),
                context.addVerticalSpace(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditMode
                          ? context.loc.editWalletTitle
                          : context.loc.addWalletTitle,
                      style: context.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                context.addVerticalSpace(20),
                Text(
                  context.loc.walletNameLabel,
                  style: context.labelSmall.copyWith(
                    color: ColorManager.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.addVerticalSpace(8),
                TextField(
                  controller: nameController,
                  maxLength: 50,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: context.loc.walletNameHint,
                    hintStyle: context.labelMedium.copyWith(color: ColorManager.secondaryColor),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    counterText: '',
                    border: border,
                    enabledBorder: border,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ColorManager.primaryBlue, width: 1.5),
                    ),
                    errorText: isDuplicate ? context.loc.walletNameExists : null,
                  ),
                ),
                context.addVerticalSpace(16),
                Text(
                  context.loc.walletTypeLabel,
                  style: context.labelSmall.copyWith(
                    color: ColorManager.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.addVerticalSpace(12),
                AppChipSelector<WalletType>(
                  items: const [WalletType.cash, WalletType.bank, WalletType.eWallet],
                  isSelected: (type) => type == selectedType.value,
                  labelBuilder: (type) => walletTypeLabel(context.loc, type),
                  onSelect: (type) => selectedType.value = type,
                ),
                context.addVerticalSpace(16),
                Text(
                  context.loc.openingBalanceLabel,
                  style: context.labelSmall.copyWith(
                    color: ColorManager.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.addVerticalSpace(8),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: minorToPlainText(0, selectedCurrency.value),
                    hintStyle: context.labelMedium.copyWith(color: ColorManager.secondaryColor),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    counterText: '',
                    border: border,
                    enabledBorder: border,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ColorManager.primaryBlue, width: 1.5),
                    ),
                    errorText: !isBalanceValid && trimmedBalance.isNotEmpty ? context.loc.invalidAmount : null,
                  ),
                ),
                context.addVerticalSpace(12),
                AppChipSelector<AppCurrency>(
                  items: AppCurrency.values,
                  isSelected: (currency) => currency == selectedCurrency.value,
                  labelBuilder: (currency) => '${currency.code} (${currency.symbol})',
                  onSelect: (currency) => selectedCurrency.value = currency,
                ),
                context.addVerticalSpace(16),
                Text(
                  context.loc.walletIconLabel,
                  style: context.labelSmall.copyWith(
                    color: ColorManager.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.addVerticalSpace(12),
                WalletIconSelector(
                  selectedIcon: selectedIcon.value,
                  onSelect: (icon) => selectedIcon.value = icon,
                ),
                context.addVerticalSpace(32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isFormValid ? handleSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryBlue,
                      disabledBackgroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading.value
                        ? const CircularProgressIndicator(color: ColorManager.white)
                        : Text(
                            isEditMode
                                ? context.loc.saveWallet
                                : context.loc.createWallet,
                            style: context.labelLarge.copyWith(
                              color: isFormValid
                                  ? ColorManager.white
                                  : ColorManager.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (isEditMode && !wallet!.isDefault) ...[
                  context.addVerticalSpace(16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: isLoading.value ? null : handleDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: ColorManager.errorColor,
                      ),
                      child: Text(context.loc.deleteWallet),
                    ),
                  ),
                ],
                context.addVerticalSpace(16),
              ],
            ).padSymmetric(20).padTop(16),
          ),
          if (isLoading.value) const LoadingOverlay(),
        ],
      ),
    );
  }
}
