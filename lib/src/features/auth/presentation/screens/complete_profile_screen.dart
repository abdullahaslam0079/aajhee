import 'package:aajhee/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_navigation.dart';

final _namePattern = RegExp(r"^[\p{L}][\p{L}\s.'\-]*$", unicode: true);

/// Collects display name for new users after phone/social auth.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (AppUtils.isBlank(value)) return 'auth.name_required'.tr();
    final name = value!.trim();
    if (name.length < 2) return 'auth.name_too_short'.tr();
    if (name.length > 50) return 'auth.name_too_long'.tr();
    if (!_namePattern.hasMatch(name)) return 'auth.name_invalid'.tr();
    return null;
  }

  bool _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid && _autovalidateMode != AutovalidateMode.onUserInteraction) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    }
    return isValid;
  }

  Future<void> _continue() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(userProfileProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
          );

      if (!mounted) return;
      navigateAfterAuthentication(
        context,
        hasSavedAddress: hasSavedAddressFromContext(context),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is Exception
          ? error.toString().replaceFirst('Exception: ', '')
          : 'auth.complete_profile_error'.tr();
      showToast(
        context,
        message: message.isNotEmpty
            ? message
            : 'auth.complete_profile_error'.tr(),
        status: 'error',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.xl.h),
                  Image.asset(
                    isDark ? AppAssets.logoOnDark : AppAssets.logo,
                    height: 64.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    'auth.complete_profile_title'.tr(),
                    textAlign: TextAlign.center,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    'auth.complete_profile_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                  AppTextField(
                    controller: _nameController,
                    enabled: !_isSaving,
                    label: 'auth.name'.tr(),
                    hint: 'auth.name_hint'.tr(),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.name],
                    autofocus: true,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    onFieldSubmitted: (_) {
                      if (!_isSaving) _continue();
                    },
                    validator: _validateName,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  AppButton(
                    label: 'auth.complete_profile_continue'.tr(),
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _continue,
                    isFullWidth: true,
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
