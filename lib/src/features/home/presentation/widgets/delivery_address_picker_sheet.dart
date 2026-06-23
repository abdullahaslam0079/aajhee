import 'package:goluto/src/features/settings/domain/entities/saved_address.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

Future<void> showDeliveryAddressPicker(BuildContext context, WidgetRef ref) {
  return context.showAppBottomSheet(
    isScrollControlled: true,
    builder: (_) => const DeliveryAddressPickerSheet(),
  );
}

class DeliveryAddressPickerSheet extends ConsumerWidget {
  const DeliveryAddressPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final addressesState = ref.watch(savedAddressesProvider);
    final addresses = addressesState.addresses;
    final selected = addressesState.selectedAddress;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: AppBorders.bottomSheet,
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.sm.h),
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: AppBorders.full,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding.w,
                  AppSpacing.md.h,
                  AppSpacing.pagePadding.w,
                  AppSpacing.sm.h,
                ),
                child: Text(
                  'Delivery address',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (addressesState.isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (addresses.isEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding.w,
                    AppSpacing.sm.h,
                    AppSpacing.pagePadding.w,
                    AppSpacing.lg.h,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 48,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        'No saved addresses yet',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        'Add a delivery address to get started.',
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      AppButton(
                        label: 'Add address',
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(AppRoutes.addAddress);
                        },
                        isFullWidth: true,
                      ),
                    ],
                  ),
                )
              else ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding.w,
                    ),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.xs.h),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final isSelected = address.id == selected?.id;

                      return _AddressPickerTile(
                        address: address,
                        isSelected: isSelected,
                        onTap: () async {
                          await ref
                              .read(savedAddressesProvider.notifier)
                              .setDefault(address.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding.w,
                    AppSpacing.md.h,
                    AppSpacing.pagePadding.w,
                    AppSpacing.lg.h,
                  ),
                  child: AppButton(
                    label: 'Add new address',
                    variant: ButtonVariant.outline,
                    prefixIcon: const Icon(Icons.add_rounded, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.addAddress);
                    },
                    isFullWidth: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressPickerTile extends StatelessWidget {
  const _AddressPickerTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final SavedAddress address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Material(
      color: isSelected
          ? cs.primaryContainer.withValues(alpha: 0.45)
          : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.lg,
        side: BorderSide(
          color: isSelected ? cs.primary.withValues(alpha: 0.35) : cs.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md.r),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: isSelected ? cs.primary : cs.secondary,
              ),
              SizedBox(width: AppSpacing.ms.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.line1,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (address.line2.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        address.line2,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
