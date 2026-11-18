import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extension/app_sizes.dart';
import '../../../transactions/presentation/utils/error_message.dart';
import '../state/analytics_providers.dart';
import '../widgets/analytics_content.dart';
import '../widgets/analytics_period_selector.dart';
import '../widgets/analytics_skeleton.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.navAnalytics), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          context.addVerticalSpace(16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AnalyticsPeriodSelector(),
          ),
          context.addVerticalSpace(16),
          Expanded(
            child: summaryAsync.when(
              loading: () => const AnalyticsSkeleton(),
              error: (error, _) =>
                  Center(child: Text(errorMessage(context, error))),
              data: (summary) => AnalyticsContent(summary: summary),
            ),
          ),
        ],
      ),
    );
  }
}
