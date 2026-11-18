import 'package:flutter/material.dart';

import 'app_sizes.dart';

extension StringValidation on String {
  String? validateGeneric(BuildContext context, String fieldName) {
    if (trim().isEmpty) {
      return context.loc.fieldCannotBeEmpty;
    }
    return null;
  }

  String? validateName(BuildContext context) {
    if (isEmpty) {
      return context.loc.emptyName;
    }
    return null;
  }

  String? validateEmail(BuildContext context) {
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    if (isEmpty) {
      return context.loc.emptyEmail;
    } else if (!emailRegExp.hasMatch(this)) {
      return context.loc.invalidEmail;
    }
    return null;
  }

  String? validatePassword(BuildContext context) {
    if (isEmpty) {
      return context.loc.emptyPassword;
    } else if (length < 6) {
      return context.loc.invalidPassword;
    }
    return null;
  }

  String? validateNewPassword(BuildContext context, String currentPassword) {
    final baseError = validatePassword(context);
    if (baseError != null) return baseError;
    if (this == currentPassword) {
      return context.loc.passwordSameAsCurrent;
    }
    return null;
  }

  String? validateConfirmPassword(BuildContext context, String newPassword) {
    final baseError = validatePassword(context);
    if (baseError != null) return baseError;
    if (this != newPassword) {
      return context.loc.passwordsDoNotMatch;
    }
    return null;
  }
}
