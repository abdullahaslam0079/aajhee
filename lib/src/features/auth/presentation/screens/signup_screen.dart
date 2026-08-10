/// Deprecated: consumer auth is phone-only. Kept to avoid stale imports.
library;

import 'package:flutter/material.dart';
import 'package:goluto/src/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(AppRoutes.login);
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
