import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:core/core.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final SmtpAuthService _smtpService;

  static final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  // No hardcoded user — starts null until real sign-in or registration
  static UserEntity? _currentUser;

  AuthRepositoryImpl({AuthService? authService, SmtpAuthService? smtpService})
      : _authService = authService ?? AuthService(),
        _smtpService = smtpService ?? const SmtpAuthService();

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authService.authStateChanges.map((u) => u ?? _currentUser);
  }

  @override
  UserEntity? get currentUser => _authService.currentUser ?? _currentUser;

  @override
  Future<(UserEntity?, Failure?)> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final (user, failure) = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (user != null) {
      _currentUser = user;
      _controller.add(user);

      // Record login in Cloud Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      return (user, null);
    }

    // If Firebase Auth returned an error (wrong password, user not found, etc.)
    if (failure != null) {
      return (null, failure);
    }

    return (null, const AuthFailure('Sign in failed. Please verify your credentials.'));
  }

  @override
  Future<(UserEntity?, Failure?)> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // 1. Create user in Firebase Auth
    final (user, failure) = await _authService.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (failure != null) {
      return (null, failure);
    }

    final newUser = user ??
        UserEntity(
          uid: 'cust-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          phone: '',
          role: UserRole.customer,
          displayName: displayName,
          createdAt: DateTime.now(),
        );

    _currentUser = newUser;
    _controller.add(newUser);

    // 2. Save user profile into Cloud Firestore (/users and /customerProfiles)
    try {
      final fs = FirebaseFirestore.instance;
      await fs.collection('users').doc(newUser.uid).set({
        'uid': newUser.uid,
        'email': email,
        'displayName': displayName,
        'role': 'customer',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fs.collection('customerProfiles').doc(newUser.uid).set({
        'userId': newUser.uid,
        'fullName': displayName,
        'email': email,
        'totalOrders': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('AuthRepositoryImpl', 'Saved new user ${newUser.uid} to Cloud Firestore');
    } catch (e) {
      AppLogger.warning('AuthRepositoryImpl.registerWithEmail', 'Firestore profile write: $e');
    }

    // 3. Dispatch branded Welcome Email via SMTP mail service
    try {
      await _smtpService.sendWelcomeEmail(
        recipientEmail: email,
        displayName: displayName,
      );
      AppLogger.info('AuthRepositoryImpl', 'Sent welcome email to $email');
    } catch (e) {
      AppLogger.warning('AuthRepositoryImpl.sendWelcomeEmail', 'SMTP send info: $e');
    }

    return (newUser, null);
  }

  @override
  Future<(String?, Failure?)> sendPhoneOtp(String phoneNumber) async {
    return _authService.sendPhoneOtp(
      phoneNumber,
      onAutoVerified: (_) {},
      onFailed: (_) {},
      onCodeSent: (_, __) {},
    );
  }

  @override
  Future<(UserEntity?, Failure?)> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) =>
      _authService.verifyPhoneOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
    await _authService.signOut();
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _authService.getIdToken(forceRefresh: forceRefresh);
}
