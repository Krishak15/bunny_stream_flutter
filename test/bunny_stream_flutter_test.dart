import 'package:flutter_test/flutter_test.dart';
import 'package:bunny_stream_flutter/bunny_stream_flutter.dart';
import 'package:bunny_stream_flutter/bunny_stream_flutter_platform_interface.dart';
import 'package:bunny_stream_flutter/bunny_stream_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBunnyStreamFlutterPlatform
    with MockPlatformInterfaceMixin
    implements BunnyStreamFlutterPlatform {
  @override
  Future<void> initialize({
    required String accessKey,
    required int libraryId,
    String? cdnHostname,
    String? token,
    int? expires,
  }) {
    return Future.value();
  }

  @override
  Future<List<Map<String, dynamic>>> listVideos({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
    String? collectionId,
  }) {
    return Future.value(<Map<String, dynamic>>[
      <String, dynamic>{'guid': 'video-1', 'title': 'Video 1'},
    ]);
  }

  @override
  Future<Map<String, dynamic>> getVideo({
    required int libraryId,
    required String videoId,
  }) {
    return Future.value(<String, dynamic>{'guid': videoId});
  }

  @override
  Future<List<Map<String, dynamic>>> listCollections({
    required int libraryId,
    int page = 1,
    int itemsPerPage = 100,
    String? search,
  }) {
    return Future.value(<Map<String, dynamic>>[
      <String, dynamic>{'guid': 'collection-1', 'name': 'Collection 1'},
    ]);
  }

  @override
  Future<Map<String, dynamic>> getCollection({
    required int libraryId,
    required String collectionId,
  }) {
    return Future.value(<String, dynamic>{'guid': collectionId});
  }

  @override
  Future<Map<String, dynamic>> getVideoPlayData({
    required int libraryId,
    required String videoId,
    String? token,
    int? expires,
  }) {
    return Future.value(<String, dynamic>{
      'videoPlaylistUrl': 'https://example.com/$videoId/playlist.m3u8',
      'fallbackUrl': 'https://example.com/$videoId/play_720p.mp4',
      'url360p': 'https://example.com/$videoId/play_360p.mp4',
      'url720p': 'https://example.com/$videoId/play_720p.mp4',
      'url1080p': 'https://example.com/$videoId/play_1080p.mp4',
    });
  }
}

void main() {
  final BunnyStreamFlutterPlatform initialPlatform =
      BunnyStreamFlutterPlatform.instance;

  test('$MethodChannelBunnyStreamFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBunnyStreamFlutter>());
  });

  test('listVideos maps to BunnyVideo', () async {
    final bunnyStreamFlutterPlugin = BunnyStreamFlutter();
    final fakePlatform = MockBunnyStreamFlutterPlatform();
    BunnyStreamFlutterPlatform.instance = fakePlatform;

    final videos = await bunnyStreamFlutterPlugin.listVideos(libraryId: 12345);
    expect(videos, hasLength(1));
    expect(videos.first.id, 'video-1');
  });

  test('getVideoPlayData maps urls', () async {
    final bunnyStreamFlutterPlugin = BunnyStreamFlutter();
    final fakePlatform = MockBunnyStreamFlutterPlatform();
    BunnyStreamFlutterPlatform.instance = fakePlatform;

    final playData = await bunnyStreamFlutterPlugin.getVideoPlayData(
      libraryId: 12345,
      videoId: 'video-1',
    );
    expect(playData.playlistUrl, contains('playlist.m3u8'));
    expect(playData.fallbackUrl, contains('play_720p.mp4'));
  });
}
