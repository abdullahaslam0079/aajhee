import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/features/splash/presentation/widgets/goluto_splash_logo.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/routing/app_navigation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashDuration = Duration(seconds: 10);

  Timer? _splashTimer;
  var _splashTimerComplete = false;
  var _bootstrapComplete = false;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(_splashDuration, _onSplashTimerComplete);
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    try {
      await ref.read(locationProvider.notifier).determineAddress();
    } catch (_) {}

    if (!mounted) return;
    _bootstrapComplete = true;
    _tryNavigate();
  }

  void _onSplashTimerComplete() {
    if (_splashTimerComplete) return;
    _splashTimerComplete = true;
    _tryNavigate();
  }

  Future<void> _tryNavigate() async {
    if (!_splashTimerComplete || !_bootstrapComplete || !mounted) return;
    await navigateFromSplash(context, ref);
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      body: const Center(
        child: GolutoSplashLogo(),
      ),
    );
  }
}
