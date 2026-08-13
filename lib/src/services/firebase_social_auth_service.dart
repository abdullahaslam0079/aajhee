import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Google / Apple sign-in via Firebase Auth.
///
/// Returns a Firebase ID token for exchange with GoLuto backend JWTs.
class FirebaseSocialAuthService {
  FirebaseSocialAuthService._();
  static final FirebaseSocialAuthService instance = FirebaseSocialAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// iOS OAuth client from `GoogleService-Info.plist` (`CLIENT_ID`).
  static const _googleIosClientId =
      '860507972929-5idpj482c4u24h6gub43m2m8acvdg3p8.apps.googleusercontent.com';

  /// Web OAuth client from `google-services.json` (client_type 3).
  /// Needed so Google returns an ID token usable by Firebase.
  static const _googleServerClientId =
      '860507972929-b78dmgqil7d22nqkad9avm6akaf95pec.apps.googleusercontent.com';

  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? _googleIosClientId
          : null,
      serverClientId: _googleServerClientId,
    );
    _googleInitialized = true;
  }

  Future<String> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google Sign-In did not return an ID token.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      return _requireIdToken(result.user);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[GoLuto] Google sign-in failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  Future<String> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final identityToken = appleCredential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-apple-id-token',
        message: 'Apple Sign-In did not return an identity token.',
      );
    }

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    final result = await _auth.signInWithCredential(oauthCredential);

    // Apple only provides the name on the first authorization.
    final givenName = appleCredential.givenName;
    final familyName = appleCredential.familyName;
    if (result.user != null &&
        (givenName != null || familyName != null) &&
        (result.user!.displayName == null ||
            result.user!.displayName!.trim().isEmpty)) {
      final displayName = [givenName, familyName]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ');
      if (displayName.isNotEmpty) {
        await result.user!.updateDisplayName(displayName);
      }
    }

    return _requireIdToken(result.user);
  }

  Future<bool> isAppleSignInAvailable() {
    return SignInWithApple.isAvailable();
  }

  Future<String> _requireIdToken(User? user) async {
    final idToken = await user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Could not get Firebase ID token after social sign-in.',
      );
    }
    return idToken;
  }

  String mapErrorToMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'missing-google-id-token':
        case 'missing-apple-id-token':
        case 'missing-id-token':
          return error.message ?? 'Could not complete sign-in.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return error.message ?? 'Social sign-in failed.';
      }
    }
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return 'Sign-in was cancelled.';
      }
      return error.description ?? 'Google Sign-In failed.';
    }
    if (error is SignInWithAppleAuthorizationException) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return 'Sign-in was cancelled.';
      }
      return error.message;
    }
    if (kDebugMode) {
      return 'Social sign-in failed: $error';
    }
    return 'Social sign-in failed. Please try again.';
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
