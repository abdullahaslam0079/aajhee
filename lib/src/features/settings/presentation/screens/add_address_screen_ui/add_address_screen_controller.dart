part of 'package:aajhee/src/features/settings/presentation/screens/add_address_screen.dart';

mixin AddAddressScreenController on ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _landmarkController = TextEditingController();

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
      _landmarkController.text = address.landmark;
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
    _landmarkController.dispose();
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
      final landmark = _landmarkController.text.trim();
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
          landmark: landmark,
        );
      } else {
        await notifier.addAddress(
          street: _streetController.text,
          houseNumber: _houseNumberController.text,
          postalCode: _postalCodeController.text,
          city: _cityController.text,
          geocoded: geocoded,
          deliveryInstructions: instructions,
          landmark: landmark,
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
}
