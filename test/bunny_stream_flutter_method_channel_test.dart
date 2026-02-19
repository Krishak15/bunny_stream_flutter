import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bunny_stream_flutter/bunny_stream_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelBunnyStreamFlutter platform =
      MethodChannelBunnyStreamFlutter();
  const MethodChannel channel = MethodChannel('bunny_stream_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'initialize':
              return null;
            case 'listVideos':
              return <Map<String, dynamic>>[
                <String, dynamic>{'guid': 'video-1'},
              ];
            case 'getVideoPlayData':
              return <String, dynamic>{
                'videoPlaylistUrl': 'https://example.com/video-1/playlist.m3u8',
                'fallbackUrl': 'https://example.com/video-1/play_720p.mp4',
              };
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize', () async {
    await platform.initialize(accessKey: 'key', libraryId: 12345);
  });

  test('listVideos', () async {
    final videos = await platform.listVideos(libraryId: 12345);
    expect(videos, hasLength(1));
    expect(videos.first['guid'], 'video-1');
  });

  test('getVideoPlayData', () async {
    final playData = await platform.getVideoPlayData(
      libraryId: 12345,
      videoId: 'video-1',
    );
    expect(playData['videoPlaylistUrl'], contains('playlist.m3u8'));
  });
}
