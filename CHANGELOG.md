## 0.2.0

* **Fixes**:
  - iOS & Android built-in player wrapper
  - Improved touch handling for native built-in player platform views by forwarding gestures eagerly in embedded mode (Android/iOS), improving reliability of in-player control taps.

* **Example updates**:
  - Added Chewie playback hooks in the example `VideoPlayerScreen`:
    - `onPositionChanged` for live playback position updates.
    - `onControllersReady` to expose `ChewieController` and `VideoPlayerController` when initialized.
  - Added safe listener attach/detach flow for position updates across quality switches.

* **Release**:
  - Bumped package version from `0.1.0+beta` to `0.2.0`.

## 0.1.0+beta

* **Documentation**: 
  - Added native implementation status (Android/iOS method availability)
  - Included security best practices for token/accessKey handling

* **Features**:
  - Cross-platform video playback URL generation (HLS + MP4 renditions)
  - Video metadata and collection retrieval via Bunny Stream API
  - Secure tokenized playback support (optional token + expires)
  - Unified Dart error handling with `BunnyStreamException`

* **Platforms**:
  - Android (minSdk 26)
  - iOS (15.0+)
