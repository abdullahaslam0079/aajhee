import 'package:aajhee/src/features/auth/presentation/models/phone_otp_args.dart';
import 'package:aajhee/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:aajhee/src/features/auth/presentation/widgets/country_code_picker.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/firebase_phone_auth_service.dart';
import 'package:aajhee/src/services/firebase_social_auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

/// Paid Apple Developer Program + Sign In with Apple entitlement required on iOS.
/// Free personal teams cannot provision `com.apple.developer.applesignin`.
const kAppleSignInEnabledOnApplePlatforms = false;

/// Phone number entry with Google / Apple social sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  var _autovalidateMode = AutovalidateMode.disabled;
  late CountryDialCode _country;
  bool _isSending = false;
  bool _isSocialLoading = false;

  @override
  void initState() {
    super.initState();
    _country = countryFromDeviceLocale();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  String _toE164(String rawNational) {
    var digits = rawNational.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) {
      return '+${digits.substring(2)}';
    }
    if (rawNational.trim().startsWith('+')) {
      return '+$digits';
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    final countryDigits = _country.dialCode.replaceAll('+', '');
    if (digits.startsWith(countryDigits) &&
        digits.length > countryDigits.length) {
      return '+$digits';
    }
    return '${_country.dialCode}$digits';
  }

  String? _validatePhone(String? value) {
    if (AppUtils.isBlank(value)) return 'auth.phone_required'.tr();
    final e164 = _toE164(value!);
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8 || digits.length > 15) {
      return 'auth.phone_invalid'.tr();
    }
    return null;
  }

  bool _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid && _autovalidateMode != AutovalidateMode.onUserInteraction) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    }
    return isValid;
  }

  Future<void> _sendCode() async {
    if (!_validateForm()) return;

    final phone = _toE164(_phoneController.text);
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
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[Aajhee] Send OTP failed: $error');
      debugPrintStack(stackTrace: stackTrace);
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
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[Aajhee] Google sign-in failed: $error');
      debugPrintStack(stackTrace: stackTrace);
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
    if (!kAppleSignInEnabledOnApplePlatforms) {
      showToast(
        context,
        message: 'auth.apple_coming_soon'.tr(),
        status: 'info',
      );
      return;
    }

    setState(() => _isSocialLoading = true);
    try {
      final idToken =
          await FirebaseSocialAuthService.instance.signInWithApple();
      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).completeFirebaseLogin(
            context: context,
            idToken: idToken,
          );
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[Aajhee] Apple sign-in failed: $error');
      debugPrintStack(stackTrace: stackTrace);
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
    final isDark = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: AutofillGroup(
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.xl.h),
                  Image.asset(
                    isDark ? AppAssets.logoOnDark : AppAssets.logo,
                    height: 80.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Text(
                    'auth.log_in_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                  Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          enabled: !isLoading,
                          label: 'auth.phone'.tr(),
                          hint: 'auth.phone_hint'.tr(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          prefixIcon: CountryCodePicker(
                            selected: _country,
                            enabled: !isLoading,
                            onChanged: (country) {
                              setState(() => _country = country);
                            },
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          autofillHints: const [
                            AutofillHints.telephoneNumberNational,
                          ],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]'),
                            ),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          onFieldSubmitted: (_) {
                            if (!isLoading) _sendCode();
                          },
                          validator: _validatePhone,
                        ),
                        SizedBox(height: AppSpacing.lg.h),
                        AppButton(
                          label: 'auth.send_code'.tr(),
                          isLoading: _isSending || isAuthBusy,
                          onPressed: isLoading ? null : _sendCode,
                          isFullWidth: true,
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        Text(
                          'auth.phone_privacy_note'.tr(),
                          textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md.w,
                        ),
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
                  SizedBox(height: AppSpacing.md.h),
                  AppButton(
                    label: 'auth.continue_with_google'.tr(),
                    variant: ButtonVariant.outline,
                    prefixIcon: SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: SvgPicture.asset(
                        AppAssets.googleIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                    onPressed: isLoading ? null : _signInWithGoogle,
                    isFullWidth: true,
                  ),
                  if (kAppleSignInEnabledOnApplePlatforms &&
                      (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.macOS)) ...[
                    SizedBox(height: AppSpacing.sm.h),
                    AppButton(
                      label: 'auth.continue_with_apple'.tr(),
                      variant: ButtonVariant.outline,
                      prefixIcon: SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: SvgPicture.asset(
                          AppAssets.appleIcon,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            cs.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      onPressed: isLoading ? null : _signInWithApple,
                      isFullWidth: true,
                    ),
                  ],
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
