import 'package:flutter/services.dart';

export 'bunny_built_in_player_view.dart';

import 'bunny_stream_flutter_platform_interface.dart';

class BunnyStreamFlutter {
  Future<void> initialize({
    required String accessKey,
    required int libraryId,
    String? cdnHostname,
    String? token,
    int? expires,
  }) {
    return _wrapErrors(
      () => BunnyStreamFlutterPlatform.instance.initialize(
        accessKey: accessKey,
        libraryId: libraryId,
        cdnHostname: cdnHostname,
        token: token,
        expires: expires,
      ),
    );
  }

  Future<List<BunnyVideo>> listVideos({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
    String? collectionId,
  }) {
    return _wrapErrors(() async {
      final response = await BunnyStreamFlutterPlatform.instance.listVideos(
        libraryId: libraryId,
        page: page,
        itemsPerPage: itemsPerPage,
        search: search,
        collectionId: collectionId,
      );
      return response.map(BunnyVideo.fromMap).toList(growable: false);
    });
  }

  Future<BunnyVideo> getVideo({
    required int libraryId,
    required String videoId,
  }) {
    return _wrapErrors(() async {
      final response = await BunnyStreamFlutterPlatform.instance.getVideo(
        libraryId: libraryId,
        videoId: videoId,
      );
      return BunnyVideo.fromMap(response);
    });
  }

  Future<List<BunnyCollection>> listCollections({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
  }) {
    return _wrapErrors(() async {
      final response = await BunnyStreamFlutterPlatform.instance
          .listCollections(
            libraryId: libraryId,
            page: page,
            itemsPerPage: itemsPerPage,
            search: search,
          );
      return response.map(BunnyCollection.fromMap).toList(growable: false);
    });
  }

  Future<BunnyCollection> getCollection({
    required int libraryId,
    required String collectionId,
  }) {
    return _wrapErrors(() async {
      final response = await BunnyStreamFlutterPlatform.instance.getCollection(
        libraryId: libraryId,
        collectionId: collectionId,
      );
      return BunnyCollection.fromMap(response);
    });
  }

  Future<BunnyVideoPlayData> getVideoPlayData({
    required int libraryId,
    required String videoId,
    String? token,
    int? expires,
  }) {
    return _wrapErrors(() async {
      final response = await BunnyStreamFlutterPlatform.instance
          .getVideoPlayData(
            libraryId: libraryId,
            videoId: videoId,
            token: token,
            expires: expires,
          );
      return BunnyVideoPlayData.fromMap(response);
    });
  }

  Future<T> _wrapErrors<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException catch (error) {
      throw BunnyStreamException(
        code: error.code,
        message: error.message ?? 'An unknown platform error occurred.',
        details: error.details,
      );
    }
  }
}

class BunnyVideo {
  BunnyVideo({required this.id, required this.raw});

  final String id;
  final Map<String, dynamic> raw;

  factory BunnyVideo.fromMap(Map<String, dynamic> map) {
    return BunnyVideo(
      id: (map['guid'] ?? map['id'] ?? '').toString(),
      raw: Map<String, dynamic>.unmodifiable(map),
    );
  }

  /// Get available resolutions as a list (e.g., ['240p', '360p', '720p', '1080p'])
  List<String> get availableResolutions {
    final resolutions = raw['availableResolutions']?.toString().trim() ?? '';
    if (resolutions.isEmpty) return [];
    return resolutions
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();
  }
}

class BunnyCollection {
  BunnyCollection({required this.id, required this.raw});

  final String id;
  final Map<String, dynamic> raw;

  factory BunnyCollection.fromMap(Map<String, dynamic> map) {
    return BunnyCollection(
      id: (map['guid'] ?? map['id'] ?? '').toString(),
      raw: Map<String, dynamic>.unmodifiable(map),
    );
  }
}

class BunnyVideoPlayData {
  BunnyVideoPlayData({
    required this.playlistUrl,
    required this.fallbackUrl,
    required this.url360p,
    required this.url720p,
    required this.url1080p,
    required this.raw,
  });

  final String playlistUrl;
  final String fallbackUrl;
  final String url360p;
  final String url720p;
  final String url1080p;
  final Map<String, dynamic> raw;

  factory BunnyVideoPlayData.fromMap(Map<String, dynamic> map) {
    return BunnyVideoPlayData(
      playlistUrl: (map['videoPlaylistUrl'] ?? map['playlistUrl'] ?? '')
          .toString(),
      fallbackUrl: (map['fallbackUrl'] ?? '').toString(),
      url360p: (map['url360p'] ?? '').toString(),
      url720p: (map['url720p'] ?? '').toString(),
      url1080p: (map['url1080p'] ?? '').toString(),
      raw: Map<String, dynamic>.unmodifiable(map),
    );
  }
}

class BunnyStreamException implements Exception {
  BunnyStreamException({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() {
    return 'BunnyStreamException(code: $code, message: $message, details: $details)';
  }
}
