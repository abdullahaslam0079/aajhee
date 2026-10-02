import 'dart:async';

import 'package:aajhee/src/features/commerce/domain/checkout_payload.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/domain/entities/cart_line.dart';
import 'package:aajhee/src/features/commerce/domain/entities/checkout_preview.dart';
import 'package:aajhee/src/features/commerce/domain/entities/upload_file.dart';
import 'package:aajhee/src/features/commerce/domain/pakistani_phone.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';

part 'checkout_screen_ui/checkout_screen_controller.dart';
part 'checkout_screen_ui/checkout_screen_view.dart';
part 'checkout_screen_ui/checkout_group.dart';
part 'checkout_screen_ui/checkout_format.dart';
part 'checkout_screen_ui/section_card.dart';
part 'checkout_screen_ui/detail_row.dart';
part 'checkout_screen_ui/checkout_item_row.dart';
part 'checkout_screen_ui/selectable_tile.dart';
part 'checkout_screen_ui/payment_instructions_details.dart';
part 'checkout_screen_ui/bank_line.dart';
part 'checkout_screen_ui/summary_row.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}
