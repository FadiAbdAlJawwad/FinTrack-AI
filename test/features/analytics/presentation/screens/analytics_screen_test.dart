import 'package:fin_track_ai/core/constant/color_manager.dart';
import 'package:fin_track_ai/core/error/transaction_exception.dart';
import 'package:fin_track_ai/features/analytics/domain/models/analytics_period.dart';
import 'package:fin_track_ai/features/analytics/domain/models/analytics_summary.dart';
import 'package:fin_track_ai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:fin_track_ai/features/analytics/presentation/state/analytics_providers.dart';
import 'package:fin_track_ai/features/analytics/presentation/widgets/analytics_amount_card.dart';
import 'package:fin_track_ai/features/analytics/presentation/widgets/analytics_skeleton.dart';
import 'package:fin_track_ai/features/analytics/presentation/widgets/category_expense_tile.dart';
import 'package:fin_track_ai/features/currency/domain/models/app_currency.dart';
import 'package:fin_track_ai/features/transactions/domain/models/transaction_model.dart';
import 'package:fin_track_ai/features/transactions/presentation/utils/transaction_category_extension.dart';
import 'package:fin_track_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget createAnalyticsApp({
  required AsyncValue<AnalyticsSummary> summaryState,
  AnalyticsPeriod? initialPeriod,
  Locale locale = const Locale('en'),
  ProviderContainer? container,
  Key? key,
}) {
  final overrides = [
    analyticsSummaryProvider.overrideWith((ref) => summaryState),
    if (initialPeriod != null)
      analyticsPeriodProvider.overrideWith((ref) => initialPeriod),
  ];

  if (container != null) {
    return UncontrolledProviderScope(
      key: key,
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const AnalyticsScreen(),
      ),
    );
  }

  return ProviderScope(
    key: key ?? UniqueKey(),
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const AnalyticsScreen(),
    ),
  );
}

void main() {
  final emptySummaryMonth = AnalyticsSummary(
    period: AnalyticsPeriod.month,
    currency: AppCurrency.usd,
    incomeMinor: 0,
    expenseMinor: 0,
    categories: const [],
    transactionCount: 0,
  );

  final sampleSummary = AnalyticsSummary(
    period: AnalyticsPeriod.month,
    currency: AppCurrency.usd,
    incomeMinor: 5200,
    expenseMinor: 1840,
    categories: const [
      CategoryExpense(
        category: TransactionCategory.food,
        amountMinor: 8500,
        share: 0.75,
      ),
      CategoryExpense(
        category: TransactionCategory.shopping,
        amountMinor: 2500,
        share: 0.25,
      ),
    ],
    transactionCount: 2,
  );

  group('AnalyticsScreen', () {
    testWidgets('1. chips show Week, Month, 12 Months in EN and Arabic in AR', (
      tester,
    ) async {
      await tester.pumpWidget(
        createAnalyticsApp(
          summaryState: AsyncData(emptySummaryMonth),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('12 Months'), findsOneWidget);

      await tester.pumpWidget(
        createAnalyticsApp(
          summaryState: AsyncData(emptySummaryMonth),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أسبوع'), findsOneWidget);
      expect(find.text('شهر'), findsOneWidget);
      expect(find.text('12 شهراً'), findsOneWidget);
    });

    testWidgets(
      '2. chip matching analyticsPeriodProvider is selected (default: Month)',
      (tester) async {
        await tester.pumpWidget(
          createAnalyticsApp(summaryState: AsyncData(emptySummaryMonth)),
        );
        await tester.pumpAndSettle();

        final selectedChip = tester.widget<ChoiceChip>(
          find.byWidgetPredicate((w) => w is ChoiceChip && w.selected),
        );
        expect((selectedChip.label as Text).data, equals('Month'));
      },
    );

    testWidgets(
      '3. tapping Week chip sets analyticsPeriodProvider to AnalyticsPeriod.week',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            analyticsSummaryProvider.overrideWith(
              (ref) => AsyncData(emptySummaryMonth),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          createAnalyticsApp(
            summaryState: AsyncData(emptySummaryMonth),
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();

        expect(
          container.read(analyticsPeriodProvider),
          equals(AnalyticsPeriod.week),
        );
      },
    );

    testWidgets(
      r'4. income card shows +$52.00 in successColor and expense card -$18.40 in errorColor',
      (tester) async {
        await tester.pumpWidget(
          createAnalyticsApp(summaryState: AsyncData(sampleSummary)),
        );
        await tester.pumpAndSettle();

        final incomeTextFinder = find.text(r'+$52.00');
        expect(incomeTextFinder, findsOneWidget);
        final incomeText = tester.widget<Text>(incomeTextFinder);
        expect(incomeText.style?.color, ColorManager.successColor);

        final expenseTextFinder = find.text(r'-$18.40');
        expect(expenseTextFinder, findsOneWidget);
        final expenseText = tester.widget<Text>(expenseTextFinder);
        expect(expenseText.style?.color, ColorManager.errorColor);
      },
    );

    testWidgets('5. null income and expense show em-dash', (tester) async {
      final summaryWithNulls = AnalyticsSummary(
        period: AnalyticsPeriod.month,
        currency: AppCurrency.usd,
        incomeMinor: null,
        expenseMinor: null,
        categories: const [],
        transactionCount: 1,
      );

      await tester.pumpWidget(
        createAnalyticsApp(summaryState: AsyncData(summaryWithNulls)),
      );
      await tester.pumpAndSettle();

      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets(
      '6. categories render localized names, formatted amounts and percentages in order',
      (tester) async {
        await tester.pumpWidget(
          createAnalyticsApp(summaryState: AsyncData(sampleSummary)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Food'), findsOneWidget);
        expect(find.text(r'$85.00'), findsOneWidget);
        expect(find.text('75%'), findsOneWidget);

        expect(find.text('Shopping'), findsOneWidget);
        expect(find.text(r'$25.00'), findsOneWidget);
        expect(find.text('25%'), findsOneWidget);
      },
    );

    testWidgets(
      '7. category with null share shows amount but no LinearProgressIndicator or percentage',
      (tester) async {
        final summaryNullShare = AnalyticsSummary(
          period: AnalyticsPeriod.month,
          currency: AppCurrency.usd,
          incomeMinor: 0,
          expenseMinor: 5000,
          categories: const [
            CategoryExpense(
              category: TransactionCategory.food,
              amountMinor: 5000,
              share: null,
            ),
          ],
          transactionCount: 1,
        );

        await tester.pumpWidget(
          createAnalyticsApp(summaryState: AsyncData(summaryNullShare)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Food'), findsOneWidget);
        expect(find.text(r'$50.00'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.textContaining('%'), findsNothing);
      },
    );

    testWidgets('8. category with null amount shows em-dash', (tester) async {
      final summaryNullAmount = AnalyticsSummary(
        period: AnalyticsPeriod.month,
        currency: AppCurrency.usd,
        incomeMinor: 0,
        expenseMinor: 0,
        categories: const [
          CategoryExpense(
            category: TransactionCategory.transport,
            amountMinor: null,
            share: null,
          ),
        ],
        transactionCount: 1,
      );

      await tester.pumpWidget(
        createAnalyticsApp(summaryState: AsyncData(summaryNullAmount)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets(
      '9. transactionCount == 0 shows analyticsEmpty and no cards or category tiles',
      (tester) async {
        await tester.pumpWidget(
          createAnalyticsApp(summaryState: AsyncData(emptySummaryMonth)),
        );
        await tester.pumpAndSettle();

        expect(find.text('No transactions in this period.'), findsOneWidget);
        expect(find.byType(AnalyticsAmountCard), findsNothing);
        expect(find.byType(CategoryExpenseTile), findsNothing);
      },
    );

    testWidgets(
      '10. loading shows AnalyticsSkeleton and chips remain visible, and no CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(
          createAnalyticsApp(summaryState: const AsyncLoading()),
        );
        await tester.pump();

        expect(find.byType(AnalyticsSkeleton), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
        expect(find.text('12 Months'), findsOneWidget);
      },
    );

    testWidgets(
      '10b. AnalyticsSkeleton renders in Arabic without overflow exceptions',
      (tester) async {
        await tester.pumpWidget(
          createAnalyticsApp(
            summaryState: const AsyncLoading(),
            locale: const Locale('ar'),
          ),
        );
        await tester.pump();

        expect(find.byType(AnalyticsSkeleton), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '11. error shows localized error message and chips remain visible',
      (tester) async {
        await tester.pumpWidget(
          createAnalyticsApp(
            summaryState: AsyncError(
              TransactionException(TransactionErrorType.networkError),
              StackTrace.empty,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Network error. Please check your connection.'),
          findsOneWidget,
        );
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
        expect(find.text('12 Months'), findsOneWidget);
      },
    );

    testWidgets('12. window note appears only when summary period is year', (
      tester,
    ) async {
      await tester.pumpWidget(
        createAnalyticsApp(summaryState: AsyncData(sampleSummary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('History available: last 12 months'), findsNothing);

      final yearSummary = AnalyticsSummary(
        period: AnalyticsPeriod.year,
        currency: AppCurrency.usd,
        incomeMinor: 5200,
        expenseMinor: 1840,
        categories: sampleSummary.categories,
        transactionCount: 2,
      );

      await tester.pumpWidget(
        createAnalyticsApp(summaryState: AsyncData(yearSummary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('History available: last 12 months'), findsOneWidget);
    });

    testWidgets(
      '13. Arabic locale renders full screen without overflow exceptions',
      (tester) async {
        final arabicSummary = AnalyticsSummary(
          period: AnalyticsPeriod.year,
          currency: AppCurrency.usd,
          incomeMinor: 99999900,
          expenseMinor: 99999900,
          categories: TransactionCategory.values
              .map(
                (c) => CategoryExpense(
                  category: c,
                  amountMinor: 16666650,
                  share: 0.166,
                ),
              )
              .toList(),
          transactionCount: 100,
        );

        await tester.pumpWidget(
          createAnalyticsApp(
            summaryState: AsyncData(arabicSummary),
            locale: const Locale('ar'),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('15. category tile shows category.icon', (tester) async {
      await tester.pumpWidget(
        createAnalyticsApp(summaryState: AsyncData(sampleSummary)),
      );
      await tester.pumpAndSettle();

      final tileIconFinder = find.descendant(
        of: find.byType(CategoryExpenseTile).first,
        matching: find.byType(Icon),
      );
      expect(tileIconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(tileIconFinder);
      expect(iconWidget.icon, equals(TransactionCategory.food.icon));
    });
  });
}
