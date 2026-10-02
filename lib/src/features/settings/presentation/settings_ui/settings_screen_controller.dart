part of 'package:aajhee/src/features/settings/presentation/settings.dart';

mixin SettingsScreenController on ConsumerState<SettingsScreen> {
  bool _deletingAccount = false;

  Future<void> _pickTheme(BuildContext context) async {
    final current = ref.read(themePreferencesProvider).preference;
    final selected = await showModalBottomSheet<AppThemePreference>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in AppThemePreference.values)
                ListTile(
                  title: Text(option.label),
                  trailing: option == current
                      ? Icon(
                          Icons.check_rounded,
                          color: sheetContext.theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == current) return;
    await ref.read(themePreferencesProvider.notifier).setPreference(selected);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Log out',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false) || !context.mounted) return;

    await ref.read(authControllerProvider.notifier).logout(context: context);
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently removes your profile and sign-in from Aajhee. '
          'Past orders may be retained by shops for their records. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false) || !context.mounted) return;

    setState(() => _deletingAccount = true);
    final result = await ref.read(userProfileServiceProvider).deleteAccount();
    if (!mounted) return;

    await result.fold(
      (failure) async {
        setState(() => _deletingAccount = false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) async {
        // Invalidate FCM before wiping the local session (backend already
        // deleted DeviceToken rows with the account).
        await PushNotificationService.instance.clearOnSessionEnd();
        await AuthService.instance.logout();
        if (!mounted) return;
        setState(() => _deletingAccount = false);
        if (!context.mounted) return;
        context.go(AppRoutes.login);
      },
    );
  }
}
