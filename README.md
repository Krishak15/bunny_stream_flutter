Flutter plugin for Bunny.net Video on Android and iOS.

This package provides a single Dart API for:

- initializing Bunny Stream credentials
- fetching video metadata/listings
- generating playback URLs (HLS + MP4 renditions)

## Features

- Cross-platform method-channel API (`android`, `ios`)
- Typed Dart models (`BunnyVideo`, `BunnyCollection`, `BunnyVideoPlayData`)
- Unified error handling through `BunnyStreamException`
- Optional tokenized playback URL generation (`token`, `expires`)

## Platform support

| Platform | Support |
|:---------|:-------:|
| Android  |   ✅    |
| iOS      |   ✅    |

Requirements:

- Flutter: `>=3.38.4`
- Dart: `^3.10.3`
- Android min SDK: `26`
- iOS: `15.0+`

## Quick start

```dart
import 'package:bunny_stream_flutter/bunny_stream_flutter.dart';

final bunny = BunnyStreamFlutter();

await bunny.initialize(
  accessKey: 'YOUR_STREAM_ACCESS_KEY',
  libraryId: 12345,
  cdnHostname: 'vz-12345.b-cdn.net', // optional
);

final playData = await bunny.getVideoPlayData(
  libraryId: 12345,
  videoId: 'VIDEO_GUID',
  token: 'OPTIONAL_SECURE_TOKEN',
  expires: 1735689600,
);

print(playData.playlistUrl);
print(playData.url720p);
```

## Required Bunny Stream values

Collect these from Bunny Stream dashboard/back-end configuration:

- `libraryId` (stream library id)
- `accessKey` (library access key)
- `videoId` (video guid)
- `cdnHostname` (optional custom host)
- `token` and `expires` (optional; for secure playback)

## Bunny dashboard setup notes

Before using this plugin in production, configure your Bunny Stream library:

- Create a Stream library in Bunny.net.
- Create at least one collection in that library to organize/store your videos.
- Create a CDN hostname in the Bunny console for delivery.
- Enable direct play in Bunny dashboard at `Stream > Security > General`.

You can find the library-specific settings here:

- https://dash.bunny.net/stream/$yourSpecificlibraryId/api

## Security notes

- Do not hardcode production `accessKey` in client apps.
- Generate `token` and `expires` on your backend for protected playback.
- Keep Bunny secrets server-side whenever possible.

## API reference

Public entrypoint: `BunnyStreamFlutter`

Official Bunny references:

- Stream API reference: https://docs.bunny.net/api-reference/stream
- Bunny Stream Android SDK: https://github.com/BunnyWay/bunny-stream-android
- Bunny Stream iOS SDK: https://github.com/BunnyWay/bunny-stream-ios

### `initialize`

```dart
Future<void> initialize({
  required String accessKey,
  required int libraryId,
  String? cdnHostname,
  String? token,
  int? expires,
})
```

Stores library credentials and optional host defaults for subsequent calls.

### `listVideos`

```dart
Future<List<BunnyVideo>> listVideos({
  required int libraryId,
  int page = 1,
  int itemsPerPage = 100,
  String? search,
  String? collectionId,
})
```

Returns paginated videos for a library.

### `getVideo`

```dart
Future<BunnyVideo> getVideo({
  required int libraryId,
  required String videoId,
})
```

Returns metadata for a single video.

### `listCollections`

```dart
Future<List<BunnyCollection>> listCollections({
  required int libraryId,
  int page = 1,
  int itemsPerPage = 100,
  String? search,
})
```

Returns paginated collections for a library.

### `getCollection`

```dart
Future<BunnyCollection> getCollection({
  required int libraryId,
  required String collectionId,
})
```

Returns metadata for a single collection.

### `getVideoPlayData`

```dart
Future<BunnyVideoPlayData> getVideoPlayData({
  required int libraryId,
  required String videoId,
  String? token,
  int? expires,
})
```

Builds playback URLs including:

- `playlistUrl` (HLS)
- `fallbackUrl`
- `url360p`, `url720p`, `url1080p`

## Model types

### `BunnyVideo`

- `id`: resolved from `guid` or `id`
- `raw`: full API payload as immutable map
- `availableResolutions`: parsed list from `availableResolutions`

### `BunnyCollection`

- `id`: resolved from `guid` or `id`
- `raw`: full API payload as immutable map

### `BunnyVideoPlayData`

- `playlistUrl`, `fallbackUrl`
- `url360p`, `url720p`, `url1080p`
- `raw`: immutable source payload

### `BunnyStreamException`

All `PlatformException` failures are mapped to:

```dart
BunnyStreamException {
  String code;
  String message;
  Object? details;
}
```

Example:

```dart
try {
  await bunny.initialize(accessKey: key, libraryId: libraryId);
} on BunnyStreamException catch (error) {
  print('${error.code}: ${error.message}');
}
```

## Native implementation status

Current Android/iOS native handlers include:

- `initialize`
- `getVideo`
- `listVideos`
- `getVideoPlayData`

Currently unimplemented natively on both platforms:

- `listCollections`
- `getCollection`

Calling unimplemented methods returns `UNIMPLEMENTED_NATIVE`.

## Additional docs

- pub.dev package page: https://pub.dev/packages/bunny_stream_flutter
- API docs (after publish): https://pub.dev/documentation/bunny_stream_flutter/latest/

