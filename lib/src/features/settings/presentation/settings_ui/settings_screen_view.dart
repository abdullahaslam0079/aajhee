part of 'package:aajhee/src/features/settings/presentation/settings.dart';

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SettingsScreenController {
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
                  contact: profile.contactDisplay,
                  isPhoneContact: profile.isPhoneAccount,
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
                      subtitle: profile.isPhoneAccount
                          ? 'Name & phone'
                          : 'Name & email',
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
                      title: 'Order & account updates',
                      subtitle: 'Push for orders, status, and replies',
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
                      icon: Icons.local_offer_outlined,
                      iconColor: colorScheme.tertiary,
                      title: 'Offers from saved stores',
                      subtitle: pushPrefs.pushEnabled
                          ? 'New offers from stores you like'
                          : 'Turn on order updates to enable',
                      trailing: Switch.adaptive(
                        value: pushPrefs.pushEnabled &&
                            pushPrefs.marketingPushEnabled,
                        onChanged:
                            (!pushPrefs.pushEnabled || pushPrefs.isSaving)
                                ? null
                                : (v) => ref
                                    .read(
                                      notificationPreferencesProvider.notifier,
                                    )
                                    .setMarketingPushEnabled(v),
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
