// lib/services/auth_service.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId; // mobile/desktop
  ConfirmationResult? _confirmationResult; // web

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting Firebase sign in for: ${email.trim()}');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('Sign in successful: ${credential.user!.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException code: ${e.code}');
      debugPrint('FirebaseAuthException message: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // -------------------- Phone auth (OTP) --------------------
  /// Sends an OTP to the given phone number (E.164 format recommended, e.g. +919876543210).
  ///
  /// On Web this uses Firebase web phone auth (reCAPTCHA is handled by Firebase).
  /// On mobile/desktop it uses verifyPhoneNumber.
  Future<void> sendOtp({
    required String phoneNumber,
  }) async {
    final phone = _normalizeE164Phone(phoneNumber);

    try {
      if (kIsWeb) {
        // Ensure we don't reuse an old verifier / confirmation result.
        _confirmationResult = null;
        _confirmationResult = await _auth.signInWithPhoneNumber(phone);
        return;
      }

      final completer = Completer<void>();
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          // Auto-resolve on Android sometimes
          try {
            await _auth.signInWithCredential(credential);
          } catch (_) {}
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.completeError(_handleAuthException(e));
          }
        },
        codeSent: (verificationId, forceResendingToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send OTP. Please try again.';
    }
  }

  /// Very small helper to reduce "Invalid phone number" errors.
  /// Firebase expects E.164 for phone auth, e.g. +14155552671, +919876543210.
  String _normalizeE164Phone(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw 'Please enter a mobile number.';
    }

    // Remove common separators/spaces.
    final cleaned = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!cleaned.startsWith('+')) {
      throw 'Invalid phone number. Please include country code (example: +919876543210).';
    }

    if (!RegExp(r'^\+\d{8,15}$').hasMatch(cleaned)) {
      throw 'Invalid phone number format. Use E.164 (example: +919876543210).';
    }

    return cleaned;
  }

  Future<UserCredential?> verifyOtp({
    required String smsCode,
  }) async {
    final code = smsCode.trim();
    if (code.isEmpty) throw 'Please enter the OTP.';

    try {
      if (kIsWeb) {
        final result = _confirmationResult;
        if (result == null) {
          throw 'Please request OTP first.';
        }
        return await result.confirm(code);
      }

      final verificationId = _verificationId;
      if (verificationId == null || verificationId.isEmpty) {
        throw 'Please request OTP first.';
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // -------------------- Google sign-in --------------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        return await _auth.signInWithPopup(provider);
      }

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw 'Google sign-in cancelled.';
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please try again.';
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'captcha-check-failed':
        return 'reCAPTCHA failed/expired. Please try again (refresh page if needed).';
      case 'invalid-app-credential':
        return 'reCAPTCHA failed/expired. Please try again (refresh page if needed).';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
