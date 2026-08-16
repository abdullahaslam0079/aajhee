import 'package:goluto/src/features/auth/presentation/models/phone_otp_args.dart';
import 'package:goluto/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:goluto/src/features/auth/presentation/widgets/country_code_picker.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Paid Apple Developer Program + Sign In with Apple entitlement required on iOS.
/// Free personal teams cannot provision `com.apple.developer.applesignin`.
const kAppleSignInEnabledOnApplePlatforms = false;

final _namePattern = RegExp(r"^[\p{L}][\p{L}\s.'\-]*$", unicode: true);

/// Phone number entry with Google / Apple social sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  var _autovalidateMode = AutovalidateMode.disabled;
  CountryDialCode _country = kDefaultCountry;
  bool _isSending = false;
  bool _isSocialLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
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
    if (digits.startsWith(countryDigits) && digits.length > countryDigits.length) {
      return '+$digits';
    }
    return '${_country.dialCode}$digits';
  }

  String? _validateName(String? value) {
    if (AppUtils.isBlank(value)) return 'auth.name_required'.tr();
    final name = value!.trim();
    if (name.length < 2) return 'auth.name_too_short'.tr();
    if (name.length > 50) return 'auth.name_too_long'.tr();
    if (!_namePattern.hasMatch(name)) return 'auth.name_invalid'.tr();
    return null;
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
    final displayName = _nameController.text.trim();
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
              displayName: displayName,
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
          displayName: displayName,
        ),
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('[GoLuto] Send OTP failed: $error');
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
      debugPrint('[GoLuto] Google sign-in failed: $error');
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
      debugPrint('[GoLuto] Apple sign-in failed: $error');
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
                    height: 96.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                  Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          enabled: !isLoading,
                          label: 'auth.name'.tr(),
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                          validator: _validateName,
                        ),
                        SizedBox(height: AppSpacing.md.h),
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
