import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constant/color_manager.dart';
import '../../../../core/constant/images_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/extension/string_validation.dart';
import '../../../../core/extension/snackbar_extension.dart';
import '../../../../core/error/auth_exception_extension.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../state/reset_password_controller.dart';

class ResetPassword extends HookConsumerWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final authState = ref.watch(resetPasswordControllerProvider);

    ref.listen<AsyncValue<void>>(resetPasswordControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stack) {
          final errorMessage = authErrorMessage(context, error);
          context.showErrorSnackBar(errorMessage);
        },
        data: (_) {
          if (previous is AsyncLoading) {
            context.showSuccessSnackBar(context.loc.resetPasswordSuccess);
            if (context.mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.homeScreenName);
              }
            }
          }
        },
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    context.addVerticalSpace(64),
                    Image.asset(ImagesManager.finTrackAILogo),
                    context.addVerticalSpace(24),
                    Text(
                      context.loc.resetPassword,
                      style: context.headlineMedium,
                    ),
                    context.addVerticalSpace(8),
                    Text(
                      context.loc.resetPasswordBody,
                      style: context.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    context.addVerticalSpace(32),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email,
                          color: ColorManager.secondaryColor,
                        ),
                        labelText: context.loc.email,
                      ),
                      validator: (value) => value?.validateEmail(context),
                    ),
                    context.addVerticalSpace(24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  ref
                                      .read(
                                        resetPasswordControllerProvider
                                            .notifier,
                                      )
                                      .resetPassword(
                                        emailController.text.trim(),
                                      );
                                }
                              },
                        child: Text(context.loc.sendResetLink),
                      ),
                    ),
                    context.addVerticalSpace(24),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.pop(),
                      child: Text(context.loc.backToLogin),
                    ),
                  ],
                ).padSymmetric(20),
              ),
            ),
          ),
          if (authState.isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
