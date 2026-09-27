import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/settings/data/services/address_geocoding_service.dart';
import 'package:aajhee/src/features/settings/domain/entities/address_suggestion.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/features/settings/presentation/widgets/address_location_map_picker.dart';
import 'package:aajhee/src/features/settings/presentation/widgets/address_search_field.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({
    super.key,
    this.isOnboardingFlow = false,
    this.addressToEdit,
  });

  final bool isOnboardingFlow;
  final SavedAddress? addressToEdit;

  bool get isEditMode => addressToEdit != null;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _instructionsController = TextEditingController();

  /// 0 = pick location on map, 1 = fill / confirm details
  int _step = 0;

  bool _isBusy = false;
  String? _verifiedAddress;
  String? _county;
  late double _mapLat;
  late double _mapLng;
  bool _hasMapPin = false;

  @override
  void initState() {
    super.initState();
    final address = widget.addressToEdit;
    if (address != null) {
      _streetController.text = address.street;
      _houseNumberController.text = address.houseNumber;
      _postalCodeController.text = address.postalCode;
      _cityController.text = address.city;
      _instructionsController.text = address.deliveryInstructions;
      _verifiedAddress = address.formattedAddress;
      _mapLat = address.latitude;
      _mapLng = address.longitude;
      _hasMapPin = true;
      // Editing: still start on map so user can adjust, or go to details?
      // Start on map with pin ready; they can confirm quickly.
      _step = 0;
    } else {
      _mapLat = MapConstants.initialCameraPosition.target.latitude;
      _mapLng = MapConstants.initialCameraPosition.target.longitude;
    }
  }

  void _applySuggestion(AddressSuggestion suggestion) {
    _streetController.text = suggestion.street;
    _houseNumberController.text = suggestion.houseNumber;
    _postalCodeController.text = suggestion.postalCode;
    _cityController.text = suggestion.city;
    setState(() {
      _verifiedAddress = suggestion.shortLabel;
      if (suggestion.hasCoordinates) {
        _mapLat = suggestion.latitude!;
        _mapLng = suggestion.longitude!;
        _hasMapPin = true;
      }
    });
    if (suggestion.hasCoordinates) {
      _resolveAt(_mapLat, _mapLng);
    }
  }

  Future<void> _resolveAt(double lat, double lng) async {
    setState(() {
      _isBusy = true;
      _mapLat = lat;
      _mapLng = lng;
      _hasMapPin = true;
    });

    try {
      final geocoded = await ref
          .read(addressGeocodingServiceProvider)
          .reverseGeocode(latitude: lat, longitude: lng);
      if (!mounted) return;
      if ((geocoded.street ?? '').isNotEmpty) {
        _streetController.text = geocoded.street!;
      }
      if ((geocoded.houseNumber ?? '').isNotEmpty) {
        _houseNumberController.text = geocoded.houseNumber!;
      }
      if ((geocoded.postalCode ?? '').isNotEmpty) {
        _postalCodeController.text = geocoded.postalCode!;
      }
      if ((geocoded.city ?? '').isNotEmpty) {
        _cityController.text = geocoded.city!;
      }
      setState(() {
        _verifiedAddress = geocoded.formattedAddress;
        _county = geocoded.county;
        _isBusy = false;
      });
    } on AddressValidationException catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      showToast(context, message: e.message, status: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      showToast(
        context,
        message: 'Could not resolve map location. Try again.',
        status: 'error',
      );
    }
  }

  Future<void> _onMapPicked(LatLng position) =>
      _resolveAt(position.latitude, position.longitude);

  Future<void> _continueToDetails() async {
    if (!_hasMapPin) {
      // Use current map center even if idle hasn't fired yet.
      await _resolveAt(_mapLat, _mapLng);
      if (!_hasMapPin && mounted) {
        showToast(
          context,
          message: 'Move the map to choose your delivery location first.',
          status: 'error',
        );
        return;
      }
    }
    if (_streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      // Still allow continue; details step can fill gaps.
    }
    setState(() => _step = 1);
  }

  @override
  void dispose() {
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_hasMapPin) {
      showToast(
        context,
        message: 'Pick a location on the map first.',
        status: 'error',
      );
      setState(() => _step = 0);
      return;
    }

    setState(() => _isBusy = true);

    try {
      final geocoded = GeocodedAddress(
        latitude: _mapLat,
        longitude: _mapLng,
        formattedAddress: _verifiedAddress ??
            '${_streetController.text} ${_houseNumberController.text}, '
                '${_postalCodeController.text} ${_cityController.text}',
        county: _county,
      );
      final instructions = _instructionsController.text.trim();
      final notifier = ref.read(savedAddressesProvider.notifier);
      if (widget.isEditMode) {
        await notifier.updateAddress(
          id: widget.addressToEdit!.id,
          street: _streetController.text,
          houseNumber: _houseNumberController.text,
          postalCode: _postalCodeController.text,
          city: _cityController.text,
          geocoded: geocoded,
          deliveryInstructions: instructions,
        );
      } else {
        await notifier.addAddress(
          street: _streetController.text,
          houseNumber: _houseNumberController.text,
          postalCode: _postalCodeController.text,
          city: _cityController.text,
          geocoded: geocoded,
          deliveryInstructions: instructions,
        );
      }

      if (!mounted) return;
      showToast(
        context,
        message: widget.isEditMode ? 'Address updated' : 'Address saved',
        status: 'success',
      );
      if (widget.isOnboardingFlow || !context.canPop()) {
        context.go(AppRoutes.bottomNavigator);
      } else {
        context.pop();
      }
    } on AddressValidationException catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      showToast(context, message: e.message, status: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isBusy = false);
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
    // Step 1: intercept back → return to map. Step 0 + onboarding: block exit.
    final canPopRoute = _step == 0 && !widget.isOnboardingFlow;

    return PopScope(
      canPop: canPopRoute,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_step == 1) {
          setState(() => _step = 0);
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(
            _step == 0
                ? 'Choose location'
                : (widget.isEditMode ? 'Edit address' : 'Address details'),
          ),
          centerTitle: false,
          scrolledUnderElevation: 0,
          backgroundColor: cs.surface,
          leading: widget.isOnboardingFlow && _step == 0
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_step == 1) {
                      setState(() => _step = 0);
                    } else if (context.canPop()) {
                      context.pop();
                    }
                  },
                ),
        ),
        body: SafeArea(
          child: _step == 0
              ? _buildLocationStep(cs, tt, pagePadding)
              : _buildDetailsStep(cs, tt, pagePadding),
        ),
      ),
    );
  }

  Widget _buildLocationStep(
    ColorScheme cs,
    TextTheme tt,
    double pagePadding,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        AppSpacing.sm.h,
        pagePadding,
        AppSpacing.md.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step 1 of 2 · Pick on the map',
            style: tt.labelLarge?.copyWith(color: cs.primary),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'Search or slide the map. The pin stays in the center.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          SizedBox(height: AppSpacing.md.h),
          AddressSearchField(
            enabled: !_isBusy,
            onSuggestionSelected: _applySuggestion,
          ),
          SizedBox(height: AppSpacing.md.h),
          Expanded(
            child: AddressLocationMapPicker(
              latitude: _mapLat,
              longitude: _mapLng,
              enabled: !_isBusy,
              expand: true,
              onLocationSelected: (pos) => _onMapPicked(pos),
            ),
          ),
          if (_verifiedAddress != null) ...[
            SizedBox(height: AppSpacing.sm.h),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm.r),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.4),
                borderRadius: AppBorders.lg,
              ),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, color: cs.primary, size: 20),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      _verifiedAddress!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSpacing.md.h),
          AppButton(
            label: 'Use this location',
            isLoading: _isBusy,
            onPressed: _isBusy ? null : _continueToDetails,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep(
    ColorScheme cs,
    TextTheme tt,
    double pagePadding,
  ) {
    return SingleChildScrollView(
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
              'Step 2 of 2 · Confirm details',
              style: tt.labelLarge?.copyWith(color: cs.primary),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Check the fields below. Delivery instructions are optional.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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
                            'Selected location',
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
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            '${_mapLat.toStringAsFixed(5)}, ${_mapLng.toStringAsFixed(5)}',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _step = 0),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppSpacing.lg.h),
            AppTextField(
              controller: _streetController,
              enabled: !_isBusy,
              label: 'Street',
              hint: 'e.g. Rosenthaler Str.',
              prefixIcon: const Icon(Icons.signpost_outlined),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  AppUtils.isBlank(v) ? 'Street is required' : null,
            ),
            SizedBox(height: AppSpacing.md.h),
            AppTextField(
              controller: _houseNumberController,
              enabled: !_isBusy,
              label: 'House number',
              hint: 'e.g. 38',
              prefixIcon: const Icon(Icons.home_outlined),
              textInputAction: TextInputAction.next,
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
                    enabled: !_isBusy,
                    label: 'Postal code',
                    hint: 'e.g. 10178',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        AppUtils.isBlank(v) ? 'Postal code is required' : null,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    controller: _cityController,
                    enabled: !_isBusy,
                    label: 'City',
                    hint: 'e.g. Lahore',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        AppUtils.isBlank(v) ? 'City is required' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            AppTextField(
              controller: _instructionsController,
              enabled: !_isBusy,
              label: 'Delivery instructions (optional)',
              hint: 'e.g. Ring doorbell, leave at reception',
              prefixIcon: const Icon(Icons.notes_outlined),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: AppSpacing.xl.h),
            AppButton(
              label: widget.isEditMode ? 'Update address' : 'Save address',
              isLoading: _isBusy,
              onPressed: _isBusy ? null : _saveAddress,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
