import 'package:aajhee/src/features/commerce/domain/entities/customer_order.dart';
import 'package:aajhee/src/features/commerce/domain/entities/upload_file.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/presentation/orders/order_status_colors.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_realtime_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/rate_product_sheet.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/shared/mixins/periodic_refresh_mixin.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/url_launcher_service.dart';

part 'order_detail_screen_ui/order_detail_screen_controller.dart';
part 'order_detail_screen_ui/order_detail_screen_view.dart';
part 'order_detail_screen_ui/section_card.dart';
part 'order_detail_screen_ui/order_timeline.dart';
part 'order_detail_screen_ui/meta_line.dart';
part 'order_detail_screen_ui/info_row.dart';
part 'order_detail_screen_ui/order_item_tile.dart';
part 'order_detail_screen_ui/item_image_fallback.dart';
part 'order_detail_screen_ui/summary_row.dart';
part 'order_detail_screen_ui/payment_proof_note_dialog.dart';
part 'order_detail_screen_ui/payment_proof_note_dialog_state.dart';
part 'order_detail_screen_ui/cancelled_info_card.dart';
part 'order_detail_screen_ui/payment_proof_tile.dart';
part 'order_detail_screen_ui/cancel_section.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.publicId});

  final String publicId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}
