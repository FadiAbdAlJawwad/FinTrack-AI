import 'package:flutter/material.dart';

import '../extension/app_sizes.dart';
import 'ai_parsing_exception.dart';

extension AiParsingExceptionExtension on AiParsingException {
  String getLocalizedMessage(BuildContext context) {
    return switch (type) {
      AiParsingErrorType.notConfigured => context.loc.aiNotConfigured,
      AiParsingErrorType.unauthorized => context.loc.aiUnauthorized,
      AiParsingErrorType.invalidInput => context.loc.aiInvalidInput,
      AiParsingErrorType.serviceUnavailable => context.loc.aiServiceUnavailable,
      AiParsingErrorType.schemaValidationFailed =>
        context.loc.aiSchemaValidationFailed,
      AiParsingErrorType.networkError => context.loc.aiNetworkError,
      AiParsingErrorType.unknown => context.loc.aiUnknown,
    };
  }
}
