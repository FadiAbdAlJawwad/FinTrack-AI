import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
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

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isBiometricOptIn = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final authState = ref.watch(authControllerProvider);

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
                    Text(
                      context.loc.signupTitle,
                      style: context.headlineMedium,
                    ),
                    context.addVerticalSpace(8),
                    Text(context.loc.signupBody, style: context.bodyMedium),
                    context.addVerticalSpace(32),
                    TextFormField(
                      controller: fullNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: context.loc.fullName,
                      ),
                      validator: (value) => value?.validateName(context),
                    ),
                    context.addVerticalSpace(16),
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
                      obscureText: !isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: context.loc.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: ColorManager.secondaryColor,
                          ),
                          onPressed: () => isPasswordVisible.value =
                              !isPasswordVisible.value,
                        ),
                      ),
                      validator: (value) => value?.validatePassword(context),
                    ),
                    context.addVerticalSpace(8),
                    CheckboxListTile(
                      value: isBiometricOptIn.value,
                      onChanged: (val) => isBiometricOptIn.value = val ?? false,
                      title: Text(context.loc.enableBiometricLogin),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
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
                                      .read(authControllerProvider.notifier)
                                      .register(
                                        fullNameController.text.trim(),
                                        emailController.text.trim(),
                                        passwordController.text,
                                        isBiometricOptIn:
                                            isBiometricOptIn.value,
                                      );
                                }
                              },
                        child: Text(context.loc.signup),
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                          : () => context.goNamed(AppRoutes.loginName),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.loc.haveAccount,
                            style: const TextStyle(
                              color: ColorManager.secondaryColor,
                            ),
                          ),
                          context.addHorizontalSpace(8),
                          Text(context.loc.login),
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
