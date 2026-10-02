import 'dart:async';

import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_product_card.dart';
import 'package:aajhee/src/features/home/data/models/category_model.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';
import 'package:aajhee/src/routing/app_routes.dart';

part 'product_search_screen_ui/product_search_screen_controller.dart';
part 'product_search_screen_ui/product_search_screen_view.dart';
part 'product_search_screen_ui/idle_body.dart';
part 'product_search_screen_ui/search_loading_body.dart';
part 'product_search_screen_ui/results_body.dart';
part 'product_search_screen_ui/search_shop_tile.dart';
part 'product_search_screen_ui/search_product_tile.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}
