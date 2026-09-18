import 'package:aajhee/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notification_preferences_provider.dart';
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
  bool _emailUpdates = false;

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
                child: _SectionTitle(label: 'Account'),
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
                child: _SectionTitle(label: 'Preferences'),
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
                      subtitle: 'Orders & offers',
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
                      icon: Icons.mail_outline_rounded,
                      iconColor: colorScheme.secondary,
                      title: 'Email updates',
                      subtitle: 'News & tips',
                      trailing: Switch.adaptive(
                        value: _emailUpdates,
                        onChanged: (v) => setState(() => _emailUpdates = v),
                      ),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.brightness_6_outlined,
                      iconColor: colorScheme.primary,
                      title: 'Appearance',
                      subtitle: themePrefs.preference.label,
                      onTap: () => _showAppearanceSheet(context, themePrefs),
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      iconColor: colorScheme.secondary,
                      title: 'Language',
                      subtitle: 'English (US)',
                      showChevron: false,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.ml.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: _SectionTitle(label: 'Support'),
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
                      onTap: () {},
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: colorScheme.secondary,
                      title: 'Contact us',
                      onTap: () {},
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.policy_outlined,
                      iconColor: colorScheme.secondary,
                      title: 'Privacy policy',
                      onTap: () {},
                    ),
                    _divider(context),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      iconColor: colorScheme.onSurfaceVariant,
                      title: 'Terms of service',
                      onTap: () {},
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
                      onTap: () {},
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

  Future<void> _showAppearanceSheet(
    BuildContext context,
    ThemePreferencesState themePrefs,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final cs = sheetContext.theme.colorScheme;
        final tt = sheetContext.theme.textTheme;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.ms.w,
              0,
              AppSpacing.ms.w,
              AppSpacing.md.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  'Uses your phone setting by default.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.sm.h),
                ...AppThemePreference.values.map((option) {
                  final selected = themePrefs.preference == option;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      switch (option) {
                        AppThemePreference.system =>
                          Icons.brightness_auto_rounded,
                        AppThemePreference.light => Icons.light_mode_rounded,
                        AppThemePreference.dark => Icons.dark_mode_rounded,
                      },
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    title: Text(
                      option.label,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_rounded, color: cs.primary)
                        : null,
                    onTap: themePrefs.isSaving
                        ? null
                        : () async {
                            Navigator.pop(sheetContext);
                            await ref
                                .read(themePreferencesProvider.notifier)
                                .setPreference(option);
                          },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your account.'),
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
