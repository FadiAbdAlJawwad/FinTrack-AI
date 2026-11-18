import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constant/shared_prefs_keys.dart';
import '../../../../core/providers/shared_prefs_provider.dart';
import '../../../../core/extension/app_sizes.dart';
import '../../../../core/extension/text_style_extension.dart';
import '../../../../core/routing/app_routes.dart';
import '../viewmodels/onboarding_view_model.dart';
import '../widgets/slider_indicator.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentIndex = useState(0);
    final list = onboardingList(context);
    useListenable(pageController);

    Future<void> finishOnboarding() async {
      final prefs = ref.read(sharedPrefsProvider);
      await prefs.setBool(SharedPrefsKeys.hasSeenOnboardingKey, true);
      if (context.mounted) {
        context.goNamed(AppRoutes.loginName);
      }
    }

    void nextPage() {
      if (currentIndex.value < list.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        finishOnboarding();
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: finishOnboarding,
                  child: Text(
                    context.loc.skip,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) => currentIndex.value = index,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    list[index].image!,
                    fit: BoxFit.contain,
                  ).padSymmetric(20);
                },
              ),
            ),

            Expanded(
              flex: 2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                reverseDuration: const Duration(milliseconds: 100),
                child: Column(
                  key: ValueKey<int>(currentIndex.value),
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      list[currentIndex.value].title!,
                      style: context.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    context.addVerticalSpace(16),
                    Text(
                      list[currentIndex.value].body!,
                      style: context.bodyMedium,
                      textAlign: TextAlign.center,
                    ).padSymmetric(20),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      list.length,
                      (index) => SliderIndicator(
                        selected: currentIndex.value == index,
                        currentPage: index,
                      ).padSymmetric(4),
                    ),
                  ),
                  context.addVerticalSpace(32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: currentIndex.value == list.length - 1
                          ? finishOnboarding
                          : nextPage,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          currentIndex.value == list.length - 1
                              ? context.loc.getStarted
                              : context.loc.next,
                          key: ValueKey<int>(currentIndex.value),
                        ),
                      ),
                    ),
                  ),
                  context.addVerticalSpace(16),
                ],
              ),
            ),
          ],
        ).padSymmetric(20),
      ),
    );
  }
}
