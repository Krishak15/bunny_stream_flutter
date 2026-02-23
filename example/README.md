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

## Built-in Bunny player platform setup

If you use the built-in Bunny player option in this example, ensure these platform requirements are met.

### Android

- Keep rule in `android/app/proguard-rules.pro`:

```pro
-keep class net.bunny.bunnystreamplayer.** { *; }
```

- App theme in `android/app/src/main/AndroidManifest.xml`:

```xml
<application
	...
	android:theme="@style/Theme.AppCompat.Light.NoActionBar">
```

- JitPack repository in `android/build.gradle.kts`:

```kotlin
allprojects {
	repositories {
		google()
		mavenCentral()
		maven("https://jitpack.io")
	}
}
```

### iOS (Swift Package Manager)

This built-in player integration requires Swift Package Manager to be enabled.

Enable Swift Package Manager globally:

```bash
flutter config --enable-swift-package-manager
```

For existing projects, refresh iOS dependencies:

```bash
cd ios
rm -rf Pods Podfile.lock
flutter clean
flutter pub get
cd ios
pod install
```

Verify Swift Package Manager is enabled by opening `ios/Runner.xcworkspace` in Xcode and confirming Swift Package dependencies are present.

## What this example demonstrates

- Plugin initialization with Bunny credentials
- Retrieving playback URLs via `getVideoPlayData`
- Handling `BunnyStreamException` errors with code/message/details
