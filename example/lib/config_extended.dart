import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Extended config with library ID and other streaming parameters
class BunnyConfig {
  /// Load Bunny credentials from .env file
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Get Library ID from env (numeric)
  static int get libraryId {
    final value = dotenv.env['BUNNY_LIBRARY_ID'];
    return int.tryParse(value ?? '') ?? 0;
  }

  /// Get Access Key from env
  static String get accessKey {
    return dotenv.env['BUNNY_ACCESS_KEY'] ?? '';
  }

  /// Get Collection ID from env
  static String get collectionId {
    return dotenv.env['BUNNY_COLLECTION_ID'] ?? '';
  }

  /// Get Video ID from env
  static String get videoId {
    return dotenv.env['BUNNY_VIDEO_ID'] ?? '';
  }

  /// Get CDN Hostname from env (optional, returns null if empty)
  static String? get cdnHostname {
    final value = dotenv.env['BUNNY_CDN_HOSTNAME']?.trim();
    return (value?.isNotEmpty ?? false) ? value : null;
  }

  /// Get Secure Token from env (optional, from backend, returns null if empty)
  static String? get secureToken {
    final value = dotenv.env['BUNNY_SECURE_TOKEN']?.trim();
    return (value?.isNotEmpty ?? false) ? value : null;
  }

  /// Get Token Expires (unix seconds) from env (optional, returns null if empty)
  static int? get tokenExpires {
    final value = dotenv.env['BUNNY_EXPIRES']?.trim();
    if (value?.isEmpty ?? true) return null;
    return int.tryParse(value ?? '');
  }

  /// Check if credentials are fully loaded
  static bool get isConfigured {
    return libraryId > 0 && accessKey.isNotEmpty && collectionId.isNotEmpty;
  }

  /// Display config status for debugging
  static String debugStatus() {
    return '''
BunnyConfig Status:
  Library ID: ${libraryId > 0 ? 'SET ($libraryId)' : 'NOT SET'}
  Collection ID: ${collectionId.isNotEmpty ? 'SET' : 'NOT SET'}
  Access Key: ${accessKey.isNotEmpty ? 'SET (${accessKey.length} chars)' : 'NOT SET'}
  Video ID: ${videoId.isNotEmpty ? 'SET' : 'NOT SET'}
  CDN Hostname: ${cdnHostname ?? 'DEFAULT'}
  Secure Token: ${secureToken != null ? 'SET' : 'NOT SET'}
  Token Expires: ${tokenExpires != null ? 'SET ($tokenExpires)' : 'NOT SET'}
  Configured: ${isConfigured ? 'YES' : 'NO'}
''';
  }
}
