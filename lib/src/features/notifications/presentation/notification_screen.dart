import 'package:goluto/src/imports/core_imports.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: const SafeArea(
        child: AppEmptyState(
          icon: Icons.notifications_none_rounded,
          title: 'No notifications yet',
          subtitle: 'Updates about your offers and account will appear here.',
        ),
      ),
    );
  }
}
