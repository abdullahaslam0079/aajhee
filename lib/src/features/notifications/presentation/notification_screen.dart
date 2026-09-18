import 'package:aajhee/src/features/notifications/data/models/app_notification.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(notificationsProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  Future<void> _openNotification(AppNotification notification) async {
    final notifier = ref.read(notificationsProvider.notifier);
    await notifier.markRead(notification);

    final branch = await notifier.resolveBranch(notification);
    if (!mounted) return;

    if (branch != null) {
      context.push(AppRoutes.businessStore, extra: branch);
      return;
    }

    showToast(
      context,
      message: 'Could not open this offer right now.',
      status: 'warning',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
          child: _buildBody(state, colorScheme),
        ),
      ),
    );
  }

  Widget _buildBody(
    NotificationsState state,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading && state.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          AppLoading(message: 'Loading notifications...'),
        ],
      );
    }

    if (state.errorMessage != null && state.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load notifications',
            subtitle: state.errorMessage,
            actionLabel: 'Retry',
            onAction: () =>
                ref.read(notificationsProvider.notifier).refresh(),
          ),
        ],
      );
    }

    if (state.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          const AppEmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications yet',
            subtitle:
                'Updates about your offers and account will appear here.',
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ms.w,
        AppSpacing.sm.h,
        AppSpacing.ms.w,
        AppSpacing.lg.h,
      ),
      itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm.h),
      itemBuilder: (context, index) {
        if (index >= state.notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: AppLoading(size: 22, strokeWidth: 2.5),
          );
        }

        final notification = state.notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () => _openNotification(notification),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final unread = !notification.isRead;

    return Material(
      color: unread
          ? colorScheme.primary.withValues(alpha: 0.06)
          : colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.lg,
        side: BorderSide(
          color: unread
              ? colorScheme.primary.withValues(alpha: 0.16)
              : colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.ms.w,
            vertical: AppSpacing.ms.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _formatTimestamp(notification.createdAt),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}';
  }
}
