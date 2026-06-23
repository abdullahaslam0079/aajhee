import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/routing/app_navigation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 3), _bootstrapAndContinue);
  }

  Future<void> _bootstrapAndContinue() async {
    try {
      await ref.read(locationProvider.notifier).determineAddress();
    } catch (_) {}

    if (!mounted) return;
    await navigateFromSplash(context, ref);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 52,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Goluto',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover your city with ease',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
