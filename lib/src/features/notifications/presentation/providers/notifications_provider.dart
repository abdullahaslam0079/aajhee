import 'package:aajhee/src/features/auth/presentation/providers/session_provider.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/notifications/data/models/app_notification.dart';
import 'package:aajhee/src/features/notifications/data/services/notification_service.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_provider.g.dart';
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService.instance;
}

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.page = 0,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.unreadCount = 0,
  });

  final List<AppNotification> notifications;
  final int page;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int unreadCount;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? page,
    int? totalCount,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? unreadCount,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  static const _pageSize = 20;

  int _requestId = 0;

  NotificationService get _service => ref.read(notificationServiceProvider);

  @override
  NotificationsState build() {
    ref.listen(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.authenticated) {
        Future.microtask(() async {
          await refreshUnreadCount();
        });
      } else if (next.status == SessionStatus.unauthenticated) {
        state = const NotificationsState();
      }
    });

    final session = ref.watch(sessionProvider);
    if (session.status == SessionStatus.authenticated) {
      Future.microtask(refreshUnreadCount);
    }

    return const NotificationsState();
  }

  Future<void> load({bool reset = true}) async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      state = const NotificationsState();
      return;
    }

    final requestId = ++_requestId;
    final nextPage = reset ? 1 : state.page + 1;

    state = state.copyWith(
      isLoading: reset,
      isLoadingMore: !reset,
      clearError: true,
    );

    final result = await _service.fetchNotifications(
      page: nextPage,
      pageSize: _pageSize,
    );

    if (requestId != _requestId) return;

    var succeeded = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      (page) {
        final merged = reset
            ? page.results
            : [...state.notifications, ...page.results];
        state = state.copyWith(
          notifications: merged,
          page: page.page,
          totalCount: page.count,
          hasMore: page.hasMore,
          isLoading: false,
          isLoadingMore: false,
          clearError: true,
        );
        succeeded = true;
      },
    );

    if (succeeded) {
      await refreshUnreadCount();
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    await load(reset: false);
  }

  Future<void> refresh() => load(reset: true);

  Future<void> refreshUnreadCount() async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      state = state.copyWith(unreadCount: 0);
      return;
    }

    final result = await _service.fetchUnreadCount();
    result.fold(
      (_) {},
      (count) => state = state.copyWith(unreadCount: count),
    );
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;

    final previous = state.notifications;
    final updated = previous
        .map(
          (item) => item.id == notification.id
              ? item.copyWith(isRead: true, readAt: DateTime.now())
              : item,
        )
        .toList();
    state = state.copyWith(
      notifications: updated,
      unreadCount: (state.unreadCount - 1).clamp(0, 1 << 30),
    );

    final result = await _service.markRead(notification.id);
    result.fold(
      (failure) {
        state = state.copyWith(
          notifications: previous,
          unreadCount: state.unreadCount + 1,
        );
        AppLogger.warning('Mark read failed: ${failure.message}');
      },
      (serverNotification) {
        state = state.copyWith(
          notifications: state.notifications
              .map(
                (item) =>
                    item.id == serverNotification.id ? serverNotification : item,
              )
              .toList(),
        );
      },
    );
  }

  Future<void> markAllRead() async {
    if (state.unreadCount == 0 &&
        state.notifications.every((n) => n.isRead)) {
      return;
    }

    final previous = state.notifications;
    final previousUnread = state.unreadCount;
    state = state.copyWith(
      notifications: previous
          .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
          .toList(),
      unreadCount: 0,
    );

    final result = await _service.markAllRead();
    result.fold(
      (failure) {
        state = state.copyWith(
          notifications: previous,
          unreadCount: previousUnread,
        );
        AppLogger.warning('Mark all read failed: ${failure.message}');
      },
      (_) {},
    );
  }

  Future<MapBranchModel?> resolveBranch(AppNotification notification) async {
    final addressId =
        ref.read(savedAddressesProvider).selectedAddress?.id.toString();
    final discovery = ref.read(discoveryServiceProvider);

    if (notification.branchId != null) {
      final byId = await discovery.findBranchById(
        notification.branchId!,
        addressId: addressId,
      );
      final branch = byId.fold((_) => null, (value) => value);
      if (branch != null) return branch;
    }

    if (notification.businessId != null) {
      final byBusiness = await discovery.findBranchByBusinessId(
        notification.businessId!,
        addressId: addressId,
      );
      return byBusiness.fold((_) => null, (value) => value);
    }

    return null;
  }
}
