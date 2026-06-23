import 'package:goluto/src/features/settings/data/services/address_geocoding_service.dart';
import 'package:goluto/src/features/settings/domain/entities/address_suggestion.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/features/settings/presentation/widgets/address_search_field.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isVerifying = false;
  String? _verifiedAddress;

  void _applySuggestion(AddressSuggestion suggestion) {
    _streetController.text = suggestion.street;
    _houseNumberController.text = suggestion.houseNumber;
    _postalCodeController.text = suggestion.postalCode;
    _cityController.text = suggestion.city;
    setState(() {
      _verifiedAddress = suggestion.shortLabel;
    });
  }

  void _clearVerifiedOnManualEdit() {
    if (_verifiedAddress != null) {
      setState(() => _verifiedAddress = null);
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _verifyAddress() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isVerifying = true;
      _verifiedAddress = null;
    });

    try {
      final geocoded = await ref.read(savedAddressesProvider.notifier).validateAddress(
            street: _streetController.text,
            houseNumber: _houseNumberController.text,
            postalCode: _postalCodeController.text,
            city: _cityController.text,
          );

      if (!mounted) return;
      setState(() {
        _verifiedAddress = geocoded.formattedAddress;
        _isVerifying = false;
      });
      showToast(
        context,
        message: 'Address verified successfully',
        status: 'success',
      );
    } on AddressValidationException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      showToast(context, message: e.message, status: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      showToast(
        context,
        message: 'Could not verify address. Please try again.',
        status: 'error',
      );
    }
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isVerifying = true;
      _verifiedAddress = null;
    });

    try {
      final geocoded = await ref.read(savedAddressesProvider.notifier).validateAddress(
            street: _streetController.text,
            houseNumber: _houseNumberController.text,
            postalCode: _postalCodeController.text,
            city: _cityController.text,
          );

      await ref.read(savedAddressesProvider.notifier).addAddress(
            street: _streetController.text,
            houseNumber: _houseNumberController.text,
            postalCode: _postalCodeController.text,
            city: _cityController.text,
            geocoded: geocoded,
          );

      if (!mounted) return;
      showToast(context, message: 'Address saved', status: 'success');
      context.pop();
    } on AddressValidationException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      showToast(context, message: e.message, status: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      showToast(
        context,
        message: 'Could not save address. Please try again.',
        status: 'error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final pagePadding = AppSpacing.pagePadding.w;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Add address'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            AppSpacing.md.h,
            pagePadding,
            AppSpacing.xl.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Delivery address',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  'Search for your address or enter the details manually. Selecting a suggestion fills all fields automatically.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.lg.h),
                AddressSearchField(
                  enabled: !_isVerifying,
                  onSuggestionSelected: _applySuggestion,
                ),
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  'Address details',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                AppTextField(
                  controller: _streetController,
                  enabled: !_isVerifying,
                  label: 'Street',
                  hint: 'e.g. Rosenthaler Str.',
                  prefixIcon: const Icon(Icons.signpost_outlined),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearVerifiedOnManualEdit(),
                  validator: (v) =>
                      AppUtils.isBlank(v) ? 'Street is required' : null,
                ),
                SizedBox(height: AppSpacing.md.h),
                AppTextField(
                  controller: _houseNumberController,
                  enabled: !_isVerifying,
                  label: 'House number',
                  hint: 'e.g. 38',
                  prefixIcon: const Icon(Icons.home_outlined),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearVerifiedOnManualEdit(),
                  validator: (v) =>
                      AppUtils.isBlank(v) ? 'House number is required' : null,
                ),
                SizedBox(height: AppSpacing.md.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        controller: _postalCodeController,
                        enabled: !_isVerifying,
                        label: 'Postal code',
                        hint: 'e.g. 10178',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _clearVerifiedOnManualEdit(),
                        validator: (v) => AppUtils.isBlank(v)
                            ? 'Postal code is required'
                            : null,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        controller: _cityController,
                        enabled: !_isVerifying,
                        label: 'City',
                        hint: 'e.g. Berlin',
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => _clearVerifiedOnManualEdit(),
                        validator: (v) =>
                            AppUtils.isBlank(v) ? 'City is required' : null,
                      ),
                    ),
                  ],
                ),
                if (_verifiedAddress != null) ...[
                  SizedBox(height: AppSpacing.md.h),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md.r),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: AppBorders.lg,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_outlined, color: cs.primary, size: 22),
                        SizedBox(width: AppSpacing.sm.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified location',
                                style: tt.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xxs.h),
                              Text(
                                _verifiedAddress!,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.xl.h),
                AppButton(
                  label: 'Verify address',
                  variant: ButtonVariant.secondary,
                  isLoading: _isVerifying,
                  onPressed: _isVerifying ? null : _verifyAddress,
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.sm.h),
                AppButton(
                  label: 'Save address',
                  isLoading: _isVerifying,
                  onPressed: _isVerifying ? null : _saveAddress,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
