import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';
import 'package:aajhee/src/routing/app_routes.dart';

part 'product_detail_screen_ui/product_detail_screen_controller.dart';
part 'product_detail_screen_ui/product_detail_screen_view.dart';
part 'product_detail_screen_ui/block.dart';
part 'product_detail_screen_ui/delivery_info_box.dart';
part 'product_detail_screen_ui/hero_image.dart';
part 'product_detail_screen_ui/price_block.dart';
part 'product_detail_screen_ui/sold_by_row.dart';
part 'product_detail_screen_ui/verified_chip.dart';
part 'product_detail_screen_ui/bottom_cart_bar.dart';
part 'product_detail_screen_ui/qty_icon_button.dart';
part 'product_detail_screen_ui/suggestion_card.dart';
part 'product_detail_screen_ui/product_rating_row.dart';
part 'product_detail_screen_ui/review_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initial,
    this.branchId,
  });

  final String productId;
  final Map<String, dynamic>? initial;
  final int? branchId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}
