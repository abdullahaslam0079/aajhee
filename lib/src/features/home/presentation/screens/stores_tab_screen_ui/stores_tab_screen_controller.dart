part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

mixin StoresTabScreenController on ConsumerState<StoresTabScreen> {
  _ShopsViewMode _viewMode = _ShopsViewMode.list;

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProductSearchScreen(),
      ),
    );
  }
}
