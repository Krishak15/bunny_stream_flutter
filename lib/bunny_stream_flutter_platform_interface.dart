import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bunny_stream_flutter_method_channel.dart';

abstract class BunnyStreamFlutterPlatform extends PlatformInterface {
  /// Constructs a BunnyStreamFlutterPlatform.
  BunnyStreamFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BunnyStreamFlutterPlatform _instance =
      MethodChannelBunnyStreamFlutter();

  /// The default instance of [BunnyStreamFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelBunnyStreamFlutter].
  static BunnyStreamFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BunnyStreamFlutterPlatform] when
  /// they register themselves.
  static set instance(BunnyStreamFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize({
    required String accessKey,
    required int libraryId,
    String? cdnHostname,
    String? token,
    int? expires,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<List<Map<String, dynamic>>> listVideos({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
    String? collectionId,
  }) {
    throw UnimplementedError('listVideos() has not been implemented.');
  }

  Future<Map<String, dynamic>> getVideo({
    required int libraryId,
    required String videoId,
  }) {
    throw UnimplementedError('getVideo() has not been implemented.');
  }

  Future<List<Map<String, dynamic>>> listCollections({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
  }) {
    throw UnimplementedError('listCollections() has not been implemented.');
  }

  Future<Map<String, dynamic>> getCollection({
    required int libraryId,
    required String collectionId,
  }) {
    throw UnimplementedError('getCollection() has not been implemented.');
  }

  Future<Map<String, dynamic>> getVideoPlayData({
    required int libraryId,
    required String videoId,
    String? token,
    int? expires,
  }) {
    throw UnimplementedError('getVideoPlayData() has not been implemented.');
  }
}
