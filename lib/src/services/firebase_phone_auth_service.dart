import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Phone Auth.
///
/// Returns a Firebase ID token after OTP confirmation; the backend exchanges
/// that token for GoLuto JWTs.
class FirebasePhoneAuthService {
  FirebasePhoneAuthService._();
  static final FirebasePhoneAuthService instance = FirebasePhoneAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends an OTP to [e164Phone] (must include country code, e.g. +49170...).
  Future<PhoneVerificationSession> sendOtp({
    required String e164Phone,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final completer = Completer<PhoneVerificationSession>();

    await _auth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      timeout: timeout,
      verificationCompleted: (credential) async {
        // Android auto-retrieval / instant verification.
        if (completer.isCompleted) return;
        try {
          final idToken = await _signInAndGetIdToken(credential);
          completer.complete(
            PhoneVerificationSession.autoVerified(idToken: idToken),
          );
        } catch (error) {
          completer.completeError(error);
        }
      },
      verificationFailed: (error) {
        if (completer.isCompleted) return;
        completer.completeError(error);
      },
      codeSent: (verificationId, resendToken) {
        if (completer.isCompleted) return;
        completer.complete(
          PhoneVerificationSession.codeSent(
            verificationId: verificationId,
            resendToken: resendToken,
            phoneNumber: e164Phone,
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        // Session already completed via codeSent in normal flows.
        if (kDebugMode) {
          debugPrint('Firebase phone auto-retrieval timed out: $verificationId');
        }
      },
    );

    return completer.future;
  }

  /// Confirms the SMS code and returns a Firebase ID token.
  Future<String> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    return _signInAndGetIdToken(credential);
  }

  /// Resends OTP using the previous [resendToken] when available.
  Future<PhoneVerificationSession> resendOtp({
    required String e164Phone,
    int? resendToken,
    Duration timeout = const Duration(seconds: 60),
  }) {
    final completer = Completer<PhoneVerificationSession>();

    _auth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      timeout: timeout,
      forceResendingToken: resendToken,
      verificationCompleted: (credential) async {
        if (completer.isCompleted) return;
        try {
          final idToken = await _signInAndGetIdToken(credential);
          completer.complete(
            PhoneVerificationSession.autoVerified(idToken: idToken),
          );
        } catch (error) {
          completer.completeError(error);
        }
      },
      verificationFailed: (error) {
        if (completer.isCompleted) return;
        completer.completeError(error);
      },
      codeSent: (verificationId, newResendToken) {
        if (completer.isCompleted) return;
        completer.complete(
          PhoneVerificationSession.codeSent(
            verificationId: verificationId,
            resendToken: newResendToken,
            phoneNumber: e164Phone,
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  Future<String> _signInAndGetIdToken(PhoneAuthCredential credential) async {
    final result = await _auth.signInWithCredential(credential);
    final idToken = await result.user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Could not get Firebase ID token after phone verification.',
      );
    }
    return idToken;
  }

  Future<void> signOut() => _auth.signOut();

  String mapErrorToMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'Enter a valid phone number with country code.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'invalid-verification-code':
          return 'Invalid verification code. Please try again.';
        case 'session-expired':
          return 'Verification session expired. Request a new code.';
        case 'missing-id-token':
          return error.message ?? 'Could not complete phone verification.';
        default:
          return error.message ?? 'Phone verification failed.';
      }
    }
    return 'Phone verification failed. Please try again.';
  }
}

enum PhoneVerificationKind { codeSent, autoVerified }

class PhoneVerificationSession {
  const PhoneVerificationSession._({
    required this.kind,
    this.verificationId,
    this.resendToken,
    this.phoneNumber,
    this.idToken,
  });

  factory PhoneVerificationSession.codeSent({
    required String verificationId,
    required String phoneNumber,
    int? resendToken,
  }) {
    return PhoneVerificationSession._(
      kind: PhoneVerificationKind.codeSent,
      verificationId: verificationId,
      resendToken: resendToken,
      phoneNumber: phoneNumber,
    );
  }

  factory PhoneVerificationSession.autoVerified({required String idToken}) {
    return PhoneVerificationSession._(
      kind: PhoneVerificationKind.autoVerified,
      idToken: idToken,
    );
  }

  final PhoneVerificationKind kind;
  final String? verificationId;
  final int? resendToken;
  final String? phoneNumber;
  final String? idToken;

  bool get isAutoVerified => kind == PhoneVerificationKind.autoVerified;
}
