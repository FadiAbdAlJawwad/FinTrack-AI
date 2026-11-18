import 'package:flutter/material.dart';

import '../../../../core/constant/color_manager.dart';
import '../../../../core/extension/app_sizes.dart';

Future<bool> showLogoutConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const LogoutConfirmDialog(),
  );
  return result ?? false;
}

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.logoutConfirmTitle),
      content: Text(context.loc.logoutConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.loc.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: ColorManager.errorColor),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.loc.logout),
        ),
      ],
    );
  }
}
