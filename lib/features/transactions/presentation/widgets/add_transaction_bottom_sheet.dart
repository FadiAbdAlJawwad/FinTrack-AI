import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/transaction_limits.dart';
import '../../../currency/data/services/exchange_rate_service.dart';
import '../../../currency/domain/models/app_currency.dart';
import '../../../currency/domain/usecases/money.dart';
import '../../../currency/presentation/state/currency_controller.dart';
import '../../../wallets/domain/usecases/check_sufficient_balance_usecase.dart';
import '../../../wallets/presentation/state/wallet_controller.dart';
import '../../../wallets/presentation/state/wallets_overview_provider.dart';
import '../state/transaction_controller.dart';
import '../utils/transaction_display_title.dart';
import '../utils/error_message.dart';
import 'amount_input_area.dart';
import 'category_selector.dart';
import 'transaction_metadata_row.dart';
import 'transaction_type_toggle.dart';
import 'wallet_selector.dart';

class AddTransactionBottomSheet extends HookConsumerWidget {
  final TransactionModel? existingTransaction;
  final TransactionDraft? prefillDraft;

  const AddTransactionBottomSheet({
    super.key,
    this.existingTransaction,
    this.prefillDraft,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = useState(
      existingTransaction?.type ??
          prefillDraft?.type ??
          TransactionType.expense,
    );
    final selectedCategory = useState<TransactionCategory?>(
      existingTransaction?.category ?? prefillDraft?.category,
    );
    final selectedWalletId = useState<String?>(existingTransaction?.walletId);
    final selectedDate = useState(
      existingTransaction?.date ?? prefillDraft?.date ?? DateTime.now(),
    );

    final tx = existingTransaction;
    final initialNotesText = tx != null
        ? (isAutoTitle(tx) ? '' : tx.title)
        : (prefillDraft?.title ?? '');
    final notesController = useTextEditingController(
      text: initialNotesText.characters
          .take(maxNoteLength)
          .toString(),
    );
    final isLoading = useState(false);

    final walletsAsync = ref.watch(walletControllerProvider);
    final wallets = walletsAsync.valueOrNull ?? [];
    ref.watch(walletsOverviewProvider);

    final appCurrencyCode =
        ref.watch(currencyControllerProvider).valueOrNull ?? 'USD';
    final isEditing = existingTransaction != null;
    final selectedInputCurrency = useState(
      existingTransaction?.currency ?? appCurrencyFromCode(appCurrencyCode),
    );
    final amountController = useTextEditingController(
      text: _initialAmountText(
        existingTransaction,
        prefillDraft,
        selectedInputCurrency.value,
      ),
    );
    useValueListenable(amountController);

    useEffect(() {
      if (selectedWalletId.value == null && wallets.isNotEmpty) {
        selectedWalletId.value = wallets
            .firstWhere((w) => w.isDefault, orElse: () => wallets.first)
            .id;
      }
      return null;
    }, [wallets.length]);

    useEffect(() {
      // An edited transaction keeps its own currency.
      if (!isEditing) {
        selectedInputCurrency.value = appCurrencyFromCode(appCurrencyCode);
      }
      return null;
    }, [appCurrencyCode]);

    final categories = categoriesForType(selectedType.value);

    final amountMinor = parseMinorUnits(
      amountController.text,
      selectedInputCurrency.value,
    );
    final bool isFormValid =
        amountMinor != null &&
        amountMinor > 0 &&
        selectedCategory.value != null &&
        selectedWalletId.value != null &&
        !isLoading.value;

    Future<void> handleSave() async {
      if (!isFormValid) return;

      isLoading.value = true;
      try {
        if (selectedType.value == TransactionType.expense) {
          final rateService = ref.read(exchangeRateServiceProvider);
          double rateBetween(AppCurrency from, AppCurrency to) =>
              rateService.rateBetween(from.code, to.code);

          final walletsOverview =
              ref.read(walletsOverviewProvider).valueOrNull;

          int? walletBalanceMinor;
          AppCurrency baseCurrency = appCurrencyFromCode(appCurrencyCode);

          if (walletsOverview != null) {
            baseCurrency = walletsOverview.currency;
            final walletBalance = walletsOverview.wallets
                .where((wb) => wb.wallet.id == selectedWalletId.value)
                .firstOrNull;
            walletBalanceMinor = walletBalance?.balanceMinor;
          }

          int? replacedAmountMinorInBase;
          if (existingTransaction != null &&
              existingTransaction!.type == TransactionType.expense &&
              existingTransaction!.walletId == selectedWalletId.value) {
            try {
              final rate =
                  rateBetween(existingTransaction!.currency, baseCurrency);
              replacedAmountMinorInBase = convertMinorUnits(
                existingTransaction!.amountMinor,
                existingTransaction!.currency,
                baseCurrency,
                rate,
              );
            } catch (_) {
              replacedAmountMinorInBase = null;
            }
          }

          final selectedWallet = wallets
              .where((w) => w.id == selectedWalletId.value)
              .firstOrNull;
          final transactions =
              ref.read(transactionControllerProvider).valueOrNull ?? [];
          final hasIncome = transactions.any(
            (t) =>
                t.walletId == selectedWalletId.value &&
                t.type == TransactionType.income,
          );
          final walletHasHistory =
              (selectedWallet?.openingBalanceMinor != null) || hasIncome;

          final hasBalance = hasSufficientBalance(
            walletBalanceMinor: walletBalanceMinor,
            baseCurrency: baseCurrency,
            amountMinor: amountMinor,
            amountCurrency: selectedInputCurrency.value,
            type: selectedType.value,
            replacedAmountMinorInBase: replacedAmountMinorInBase,
            rateBetween: rateBetween,
            walletHasHistory: walletHasHistory,
          );

          if (!hasBalance) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.loc.insufficientBalance)),
              );
            }
            return;
          }
        }

        final transaction = _buildTransactionFromForm(
          existingTransaction: existingTransaction,
          amountMinor: amountMinor,
          currency: selectedInputCurrency.value,
          type: selectedType.value,
          category: selectedCategory.value!,
          notesText: notesController.text,
          date: selectedDate.value,
          walletId: selectedWalletId.value!,
        );

        if (existingTransaction == null) {
          await ref
              .read(transactionControllerProvider.notifier)
              .addTransaction(transaction);
        } else {
          await ref
              .read(transactionControllerProvider.notifier)
              .updateTransaction(transaction);
        }

        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage(context, e))));
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetDragHandle(),
                context.addVerticalSpace(20),
                TransactionTypeToggle(
                  selectedType: selectedType.value,
                  onChanged: (TransactionType type) {
                    selectedType.value = type;
                    selectedCategory.value = null;
                  },
                ),
                context.addVerticalSpace(32),
                AmountInputArea(
                  controller: amountController,
                  type: selectedType.value,
                  currency: selectedInputCurrency.value,
                  onCurrencyChanged: (currency) =>
                      selectedInputCurrency.value = currency,
                ),
                context.addVerticalSpace(24),
                TransactionMetadataRow(
                  selectedDate: selectedDate.value,
                  notesController: notesController,
                  onDateTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) selectedDate.value = picked;
                  },
                ),
                context.addVerticalSpace(24),
                Text(
                  context.loc.selectWallet,
                  style: context.labelSmall.copyWith(
                    color: ColorManager.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.addVerticalSpace(12),
                if (walletsAsync.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      errorMessage(context, walletsAsync.error!),
                      style: context.labelSmall.copyWith(
                        color: ColorManager.errorColor,
                      ),
                    ),
                  ),
                WalletSelector(
                  wallets: wallets,
                  selectedWalletId: selectedWalletId.value,
                  onSelect: (val) => selectedWalletId.value = val,
                ),
                const SizedBox(height: 24),
                Text(
                  context.loc.category,
                  style: context.labelSmall.copyWith(
                    color: ColorManager.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CategorySelector(
                  categories: categories,
                  selectedCategory: selectedCategory.value,
                  onSelect: (cat) => selectedCategory.value = cat,
                ),
                const SizedBox(height: 32),
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
                            existingTransaction == null
                                ? context.loc.saveTransaction
                                : context.loc.editTransaction,
                            style: context.labelLarge.copyWith(
                              color: isFormValid
                                  ? ColorManager.white
                                  : ColorManager.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ).padSymmetric(20).padTop(16),
          ),
          if (isLoading.value) const LoadingOverlay(),
        ],
      ),
    );
  }
}

TransactionModel _buildTransactionFromForm({
  required TransactionModel? existingTransaction,
  required int amountMinor,
  required AppCurrency currency,
  required TransactionType type,
  required TransactionCategory category,
  required String notesText,
  required DateTime date,
  required String walletId,
}) {
  return TransactionModel(
    id: existingTransaction?.id,
    amountMinor: amountMinor,
    currency: currency,
    type: type,
    category: category,
    title: notesText,
    date: date,
    walletId: walletId,
  );
}

/// Initial text of the amount field: the edited transaction's exact amount,
/// or the voice draft rounded to the input currency's decimals.
String _initialAmountText(
  TransactionModel? existingTransaction,
  TransactionDraft? prefillDraft,
  AppCurrency inputCurrency,
) {
  if (existingTransaction != null) {
    return minorToPlainText(
      existingTransaction.amountMinor,
      existingTransaction.currency,
    );
  }
  if (prefillDraft != null) {
    return prefillDraft.amount.toStringAsFixed(inputCurrency.decimals);
  }
  return '';
}
