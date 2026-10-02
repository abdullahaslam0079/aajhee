part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class _ListMapToggle extends StatelessWidget {
  const _ListMapToggle({
    required this.mode,
    required this.onChanged,
  });

  final _ShopsViewMode mode;
  final ValueChanged<_ShopsViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppBorders.full,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            selected: mode == _ShopsViewMode.list,
            icon: Icons.view_list_rounded,
            label: 'List',
            onTap: () => onChanged(_ShopsViewMode.list),
            textTheme: tt,
            colorScheme: cs,
          ),
          _ToggleChip(
            selected: mode == _ShopsViewMode.map,
            icon: Icons.map_outlined,
            label: 'Map',
            onTap: () => onChanged(_ShopsViewMode.map),
            textTheme: tt,
            colorScheme: cs,
          ),
        ],
      ),
    );
  }
}
