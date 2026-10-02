part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class _StoresFeedError extends StatelessWidget {
  const _StoresFeedError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.cloud_off_outlined,
      title: 'Could not load shops',
      message: message,
      onRetry: onRetry,
    );
  }
}
