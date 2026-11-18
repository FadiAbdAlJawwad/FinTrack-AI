import '../../../../core/routing/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/constant/images_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../currency/presentation/utils/money_format.dart';
import '../widgets/home_action_card.dart';
import '../state/dashboard_controller.dart';
import '../widgets/home_skeleton.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../features/transactions/presentation/utils/error_message.dart';
import '../../../transactions/presentation/utils/transaction_group_label.dart';
import '../../../../features/transactions/presentation/widgets/add_transaction_bottom_sheet.dart';
import '../../../../features/transactions/presentation/widgets/transaction_list_tile.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  String getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.loc.goodMorning;
    if (hour < 18) return context.loc.goodAfternoon;
    return context.loc.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final user = ref.watch(currentUserProvider);
    final isAiAvailable = ref.watch(aiFeatureAvailableProvider);

    final userName = (user == null || user.fullName.isEmpty)
        ? 'User'
        : user.fullName;

    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(child: Image.asset(ImagesManager.userAvatar))
            .padStart(20),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getGreeting(context), style: context.labelSmall),
            Text(
              userName,
              style: context.labelLarge.copyWith(
                color: ColorManager.secondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const HomeSkeleton(),
        error: (error, stack) =>
            Center(child: Text(errorMessage(context, error))),
        data: (state) => SingleChildScrollView(
          child: Column(
            children: [
              context.addVerticalSpace(16),
              Card(
                color: ColorManager.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.loc.totalBalance,
                          style: context.bodyMedium.copyWith(
                            color: ColorManager.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const Icon(Icons.more_horiz, color: ColorManager.white),
                      ],
                    ),
                    context.addVerticalSpace(8),
                    Text(
                      state.balanceMinor == null
                          ? '—'
                          : formatMoney(state.balanceMinor!, state.currency),
                      style: context.displayLarge.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ).pad(24),
              ),
              context.addVerticalSpace(24),
              Row(
                children: [
                  HomeActionCard(
                    icon: Icons.camera_alt,
                    label: context.loc.scan,
                    onTap: () {},
                  ),
                  context.addHorizontalSpace(12),
                  HomeActionCard(
                    icon: Icons.mic,
                    label: context.loc.voice,
                    onTap: () {
                      if (isAiAvailable) {
                        context.pushNamed(AppRoutes.voiceEntryName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.loc.aiNotConfigured)),
                        );
                      }
                    },
                  ),
                  context.addHorizontalSpace(12),
                  HomeActionCard(
                    icon: Icons.add,
                    label: context.loc.manual,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddTransactionBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
              context.addVerticalSpace(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.loc.recentTransactions,
                    style: context.labelLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(AppRoutes.transactionsScreenName);
                    },
                    child: Text(context.loc.seeAll, style: context.bodyMedium),
                  ),
                ],
              ),
              context.addVerticalSpace(16),
              if (state.groupedTransactions.isEmpty)
                Center(child: Text(context.loc.emptyTransactions))
              else
                Column(
                  children: state.groupedTransactions.entries.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.key.label(context.loc),
                          style: context.labelSmall.copyWith(
                            color: ColorManager.secondaryColor,
                          ),
                        ),
                        context.addVerticalSpace(8),
                        ListView.separated(
                          itemCount: group.value.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              context.addVerticalSpace(8),
                          itemBuilder: (context, index) {
                            return TransactionListTile(
                              transaction: group.value[index],
                            );
                          },
                        ),
                        context.addVerticalSpace(16),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ).padSymmetric(20).padVerticalSymmetric(15),
        ),
      ),
    );
  }
}
