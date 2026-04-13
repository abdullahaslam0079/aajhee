import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_nav_bar_controller.g.dart';

@riverpod
class BottomNavBarController extends _$BottomNavBarController {
  @override
  int build() => 0;

  void setSelectedIndex(int index) {
    state = index;
  }
}
