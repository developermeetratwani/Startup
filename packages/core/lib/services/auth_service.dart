import 'package:firebase_auth/firebase_auth.dart';
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

class AuthService {
  FirebaseAuth? _authInstance;

  FirebaseAuth? get _auth {
    try {
      return _authInstance ??= FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Stream of Firebase auth state mapped to domain UserEntity
  Stream<UserEntity?> get authStateChanges {
    final auth = _auth;
    if (auth == null) return Stream.value(null);
    return auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  UserEntity? get currentUser {
    try {
      final user = _auth?.currentUser;
      if (user == null) return null;
      return _mapFirebaseUser(user);
    } catch (_) {
      return null;
    }
  }

  Future<(UserEntity?, Failure?)> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return (null, const AuthFailure('Firebase Auth is not initialized'));
    }
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      final user = _mapFirebaseUser(cred.user!);
      return (user, null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('signInWithEmail', e.message ?? e.code);
      return (null, AuthFailure(_friendlyAuthError(e.code)));
    } catch (e) {
      return (null, UnexpectedFailure(e.toString()));
    }
  }

  Future<(UserEntity?, Failure?)> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return (null, const AuthFailure('Firebase Auth is not initialized'));
    }
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      await cred.user?.updateDisplayName(displayName);
      await cred.user?.reload();
      final user = _mapFirebaseUser(auth.currentUser!);
      return (user, null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('registerWithEmail', e.message ?? e.code);
      return (null, AuthFailure(_friendlyAuthError(e.code)));
    } catch (e) {
      return (null, UnexpectedFailure(e.toString()));
    }
  }

  Future<(String?, Failure?)> sendPhoneOtp(
    String phoneNumber, {
    required PhoneVerificationCompleted onAutoVerified,
    required PhoneVerificationFailed onFailed,
    required void Function(String, int?) onCodeSent,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return (null, const AuthFailure('Firebase Auth not available'));
    }
    try {
      String? verificationId;
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onAutoVerified,
        verificationFailed: onFailed,
        codeSent: (vId, resendToken) {
          verificationId = vId;
          onCodeSent(vId, resendToken);
        },
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
      return (verificationId, null);
    } catch (e) {
      return (null, const AuthFailure('Failed to send OTP'));
    }
  }

  Future<(UserEntity?, Failure?)> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return (null, const AuthFailure('Firebase Auth not available'));
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await auth.signInWithCredential(credential);
      return (_mapFirebaseUser(cred.user!), null);
    } on FirebaseAuthException catch (e) {
      return (null, AuthFailure(_friendlyAuthError(e.code)));
    } catch (e) {
      return (null, UnexpectedFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _auth?.signOut();
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth?.currentUser?.getIdToken(forceRefresh);
  }

  Future<UserRole?> getCurrentRole() async {
    final token = await _auth?.currentUser?.getIdTokenResult();
    final role = token?.claims?['role'] as String?;
    if (role == null) return null;
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.customer,
    );
  }

  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      uid: user.uid,
      email: user.email,
      phone: user.phoneNumber,
      role: UserRole.customer, // actual role comes from custom claims
      displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  String _friendlyAuthError(String code) {
    return switch (code) {
      'user-not-found'       => 'No account found with this email.',
      'wrong-password'       => 'Incorrect password.',
      'email-already-in-use' => 'An account already exists with this email.',
      'weak-password'        => 'Password must be at least 6 characters.',
      'invalid-email'        => 'Please enter a valid email address.',
      'too-many-requests'    => 'Too many attempts. Please try again later.',
      'invalid-verification-code' => 'Invalid OTP. Please try again.',
      _ => 'Authentication failed. Please try again.',
    };
  }
}
