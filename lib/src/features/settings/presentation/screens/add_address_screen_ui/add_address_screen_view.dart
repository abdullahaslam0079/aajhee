part of 'package:aajhee/src/features/settings/presentation/screens/add_address_screen.dart';

class _AddAddressScreenState extends ConsumerState<AddAddressScreen>
    with AddAddressScreenController {
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
                              color:
                                  cs.onPrimaryContainer.withValues(alpha: 0.8),
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
                    hint: cityHintExample(),
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
              controller: _landmarkController,
              enabled: !_isBusy,
              label: 'Landmark',
              hint: 'e.g. Near Liberty Market',
              prefixIcon: const Icon(Icons.place_outlined),
              textInputAction: TextInputAction.next,
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
