import '../../imports/core_imports.dart';
import '../../imports/packages_imports.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = false,
    this.onPressed,
    this.isTransparent = false,
  });

  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onPressed;
  final bool? centerTitle;
  final bool isTransparent;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final canPop = context.canPop();

    void handleBack() {
      if (onPressed != null) {
        onPressed!();
      } else if (canPop) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }

    return AppBar(
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isTransparent ? Colors.transparent : null,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      title: titleWidget ??
          Text(
            title,
            style: theme.appBarTheme.titleTextStyle ??
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.25,
                ),
          ),
      leading: IconButton(
        onPressed: handleBack,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.appBarTheme.iconTheme?.color ??
              theme.colorScheme.onSurface,
        ),
      ),
      iconTheme: theme.appBarTheme.iconTheme,
      actions: actions ?? [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
