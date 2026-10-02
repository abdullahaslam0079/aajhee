import 'package:aajhee/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:aajhee/src/features/commerce/domain/entities/customer_order.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/presentation/orders/order_status_colors.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/active_orders_badge_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_realtime_provider.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/shared/mixins/periodic_refresh_mixin.dart';
import 'package:aajhee/src/routing/app_routes.dart';

export 'order_detail_screen.dart';

part 'orders_screen_ui/orders_screen_controller.dart';
part 'orders_screen_ui/orders_screen_view.dart';
part 'orders_screen_ui/order_list_card.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}
