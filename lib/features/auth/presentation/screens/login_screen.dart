import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../state/auth_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final authState = ref.watch(authControllerProvider);
    final obscurePassword = useState(true);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          final errorMessage = authErrorMessage(context, error);
          context.showErrorSnackBar(errorMessage);
        },
        data: (_) {
          if (previous is AsyncLoading && context.mounted) {
            context.goNamed(AppRoutes.homeScreenName);
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
                  children: [
                    context.addVerticalSpace(32),
                    Image.asset(
                      ImagesManager.finTrackAILogo,
                      width: context.wp(40),
                    ),
                    Text(context.loc.loginTitle, style: context.headlineMedium),
                    context.addVerticalSpace(8),
                    Text(context.loc.loginBody, style: context.bodyMedium),
                    context.addVerticalSpace(32),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: context.loc.email),
                      validator: (value) => value?.validateEmail(context),
                    ),
                    context.addVerticalSpace(16),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: context.loc.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: ColorManager.secondaryColor,
                          ),
                          onPressed: () =>
                              obscurePassword.value = !obscurePassword.value,
                        ),
                      ),
                      validator: (value) => value?.validatePassword(context),
                    ),
                    context.addVerticalSpace(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              context.pushNamed(AppRoutes.resetPasswordName),
                          child: Text(context.loc.forgotPassword),
                        ),
                      ],
                    ),
                    context.addVerticalSpace(24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      ref
                                          .read(authControllerProvider.notifier)
                                          .login(
                                            emailController.text.trim(),
                                            passwordController.text,
                                            isBiometricOptIn: false,
                                          );
                                    }
                                  },
                            child: Text(context.loc.login),
                          ),
                        ),
                      ],
                    ),
                    context.addVerticalSpace(32),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: ColorManager.secondaryColor,
                            thickness: 1,
                          ),
                        ),
                        Text(context.loc.or).padSymmetric(16),
                        Expanded(
                          child: Divider(
                            color: ColorManager.secondaryColor,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    context.addVerticalSpace(32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        side: const BorderSide(color: ColorManager.primaryBlue),
                      ),
                      onPressed: authState.isLoading
                          ? null
                          : () => ref
                                .read(authControllerProvider.notifier)
                                .loginWithGoogle(isGoogleAuthTriggered: true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            ImagesManager.googleLogo,
                            height: 24,
                          ),
                          context.addHorizontalSpace(8),
                          Text(
                            context.loc.continueWithGoogle,
                            style: const TextStyle(
                              color: ColorManager.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    context.addVerticalSpace(32),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.pushNamed(AppRoutes.signupName),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.loc.dontHaveAccount,
                            style: const TextStyle(
                              color: ColorManager.secondaryColor,
                            ),
                          ),
                          context.addHorizontalSpace(8),
                          Text(context.loc.signup),
                        ],
                      ),
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
