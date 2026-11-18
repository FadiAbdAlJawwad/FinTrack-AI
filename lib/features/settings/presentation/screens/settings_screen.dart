import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extension/app_sizes.dart';
import '../widgets/app_preferences_section.dart';
import '../widgets/logout_button.dart';
import '../widgets/security_section.dart';
import '../widgets/settings_profile_header.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.loc.navSettings), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            context.addVerticalSpace(16),
            const SettingsProfileHeader(),
            context.addVerticalSpace(24),
            const AppPreferencesSection(),
            context.addVerticalSpace(20),
            const SecuritySection(),
            context.addVerticalSpace(32),
            const LogoutButton(),
            context.addVerticalSpace(24),
          ],
        ).padSymmetric(20),
      ),
    );
  }
}
