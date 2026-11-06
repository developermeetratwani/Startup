import '../entities/user_entity.dart';
import '../core/failure.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;

  Future<(UserEntity?, Failure?)> signInWithEmail({
    required String email,
    required String password,
  });
  Future<(UserEntity?, Failure?)> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<(String?, Failure?)> sendPhoneOtp(String phoneNumber);
  Future<(UserEntity?, Failure?)> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<void> signOut();
  Future<String?> getIdToken({bool forceRefresh = false});
}
