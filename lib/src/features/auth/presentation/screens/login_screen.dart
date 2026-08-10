import 'package:goluto/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Phone number entry — primary consumer auth screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isSending = false;

  /// Default to Germany (+49); user can edit the full E.164 value.
  static const _defaultCountryCode = '+49';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizeToE164(String raw) {
    final trimmed = raw.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (trimmed.startsWith('+')) return trimmed;
    if (trimmed.startsWith('00')) return '+${trimmed.substring(2)}';
    // Local number without country code → prepend default.
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
        await ref.read(authControllerProvider.notifier).completePhoneLogin(
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

  @override
  Widget build(BuildContext context) {
    final isAuthBusy = ref.watch(authControllerProvider);
    final isLoading = _isSending || isAuthBusy;
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
                  style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          final digits = normalized.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 8) {
                            return 'auth.phone_invalid'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      AppButton(
                        label: 'auth.send_code'.tr(),
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _sendCode,
                        width: ButtonSize.large,
                        isFullWidth: true,
                      ),
                    ],
                  ),
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
