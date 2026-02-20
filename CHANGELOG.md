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
