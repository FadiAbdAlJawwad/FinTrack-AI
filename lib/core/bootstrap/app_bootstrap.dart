import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import 'boot_error_screen.dart';

/// Initializes core app services (Firebase and SharedPreferences) before
/// mounting the Riverpod ProviderScope and main application widget.
Future<SharedPreferences> runBootstrap({
  Future<void> Function()? initFirebase,
  Future<SharedPreferences> Function()? getPrefs,
  Duration timeout = const Duration(seconds: 10),
}) async {
  final initFB = initFirebase ?? _defaultInitFirebase;
  final getP = getPrefs ?? SharedPreferences.getInstance;

  return () async {
    try {
      await initFB();
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') {
        rethrow;
      }
    }
    return await getP();
  }().timeout(timeout);
}

Future<void> _defaultInitFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// A non-Riverpod root StatefulWidget that handles app initialization state.
///
/// Shows [SizedBox.shrink] while loading (keeping native splash preserved),
/// [BootErrorScreen] on failure with retry capability, and invokes [appBuilder]
/// once initialization succeeds.
class BootstrapApp extends StatefulWidget {
  const BootstrapApp({
    super.key,
    required this.bootstrap,
    required this.appBuilder,
  });

  final Future<SharedPreferences> Function() bootstrap;
  final Widget Function(SharedPreferences prefs) appBuilder;

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  SharedPreferences? _prefs;
  Object? _error;
  bool _isRetrying = false;
  int _attemptId = 0;

  @override
  void initState() {
    super.initState();
    _runBootstrap();
  }

  Future<void> _runBootstrap() async {
    final attempt = ++_attemptId;
    if (_error != null) {
      setState(() {
        _isRetrying = true;
      });
    }

    try {
      final prefs = await widget.bootstrap();
      if (!mounted || attempt != _attemptId) return;
      setState(() {
        _prefs = prefs;
        _error = null;
        _isRetrying = false;
      });
    } catch (e) {
      if (!mounted || attempt != _attemptId) return;
      setState(() {
        _error = e;
        _isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs != null) {
      return widget.appBuilder(_prefs!);
    }

    if (_error != null) {
      return BootErrorScreen(onRetry: _runBootstrap, isRetrying: _isRetrying);
    }

    return const SizedBox.shrink();
  }
}
