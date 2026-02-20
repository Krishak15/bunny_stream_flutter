# bunny_stream_flutter_example

Demonstrates how to use the bunny_stream_flutter plugin.

## Prerequisites

Collect these from Bunny Stream console:

- Stream `Library ID`
- Stream `Access Key`
- One `Video ID`
- Optional custom `CDN Hostname`
- Optional secure `token` and `expires` from your backend (if token auth enabled)

## Run Android example

```bash
cd example
flutter pub get
flutter run -d android
```

## Run iOS example

```bash
cd example
flutter pub get
flutter run -d ios
```

iOS requires 15.0+.

## What this example demonstrates

- Plugin initialization with Bunny credentials
- Retrieving playback URLs via `getVideoPlayData`
- Handling `BunnyStreamException` errors with code/message/details
