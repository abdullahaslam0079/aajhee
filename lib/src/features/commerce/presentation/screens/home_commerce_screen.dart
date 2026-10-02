import 'dart:async';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_product_card.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_search_bar.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/features/home/presentation/widgets/category_widget.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/home/presentation/widgets/home_header.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';

part 'home_commerce_screen_ui/home_commerce_screen_controller.dart';
part 'home_commerce_screen_ui/home_commerce_screen_view.dart';
part 'home_commerce_screen_ui/pinned_home_header_delegate.dart';
part 'home_commerce_screen_ui/pinned_search_bar_delegate.dart';
part 'home_commerce_screen_ui/pinned_filters_delegate.dart';
part 'home_commerce_screen_ui/product_list_filter_chips.dart';
part 'home_commerce_screen_ui/section_title.dart';
part 'home_commerce_screen_ui/nearby_shop_card.dart';
part 'home_commerce_screen_ui/same_day_delivery_chip.dart';
part 'home_commerce_screen_ui/marketplace_skeleton.dart';

class HomeCommerceScreen extends ConsumerStatefulWidget {
  const HomeCommerceScreen({super.key});

  @override
  ConsumerState<HomeCommerceScreen> createState() => _HomeCommerceScreenState();
}
