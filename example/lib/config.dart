import 'package:flutter_dotenv/flutter_dotenv.dart';

class BunnyConfig {
  /// Load Bunny credentials from .env file
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Get Access Key from env
  static String get accessKey {
    return dotenv.env['BUNNY_ACCESS_KEY'] ?? '';
  }

  /// Get CDN Hostname from env (optional)
  static String? get cdnHostname {
    final value = dotenv.env['BUNNY_CDN_HOSTNAME']?.trim();
    return (value?.isNotEmpty ?? false) ? value : null;
  }

  /// Get Secure Token from env (optional, from backend)
  static String? get secureToken {
    final value = dotenv.env['BUNNY_SECURE_TOKEN']?.trim();
    return (value?.isNotEmpty ?? false) ? value : null;
  }

  /// Get Token Expires (unix seconds) from env (optional)
  static int? get tokenExpires {
    final value = dotenv.env['BUNNY_EXPIRES'];
    return int.tryParse(value ?? '');
  }

  /// Check if credentials are fully loaded
  static bool get isConfigured {
    return accessKey.isNotEmpty;
  }

  /// Display config status for debugging
  static String debugStatus() {
    return '''
  BunnyConfig Status:
  Access Key: ${accessKey.isNotEmpty ? 'SET (${accessKey.length} chars)' : 'NOT SET'}
  CDN Hostname: ${cdnHostname ?? 'DEFAULT'}
  Secure Token: ${secureToken != null ? 'SET' : 'NOT SET'}
  Token Expires: ${tokenExpires ?? 'NOT SET'}
  Configured: ${isConfigured ? 'YES' : 'NO'}
''';
  }
}
