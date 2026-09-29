import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped when an order-related push arrives so open order screens can refetch.
final commerceRealtimeTickProvider =
    NotifierProvider<CommerceRealtimeTick, int>(CommerceRealtimeTick.new);

class CommerceRealtimeTick extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}
