import 'dart:async';

import 'package:goluto/src/features/auth/presentation/models/phone_otp_args.dart';
import 'package:goluto/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:goluto/src/features/auth/presentation/widgets/otp_code_input.dart';
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
  final _otpKey = GlobalKey<OtpCodeInputState>();
  String _code = '';
  bool _hasError = false;
  bool _isVerifying = false;
  bool _isResending = false;
  late String _verificationId;
  int? _resendToken;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  static const _otpLength = 6;
  static const _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.args.verificationId;
    _resendToken = widget.args.resendToken;
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendCooldown);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  String get _formattedCountdown {
    final minutes = (_resendSeconds ~/ 60).toString().padLeft(1, '0');
    final seconds = (_resendSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _verify([String? code]) async {
    final smsCode = (code ?? _code).trim();
    if (smsCode.length != _otpLength) {
      setState(() => _hasError = true);
      return;
    }
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _hasError = false;
    });

    try {
      final idToken = await FirebasePhoneAuthService.instance.confirmOtp(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      if (!mounted) return;

      await ref.read(authControllerProvider.notifier).completeFirebaseLogin(
            context: context,
            idToken: idToken,
            displayName: widget.args.displayName,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() => _hasError = true);
      _otpKey.currentState?.clear();
      _code = '';
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
    if (_resendSeconds > 0 || _isResending || _isVerifying) return;

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
              displayName: widget.args.displayName,
            );
        return;
      }

      if (session.verificationId != null) {
        _verificationId = session.verificationId!;
        _resendToken = session.resendToken;
      }

      _otpKey.currentState?.clear();
      _code = '';
      _hasError = false;
      _startResendTimer();

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
    final canResend = _resendSeconds == 0 && !isLoading && !_isResending;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('auth.verify_otp_title'.tr()),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              SizedBox(height: AppSpacing.xl.h),
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: AppBorders.xl,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 32.sp,
                  color: cs.primary,
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                'auth.verify_otp_heading'.tr(),
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                'auth.verify_otp_subtitle'.tr(
                  namedArgs: {'phone': widget.args.phoneNumber},
                ),
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              SizedBox(height: AppSpacing.xl.h),
              OtpCodeInput(
                key: _otpKey,
                length: _otpLength,
                enabled: !isLoading,
                hasError: _hasError,
                onChanged: (value) {
                  setState(() {
                    _code = value;
                    if (_hasError) _hasError = false;
                  });
                },
                onCompleted: (value) {
                  _code = value;
                  _verify(value);
                },
              ),
              if (_hasError) ...[
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  'auth.otp_invalid'.tr(),
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
              ],
              SizedBox(height: AppSpacing.xl.h),
              AppButton(
                label: 'auth.verify_and_continue'.tr(),
                isLoading: isLoading,
                onPressed: isLoading ? null : () => _verify(),
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                'auth.didnt_receive_code'.tr(),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              SizedBox(height: AppSpacing.xs.h),
              if (_isResending)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else if (canResend)
                TextButton(
                  onPressed: _resend,
                  child: Text(
                    'auth.resend_code'.tr(),
                    style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  'auth.resend_in'.tr(
                    namedArgs: {'time': _formattedCountdown},
                  ),
                  style: tt.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
