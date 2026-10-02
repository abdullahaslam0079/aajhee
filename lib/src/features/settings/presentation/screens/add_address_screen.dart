import 'package:aajhee/src/config/launch_cities.dart';
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
import 'package:aajhee/src/routing/app_routes.dart';

part 'add_address_screen_ui/add_address_screen_controller.dart';
part 'add_address_screen_ui/add_address_screen_view.dart';

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
