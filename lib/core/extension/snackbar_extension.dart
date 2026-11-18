import 'package:flutter/material.dart';

import '../constant/color_manager.dart';

extension SnackbarExtension on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: ColorManager.white),
        ),
        backgroundColor: ColorManager.errorColor,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: ColorManager.white),
        ),
        backgroundColor: ColorManager.successColor,
      ),
    );
  }
}
