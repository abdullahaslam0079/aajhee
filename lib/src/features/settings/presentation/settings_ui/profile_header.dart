part of 'package:aajhee/src/features/settings/presentation/settings.dart';

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.contact,
    required this.isPhoneContact,
    required this.location,
    required this.colorScheme,
  });

  final String name;
  final String? contact;
  final bool isPhoneContact;
  final String? location;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final muted = colorScheme.onSurfaceVariant;
    final contactLabel = contact?.trim() ?? '';

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
            if (contactLabel.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm.h),
              _ProfileMetaRow(
                icon: isPhoneContact
                    ? Icons.phone_outlined
                    : Icons.mail_outline_rounded,
                label: contactLabel,
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
