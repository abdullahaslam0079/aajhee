import 'package:goluto/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.args,
  });

  final PhoneOtpArgs args;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  late String _verificationId;
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.args.verificationId;
    _resendToken = widget.args.resendToken;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isVerifying = true);
    try {
      final idToken = await FirebasePhoneAuthService.instance.confirmOtp(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );

      if (!mounted) return;

      await ref.read(authControllerProvider.notifier).completeFirebaseLogin(
            context: context,
            idToken: idToken,
          );
    } catch (error) {
      if (!mounted) return;
      showToast(
        context,
        message: FirebasePhoneAuthService.instance.mapErrorToMessage(error),
        status: 'error',
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      final session = await FirebasePhoneAuthService.instance.resendOtp(
        e164Phone: widget.args.phoneNumber,
        resendToken: _resendToken,
      );

      if (!mounted) return;

      if (session.isAutoVerified && session.idToken != null) {
        await ref.read(authControllerProvider.notifier).completeFirebaseLogin(
              context: context,
              idToken: session.idToken!,
            );
        return;
      }

      if (session.verificationId != null) {
        setState(() {
          _verificationId = session.verificationId!;
          _resendToken = session.resendToken;
        });
      }

      showToast(
        context,
        message: 'auth.code_resent'.tr(),
        status: 'success',
      );
    } catch (error) {
      if (!mounted) return;
      showToast(
        context,
        message: FirebasePhoneAuthService.instance.mapErrorToMessage(error),
        status: 'error',
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthBusy = ref.watch(authControllerProvider);
    final isLoading = _isVerifying || isAuthBusy;
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('auth.verify_otp_title'.tr()),
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xl.h),
                Text(
                  'auth.verify_otp_subtitle'.tr(
                    namedArgs: {'phone': widget.args.phoneNumber},
                  ),
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xl.h),
                AppTextField(
                  controller: _codeController,
                  enabled: !isLoading,
                  label: 'auth.otp_code'.tr(),
                  hint: 'auth.otp_hint'.tr(),
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.sms_outlined),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!isLoading) _verify();
                  },
                  validator: (v) {
                    if (AppUtils.isBlank(v)) {
                      return 'auth.otp_required'.tr();
                    }
                    if (v!.trim().length < 6) {
                      return 'auth.otp_invalid'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg.h),
                AppButton(
                  label: 'auth.verify_and_continue'.tr(),
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _verify,
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.md.h),
                TextButton(
                  onPressed: (isLoading || _isResending) ? null : _resend,
                  child: _isResending
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('auth.resend_code'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
