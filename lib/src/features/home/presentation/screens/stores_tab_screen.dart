import 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_search_bar.dart';
import 'package:aajhee/src/features/home/data/models/category_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/features/home/presentation/widgets/category_widget.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/home/presentation/widgets/home_header.dart';
import 'package:aajhee/src/features/location/presentation/providers/location_provider.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/mapFeature/presentation/map_screen.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';

part 'stores_tab_screen_ui/stores_tab_screen_controller.dart';
part 'stores_tab_screen_ui/stores_tab_screen_view.dart';
part 'stores_tab_screen_ui/shops_view_mode.dart';
part 'stores_tab_screen_ui/list_map_toggle.dart';
part 'stores_tab_screen_ui/toggle_chip.dart';
part 'stores_tab_screen_ui/pinned_stores_header.dart';
part 'stores_tab_screen_ui/stores_feed_error.dart';
part 'stores_tab_screen_ui/empty_category_state.dart';
part 'stores_tab_screen_ui/stores_categories_header.dart';

class StoresTabScreen extends ConsumerStatefulWidget {
  const StoresTabScreen({super.key});

  @override
  ConsumerState<StoresTabScreen> createState() => _StoresTabScreenState();
}
