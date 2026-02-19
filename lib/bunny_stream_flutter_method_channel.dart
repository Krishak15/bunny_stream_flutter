import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bunny_stream_flutter_platform_interface.dart';

/// An implementation of [BunnyStreamFlutterPlatform] that uses method channels.
class MethodChannelBunnyStreamFlutter extends BunnyStreamFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bunny_stream_flutter');

  @override
  Future<void> initialize({
    required String accessKey,
    required int libraryId,
    String? cdnHostname,
    String? token,
    int? expires,
  }) async {
    await methodChannel.invokeMethod<void>('initialize', {
      'accessKey': accessKey,
      'libraryId': libraryId,
      'cdnHostname': cdnHostname,
      'token': token,
      'expires': expires,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> listVideos({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
    String? collectionId,
  }) async {
    final response = await methodChannel
        .invokeMethod<List<Object?>>('listVideos', {
          'libraryId': libraryId,
          'page': page,
          'itemsPerPage': itemsPerPage,
          'search': search,
          'collectionId': collectionId,
        });
    return response?.map(_asMap).toList() ?? <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> getVideo({
    required int libraryId,
    required String videoId,
  }) async {
    final response = await methodChannel.invokeMethod<Object?>('getVideo', {
      'libraryId': libraryId,
      'videoId': videoId,
    });
    return _asMap(response);
  }

  @override
  Future<List<Map<String, dynamic>>> listCollections({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
  }) async {
    final response = await methodChannel
        .invokeMethod<List<Object?>>('listCollections', {
          'libraryId': libraryId,
          'page': page,
          'itemsPerPage': itemsPerPage,
          'search': search,
        });
    return response?.map(_asMap).toList() ?? <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> getCollection({
    required int libraryId,
    required String collectionId,
  }) async {
    final response = await methodChannel.invokeMethod<Object?>(
      'getCollection',
      {'libraryId': libraryId, 'collectionId': collectionId},
    );
    return _asMap(response);
  }

  @override
  Future<Map<String, dynamic>> getVideoPlayData({
    required int libraryId,
    required String videoId,
    String? token,
    int? expires,
  }) async {
    final response = await methodChannel.invokeMethod<Object?>(
      'getVideoPlayData',
      {
        'libraryId': libraryId,
        'videoId': videoId,
        'token': token,
        'expires': expires,
      },
    );
    return _asMap(response);
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }
}
