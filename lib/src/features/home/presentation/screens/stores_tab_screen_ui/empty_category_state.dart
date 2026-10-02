part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState({this.onClearFilter});

  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.storefront_outlined,
      title: 'No shops here yet',
      subtitle: 'Try another category or check back soon.',
      actionLabel: onClearFilter != null ? 'Show all shops' : null,
      onAction: onClearFilter,
    );
  }
}
