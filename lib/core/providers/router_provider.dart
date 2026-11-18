import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/firebase_providers.dart';
import '../providers/shared_prefs_provider.dart';
import '../routing/router_generator.dart';
import '../routing/app_lock_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return RouteGenerator.build(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    prefs: ref.watch(sharedPrefsProvider),
    lock: ref.watch(appLockNotifierProvider),
  );
});
