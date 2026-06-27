import 'package:goluto/src/features/settings/data/services/address_geocoding_service.dart';
import 'package:goluto/src/features/settings/domain/entities/saved_address.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.theme.colorScheme;
    final pagePadding = AppSpacing.pagePadding.w;
    final addressesState = ref.watch(savedAddressesProvider);
    final addresses = addressesState.addresses;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Addresses'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addAddress),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
      body: SafeArea(
        child: addressesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : addresses.isEmpty
                ? _EmptyAddresses(
                    onAdd: () => context.push(AppRoutes.addAddress),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding,
                      AppSpacing.sm.h,
                      pagePadding,
                      96.h,
                    ),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm.h),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _AddressCard(
                        address: address,
                        onEdit: () => context.push(
                          AppRoutes.editAddress,
                          extra: address,
                        ),
                        onSetDefault: () => _setDefault(context, ref, address.id),
                        onDelete: () => _confirmDelete(context, ref, address.id),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref.read(savedAddressesProvider.notifier).setDefault(id);
      if (context.mounted) {
        showToast(context, message: 'Default address updated', status: 'success');
      }
    } on AddressValidationException catch (e) {
      if (context.mounted) {
        showToast(context, message: e.message, status: 'error');
      }
    } catch (_) {
      if (context.mounted) {
        showToast(
          context,
          message: 'Could not update default address. Please try again.',
          status: 'error',
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address?'),
        content: const Text(
          'This delivery location will be removed from your saved addresses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

    try {
      await ref.read(savedAddressesProvider.notifier).removeAddress(id);
      if (context.mounted) {
        showToast(context, message: 'Address removed', status: 'success');
      }
    } on AddressValidationException catch (e) {
      if (context.mounted) {
        showToast(context, message: e.message, status: 'error');
      }
    } catch (_) {
      if (context.mounted) {
        showToast(
          context,
          message: 'Could not delete address. Please try again.',
          status: 'error',
        );
      }
    }
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'No saved addresses',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Add a delivery address so we can bring your orders to the right place.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppButton(
              label: 'Add address',
              onPressed: onAdd,
              prefixIcon: const Icon(Icons.add_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Material(
      color: cs.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.lg,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: cs.secondary.withValues(alpha: 0.12),
                    borderRadius: AppBorders.md,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: cs.secondary,
                    size: 22,
                  ),
                ),
                SizedBox(width: AppSpacing.ms.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.line1,
                              style: tt.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: AppBorders.sm,
                              ),
                              child: Text(
                                'Default',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        address.line2,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (address.formattedAddress.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          address.formattedAddress,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set as default'),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: cs.primary),
                  tooltip: 'Edit address',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                  tooltip: 'Delete address',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
