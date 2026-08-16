class PhoneOtpArgs {
  const PhoneOtpArgs({
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
    this.displayName,
  });

  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final String? displayName;
}
