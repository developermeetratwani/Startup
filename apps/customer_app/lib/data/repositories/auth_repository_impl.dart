import 'package:domain/domain.dart';
import 'package:core/core.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  Stream<UserEntity?> get authStateChanges => _authService.authStateChanges;

  @override
  UserEntity? get currentUser => _authService.currentUser;

  @override
  Future<(UserEntity?, Failure?)> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _authService.signInWithEmail(email: email, password: password);

  @override
  Future<(UserEntity?, Failure?)> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) =>
      _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

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
  Future<void> signOut() => _authService.signOut();

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _authService.getIdToken(forceRefresh: forceRefresh);
}
