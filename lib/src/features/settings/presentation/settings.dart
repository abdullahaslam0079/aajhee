import 'package:aajhee/src/config/app_web_links.dart';
import 'package:aajhee/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notification_preferences_provider.dart';
import 'package:aajhee/src/features/settings/data/services/user_profile_service.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/theme_preferences_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _deletingAccount = false;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;
    final defaultAddress =
        ref.watch(savedAddressesProvider).selectedAddress?.shortLabel;
    final pushPrefs = ref.watch(notificationPreferencesProvider);
    final themePrefs = ref.watch(themePreferencesProvider);
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final pagePadding = AppSpacing.pagePadding.w;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pagePadding,
                  AppSpacing.ml.h,
                  pagePadding,
                  AppSpacing.sm.h,
                ),
                child: Text(
                  'Profile',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: _ProfileHeader(
                  name: profile.displayName,
                  email: profile.email,
                  location: defaultAddress,
                  colorScheme: colorScheme,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: const _SectionTitle(label: 'Account'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      iconColor: colorScheme.primary,
                      title: 'Edit profile',
                      subtitle: 'Name & email',
                      onTap: () => context.push(AppRoutes.editProfile),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.location_on_outlined,
                      iconColor: colorScheme.secondary,
                      title: 'Addresses',
                      subtitle: 'Delivery locations',
                      onTap: () => context.push(AppRoutes.addresses),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.ml.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: const _SectionTitle(label: 'Preferences'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      iconColor: colorScheme.primary,
                      title: 'Push notifications',
                      subtitle: 'Orders & shopping updates',
                      trailing: Switch.adaptive(
                        value: pushPrefs.pushEnabled,
                        onChanged: pushPrefs.isSaving
                            ? null
                            : (v) => ref
                                .read(
                                  notificationPreferencesProvider.notifier,
                                )
                                .setPushEnabled(v),
                      ),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.brightness_6_outlined,
                      iconColor: colorScheme.secondary,
                      title: 'Appearance',
                      subtitle: themePrefs.preference.label,
                      onTap: () => _pickTheme(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.ml.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: const _SectionTitle(label: 'Shopping'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: colorScheme.primary,
                      title: 'Cart',
                      onTap: () => context.push(AppRoutes.cart),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.receipt_long_outlined,
                      iconColor: colorScheme.secondary,
                      title: 'My orders',
                      onTap: () => context.push(AppRoutes.orders),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.ml.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: const _SectionTitle(label: 'Support'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: colorScheme.primary,
                      title: 'Help center',
                      onTap: () => AppWebLinks.openHelp(),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: colorScheme.secondary,
                      title: 'Contact us',
                      onTap: () => AppWebLinks.openContact(),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.policy_outlined,
                      iconColor: colorScheme.secondary,
                      title: 'Privacy policy',
                      onTap: () => AppWebLinks.openPrivacy(),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      iconColor: colorScheme.onSurfaceVariant,
                      title: 'Terms of service',
                      onTap: () => AppWebLinks.openTerms(),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.ml.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: colorScheme.primary,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      showChevron: false,
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: colorScheme.error,
                      title: 'Log out',
                      titleColor: colorScheme.error,
                      showChevron: false,
                      onTap: () => _confirmLogout(context),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      iconColor: colorScheme.error,
                      title: _deletingAccount
                          ? 'Deleting account…'
                          : 'Delete account',
                      titleColor: colorScheme.error,
                      showChevron: false,
                      onTap: _deletingAccount
                          ? null
                          : () => _confirmDeleteAccount(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl.h)),
          ],
        ),
      ),
    );
  }

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
    final result = await UserProfileService.instance.deleteAccount();
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
        await AuthService.instance.logout();
        if (!mounted) return;
        setState(() => _deletingAccount = false);
        if (!context.mounted) return;
        context.go(AppRoutes.login);
      },
    );
  }

  Widget _divider(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56.w,
      endIndent: AppSpacing.md.w,
      color: cs.outlineVariant,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.location,
    required this.colorScheme,
  });

  final String name;
  final String email;
  final String? location;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final muted = colorScheme.onSurfaceVariant;

    return Material(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.lg,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.ml.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                height: 1.2,
              ),
            ),
            if (email.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm.h),
              _ProfileMetaRow(
                icon: Icons.mail_outline_rounded,
                label: email,
                muted: muted,
                textStyle: tt.bodyMedium,
              ),
            ],
            if (location != null && location!.isNotEmpty) ...[
              SizedBox(height: AppSpacing.md.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.ms.w,
                  vertical: AppSpacing.sm.h,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                  borderRadius: AppBorders.md,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: _ProfileMetaRow(
                  icon: Icons.location_on_outlined,
                  label: location!,
                  muted: muted,
                  textStyle: tt.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileMetaRow extends StatelessWidget {
  const _ProfileMetaRow({
    required this.icon,
    required this.label,
    required this.muted,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final Color muted;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: muted),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            label,
            style: textStyle?.copyWith(
              color: muted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cs = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: AppSpacing.xs.w),
      child: Text(
        label,
        style: tt.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.lg,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cs = context.theme.colorScheme;
    final effectiveTitleColor = titleColor ?? cs.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: AppSpacing.ms.h,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: AppBorders.md,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: AppSpacing.ms.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: effectiveTitleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      subtitle!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: cs.outline,
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}
