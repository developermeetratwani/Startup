import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void info(String tag, String message) =>
      _logger.i('[$tag] $message');

  static void warning(String tag, String message) =>
      _logger.w('[$tag] $message');

  static void error(String tag, String message) =>
      _logger.e('[$tag] $message');

  static void debug(String tag, String message) =>
      _logger.d('[$tag] $message');
}
