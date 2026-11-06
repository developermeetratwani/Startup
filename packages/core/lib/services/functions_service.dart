import 'package:cloud_functions/cloud_functions.dart';
import 'package:domain/domain.dart';
import '../utils/app_logger.dart';

class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-south1',
  );

  /// Call a Firebase callable function
  Future<(Map<String, dynamic>?, Failure?)> call(
    String functionName, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable(functionName);
      final result = await callable.call(data ?? {});
      return (Map<String, dynamic>.from(result.data as Map), null);
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error('CloudFunction[$functionName]', '${e.code}: ${e.message}');
      return (null, _mapFunctionsError(e));
    } catch (e) {
      AppLogger.error('CloudFunction[$functionName]', e.toString());
      return (null, UnexpectedFailure());
    }
  }

  Failure _mapFunctionsError(FirebaseFunctionsException e) {
    return switch (e.code) {
      'unauthenticated'   => const AuthFailure('Please sign in to continue.'),
      'permission-denied' => const PermissionFailure('You do not have permission.'),
      'not-found'         => const NotFoundFailure(),
      'invalid-argument'  => ValidationFailure(e.message ?? 'Invalid data provided.'),
      _                   => ServerFailure(e.message ?? 'Server error. Try again.'),
    };
  }
}
