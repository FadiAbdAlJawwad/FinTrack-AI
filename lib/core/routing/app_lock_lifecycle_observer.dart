import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/shared_prefs_keys.dart';
import 'app_lock_notifier.dart';

class AppLockLifecycleObserver extends StatefulWidget {
  final Widget child;
  final AppLockNotifier appLockNotifier;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences prefs;
  final DateTime Function() getCurrentTime;

  const AppLockLifecycleObserver({
    super.key,
    required this.child,
    required this.appLockNotifier,
    required this.firebaseAuth,
    required this.prefs,
    this.getCurrentTime = _defaultGetCurrentTime,
  });

  static DateTime _defaultGetCurrentTime() => DateTime.now();

  @override
  State<AppLockLifecycleObserver> createState() =>
      _AppLockLifecycleObserverState();
}

class _AppLockLifecycleObserverState extends State<AppLockLifecycleObserver>
    with WidgetsBindingObserver {
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedTime = widget.getCurrentTime();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null) {
        final elapsed = widget.getCurrentTime().difference(_pausedTime!);
        if (elapsed > AppLockNotifier.lockTimeout) {
          final isSignedOut = widget.firebaseAuth.currentUser == null;
          final isBiometricEnabled =
              widget.prefs.getBool(SharedPrefsKeys.isBiometricEnabledKey) ??
              false;
          if (!isSignedOut && isBiometricEnabled) {
            widget.appLockNotifier.lock();
          }
        }
      }
      _pausedTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
