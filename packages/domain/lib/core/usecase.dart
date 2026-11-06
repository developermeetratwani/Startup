import 'failure.dart';

abstract class UseCase<T, P> {
  Future<(T?, Failure?)> call(P params);
}

class NoParams {
  const NoParams();
}
