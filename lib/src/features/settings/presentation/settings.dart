import 'package:aajhee/src/config/app_web_links.dart';
import 'package:aajhee/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notification_preferences_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/theme_preferences_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/auth_service.dart';
import 'package:aajhee/src/services/push_notification_service.dart';

part 'settings_ui/settings_screen_controller.dart';
part 'settings_ui/settings_screen_view.dart';
part 'settings_ui/profile_header.dart';
part 'settings_ui/profile_meta_row.dart';
part 'settings_ui/section_title.dart';
part 'settings_ui/settings_card.dart';
part 'settings_ui/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}
