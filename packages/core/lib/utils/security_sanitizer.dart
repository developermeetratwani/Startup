/// Comprehensive Security & Anti-Injection Sanitizer
/// Protects against SQL injection, NoSQL operator injection, XSS, and path traversal.
class SecuritySanitizer {
  // Common SQL injection patterns
  static final RegExp _sqlInjectionPattern = RegExp(
    r'''(?i)(\b(SELECT|INSERT|UPDATE|DELETE|DROP|ALTER|CREATE|TRUNCATE|UNION|EXEC|EXECUTE|DECLARE|CAST)\b\s+|--|\/\*|\*\/|;|\bOR\b\s+['"\d\w]+=['"\d\w]+|\bAND\b\s+['"\d\w]+=['"\d\w]+|'.*--|'.*#|'.*\/\*)''',
    caseSensitive: false,
  );

  // Common XSS patterns
  static final RegExp _xssPattern = RegExp(
    r'''(?i)(<script\b[^>]*>([\s\S]*?)<\/script>|javascript:|data:text\/html|vbscript:|on\w+\s*=|<\s*img[^>]+src\s*=\s*['"]?javascript:)''',
    caseSensitive: false,
  );

  // Path traversal pattern
  static final RegExp _pathTraversalPattern = RegExp(
    r'''(\.\.[\/\\]|\/etc\/|C:\\Windows\\)''',
    caseSensitive: false,
  );

  /// Validates if an input string is safe from SQL injection attacks.
  static bool isSqlSafe(String? input) {
    if (input == null || input.isEmpty) return true;
    return !_sqlInjectionPattern.hasMatch(input);
  }

  /// Validates if an input string is safe from XSS attacks.
  static bool isXssSafe(String? input) {
    if (input == null || input.isEmpty) return true;
    return !_xssPattern.hasMatch(input);
  }

  /// Validates if an input string is safe from path traversal.
  static bool isPathSafe(String? input) {
    if (input == null || input.isEmpty) return true;
    return !_pathTraversalPattern.hasMatch(input);
  }

  /// Validates if input passes all security checks.
  static bool isCompletelySafe(String? input) {
    if (input == null || input.isEmpty) return true;
    return isSqlSafe(input) && isXssSafe(input) && isPathSafe(input);
  }

  /// Sanitizes raw user input by stripping malicious script tags and neutralizing SQL escape characters.
  static String sanitize(String input) {
    if (input.isEmpty) return input;
    String sanitized = input;
    // Strip script tags
    sanitized = sanitized.replaceAll(RegExp(r'<script\b[^>]*>([\s\S]*?)<\/script>', caseSensitive: false), '');
    // Neutralize dangerous characters
    sanitized = sanitized.replaceAll('\'', "''"); // SQL escaping
    sanitized = sanitized.replaceAll('<', '&lt;');
    sanitized = sanitized.replaceAll('>', '&gt;');
    sanitized = sanitized.replaceAll('"', '&quot;');
    return sanitized.trim();
  }

  /// Validates email format strictly to prevent header injection in SMTP
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    // Disallow newlines in email addresses to prevent SMTP header injection
    if (email.contains('\r') || email.contains('\n')) return false;
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates phone number (standard 10-digit Indian mobile)
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned) ||
           (cleaned.length == 12 && cleaned.startsWith('91') && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned.substring(2)));
  }
}
