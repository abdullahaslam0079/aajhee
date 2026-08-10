import 'dart:io' show Platform;

import 'package:goluto/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Phone number entry with Google / Apple social sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isSending = false;
  bool _isSocialLoading = false;
  bool _appleAvailable = false;

  /// Default to Germany (+49); user can edit the full E.164 value.
  static const _defaultCountryCode = '+49';

  @override
  void initState() {
    super.initState();
    _checkAppleAvailability();
  }

  Future<void> _checkAppleAvailability() async {
    if (kIsWeb) return;
    if (!(Platform.isIOS || Platform.isMacOS || Platform.isAndroid)) return;
    final available =
        await FirebaseSocialAuthService.instance.isAppleSignInAvailable();
    if (mounted) setState(() => _appleAvailable = available);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizeToE164(String raw) {
    final trimmed = raw.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (trimmed.startsWith('+')) return trimmed;
    if (trimmed.startsWith('00')) return '+${trimmed.substring(2)}';
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      return '$_defaultCountryCode${digits.substring(1)}';
    }
    return '$_defaultCountryCode$digits';
  }

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _normalizeToE164(_phoneController.text);
    setState(() => _isSending = true);

    try {
      final session = await FirebasePhoneAuthService.instance.sendOtp(
        e164Phone: phone,
      );

      if (!mounted) return;

      if (session.isAutoVerified && session.idToken != null) {
        await ref.read(authControllerProvider.notifier).completeFirebaseLogin(
              context: context,
              idToken: session.idToken!,
            );
        return;
      }

      if (session.verificationId == null) {
        showToast(
          context,
          message: 'Could not start phone verification.',
          status: 'error',
        );
        return;
      }

      await context.push(
        AppRoutes.verifyOtp,
        extra: PhoneOtpArgs(
          phoneNumber: phone,
          verificationId: session.verificationId!,
          resendToken: session.resendToken,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showToast(
        context,
        message: FirebasePhoneAuthService.instance.mapErrorToMessage(error),
        status: 'error',
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isSocialLoading = true);
    try {
      final idToken =
          await FirebaseSocialAuthService.instance.signInWithGoogle();
      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).completeFirebaseLogin(
            context: context,
            idToken: idToken,
          );
    } catch (error) {
      if (!mounted) return;
      showToast(
        context,
        message: FirebaseSocialAuthService.instance.mapErrorToMessage(error),
        status: 'error',
      );
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isSocialLoading = true);
    try {
      final idToken =
          await FirebaseSocialAuthService.instance.signInWithApple();
      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).completeFirebaseLogin(
            context: context,
            idToken: idToken,
          );
    } catch (error) {
      if (!mounted) return;
      showToast(
        context,
        message: FirebaseSocialAuthService.instance.mapErrorToMessage(error),
        status: 'error',
      );
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthBusy = ref.watch(authControllerProvider);
    final isLoading = _isSending || _isSocialLoading || isAuthBusy;
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl.h),
                Text(
                  'auth.log_in'.tr(),
                  style:
                      tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  'auth.log_in_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xxxl.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _phoneController,
                        enabled: !isLoading,
                        label: 'auth.phone'.tr(),
                        hint: 'auth.phone_hint'.tr(),
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!isLoading) _sendCode();
                        },
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.phone_required'.tr();
                          }
                          final normalized = _normalizeToE164(v!);
                          final digits =
                              normalized.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 8) {
                            return 'auth.phone_invalid'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      AppButton(
                        label: 'auth.send_code'.tr(),
                        isLoading: _isSending || isAuthBusy,
                        onPressed: isLoading ? null : _sendCode,
                        width: ButtonSize.large,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                      child: Text(
                        'auth.or_continue_with'.tr(),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: AppSpacing.lg.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialIconButton(
                      backgroundColor:
                          const Color(0xFFEA4335).withValues(alpha: 0.9),
                      assetPath: AppAssets.googleIcon,
                      enabled: !isLoading,
                      onPressed: _signInWithGoogle,
                    ),
                    if (_appleAvailable) ...[
                      SizedBox(width: 20.w),
                      _SocialIconButton(
                        backgroundColor: const Color(0xFF000000),
                        assetPath: AppAssets.appleIcon,
                        enabled: !isLoading,
                        onPressed: _signInWithApple,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.xl.h),
                Text(
                  'auth.phone_privacy_note'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.backgroundColor,
    required this.assetPath,
    required this.onPressed,
    required this.enabled,
  });

  final Color backgroundColor;
  final String assetPath;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      height: 50.w,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.4),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorders.button,
          ),
        ),
        child: SvgPicture.asset(assetPath),
      ),
    );
  }
}

class PhoneOtpArgs {
  const PhoneOtpArgs({
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });

  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
}
