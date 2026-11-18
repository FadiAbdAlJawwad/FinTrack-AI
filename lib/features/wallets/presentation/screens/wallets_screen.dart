import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../transactions/presentation/utils/error_message.dart';
import '../state/wallets_overview_provider.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/wallets_overview_view.dart';
import '../widgets/wallets_skeleton.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(walletsOverviewProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.navWallets), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddWalletSheet(context),
        backgroundColor: ColorManager.primaryBlue,
        foregroundColor: ColorManager.white,
        child: const Icon(Icons.add),
      ),
      body: overviewAsync.when(
        loading: () => const WalletsSkeleton(),
        error: (error, _) => Center(child: Text(errorMessage(context, error))),
        data: (overview) => WalletsOverviewView(overview: overview),
      ),
    );
  }
}
