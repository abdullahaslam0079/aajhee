import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/domain/pakistani_phone.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_product_card.dart';
import 'package:aajhee/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/url_launcher_service.dart';
import 'package:aajhee/src/utils/geo_distance_utils.dart';

part 'store_catalog_screen_ui/store_catalog_screen_controller.dart';
part 'store_catalog_screen_ui/store_catalog_screen_view.dart';
part 'store_catalog_screen_ui/store_hero.dart';
part 'store_catalog_screen_ui/store_highlights.dart';
part 'store_catalog_screen_ui/store_segment_tabs.dart';
part 'store_catalog_screen_ui/store_cover_banner.dart';
part 'store_catalog_screen_ui/store_category_cards.dart';
part 'store_catalog_screen_ui/store_product_carousel.dart';
part 'store_catalog_screen_ui/store_about_panel.dart';
part 'store_catalog_screen_ui/contact_button.dart';

/// Opens a store catalog from a map branch or business/branch ids.
class StoreCatalogArgs {
  const StoreCatalogArgs({
    this.branch,
    this.businessId,
    this.branchId,
    this.businessName,
    this.logoUrl,
  });

  factory StoreCatalogArgs.fromBranch(MapBranchModel branch) {
    return StoreCatalogArgs(
      branch: branch,
      businessId: branch.businessId,
      branchId: branch.id,
      businessName: branch.businessName,
      logoUrl: branch.businessLogoUrl,
    );
  }

  final MapBranchModel? branch;
  final int? businessId;
  final int? branchId;
  final String? businessName;
  final String? logoUrl;

  int? get resolvedBusinessId =>
      businessId ??
      (branch != null && branch!.businessId > 0 ? branch!.businessId : null);

  int? get resolvedBranchId => branchId ?? branch?.id;
}

class StoreCatalogScreen extends ConsumerStatefulWidget {
  const StoreCatalogScreen({super.key, required this.args});

  final StoreCatalogArgs args;

  @override
  ConsumerState<StoreCatalogScreen> createState() => _StoreCatalogScreenState();
}
