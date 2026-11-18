import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/screens/transaction_details.dart';
import 'package:fin_track_ai/features/transactions/presentation/state/transaction_controller.dart';
import 'package:fin_track_ai/features/wallets/domain/models/wallet_model.dart';
import 'package:fin_track_ai/features/wallets/presentation/state/wallet_controller.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

class TestTransactionController extends TransactionController {
  final List<TransactionModel> transactions;
  TestTransactionController(this.transactions);

  @override
  Stream<List<TransactionModel>> build() => Stream.value(transactions);
}

class TestWalletController extends WalletController {
  final List<WalletModel> wallets;
  TestWalletController(this.wallets);

  @override
  Stream<List<WalletModel>> build() => Stream.value(wallets);
}

Widget buildTestableWidget({
  required TransactionModel transaction,
  required List<WalletModel> wallets,
  required Locale locale,
  Key? key,
}) {
  return ProviderScope(
    key: key,
    overrides: [
      transactionControllerProvider.overrideWith(
        () => TestTransactionController([transaction]),
      ),
      walletControllerProvider.overrideWith(
        () => TestWalletController(wallets),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: TransactionDetails(transactionId: transaction.id!),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
    await initializeDateFormatting('en', null);
  });

  group('TransactionDetails localization tests', () {
    final sampleTx = TransactionModel(
      id: 'tx1',
      amountMinor: 1000,
      currency: AppCurrency.usd,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      title: 'Dinner',
      date: DateTime(2026, 10, 14, 15, 30),
      walletId: 'cash',
    );

    const seededWallets = [
      WalletModel(id: 'cash', name: 'Cash', icon: 'payments'),
    ];

    testWidgets(
      'Arabic: category shows localized name طعام twice, no food/FOOD',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            transaction: sampleTx,
            wallets: seededWallets,
            locale: const Locale('ar'),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        expect(find.text('طعام'), findsNWidgets(2));
        expect(find.text('food'), findsNothing);
        expect(find.text('FOOD'), findsNothing);
      },
    );

    testWidgets('Arabic: type row shows مصاريف for expense transaction', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          transaction: sampleTx,
          wallets: seededWallets,
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();
      await tester.pump(Duration.zero);

      expect(find.text('مصاريف'), findsOneWidget);
    });

    testWidgets('Arabic: type row shows دخل for income transaction', (
      tester,
    ) async {
      final incomeTx = sampleTx.copyWith(type: TransactionType.income);
      await tester.pumpWidget(
        buildTestableWidget(
          transaction: incomeTx,
          wallets: seededWallets,
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();
      await tester.pump(Duration.zero);

      expect(find.text('دخل'), findsOneWidget);
    });

    testWidgets(
      'English: headline shows Food, category row FOOD and type row EXPENSE',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            transaction: sampleTx,
            wallets: seededWallets,
            locale: const Locale('en'),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        expect(find.text('Food'), findsOneWidget);
        expect(find.text('FOOD'), findsOneWidget);
        expect(find.text('EXPENSE'), findsOneWidget);
      },
    );

    testWidgets(
      '13. TransactionDetails: seeded wallet shows localized name in Arabic',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            transaction: sampleTx,
            wallets: seededWallets,
            locale: const Locale('ar'),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        expect(find.text('نقدي'), findsOneWidget);
      },
    );
  });
}
