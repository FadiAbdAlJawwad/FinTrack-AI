import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../../core/constant/images_manager.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/routing/app_routes.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 2500),
    );

    final slideAnimation = useMemoized(
      () =>
          Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
              parent: animationController,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
            ),
          ),
      [animationController],
    );

    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
      ),
      [animationController],
    );

    final textFadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
        ),
      ),
      [animationController],
    );

    useEffect(() {
      FlutterNativeSplash.remove();
      animationController.forward();

      void listener(AnimationStatus status) async {
        if (status == AnimationStatus.completed) {
          await Future.delayed(const Duration(milliseconds: 800));
          if (context.mounted) {
            context.goNamed(AppRoutes.onboardingName);
          }
        }
      }

      animationController.addStatusListener(listener);
      return () => animationController.removeStatusListener(listener);
    }, [animationController]);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Image.asset(
                    ImagesManager.finTrackAILogo,
                    width: context.wp(40),
                  ),
                ),
              ),
              FadeTransition(
                opacity: textFadeAnimation,
                child: Column(
                  children: [
                    Text(context.loc.appTitle, style: context.headlineMedium),
                    context.addVerticalSpace(8),
                    Text(context.loc.splashBody, style: context.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
