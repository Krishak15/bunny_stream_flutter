# Bunny Stream Flutter Example - API + Provider + Chewie Player

This example demonstrates a complete modern Flutter architecture for Bunny Stream integration.

## Architecture Overview

### **Layers**

1. **Models** (`models/`)
   - `bunny_collection.dart` — Bunny Collection data model with JSON serialization
   - `bunny_video.dart` — Bunny Video data model

2. **Services** (`services/`)
   - `dio_client.dart` — HTTP client with Dio for Bunny REST API calls

3. **Repositories** (`repositories/`)
   - `collection_repository.dart` — Bunny REST API methods (list, get collections)

4. **Providers** (`providers/`)
   - `collection_provider.dart` — State management with Provider
   - Manages collections, loading, error states

5. **Screens** (`screens/`)
   - `collections_screen.dart` — Grid of collections with thumbnails
   - `video_player_screen.dart` — Chewie video player with cupertino controls

6. **Config**
   - `config_extended.dart` — Environment variable loader (uses .env)
   - CDN hostname, token, expires defaults to null if not in .env

## Setup

### 1. Create `.env` file

```bash
cp .env.example .env
```

### 2. Fill in your Bunny credentials

```env
BUNNY_LIBRARY_ID=12345
BUNNY_ACCESS_KEY=your-stream-access-key
BUNNY_VIDEO_ID=your-video-guid
BUNNY_CDN_HOSTNAME=          # optional
BUNNY_SECURE_TOKEN=          # optional
BUNNY_EXPIRES=               # optional
```

### 3. Run the app

```bash
fvm flutter run -d android
# or
fvm flutter run -d ios
```

## Flow

1. **App Launch** → Loads `.env` config
2. **Config Validation** → Checks if `LIBRARY_ID` and `ACCESS_KEY` are set
3. **Main Screen** → Collections grid (uses Provider + Dio API)
4. **Click Collection** → Navigate to video player screen with Chewie
5. **Play Video** → Chewie player with cupertino-style controls (play/pause, seek, speed, mute)

## Features

✅ **Dio HTTP Client** — Type-safe REST API calls  
✅ **Provider State Management** — Reactive collections list  
✅ **Chewie Video Player** — Full-featured iOS-style UI  
✅ **Environment Config** — Secure credential storage  
✅ **Error Handling** — Graceful error displays  
✅ **Thumbnail Display** — Collection preview images  
✅ **Nullable Env Vars** — CDN, token, expires default to null  

## API Endpoints Used

- `/library/{libraryId}/collections` — List collections
- `/library/{libraryId}/collections/{collectionId}` — Get single collection
- Bunny Stream plugin `getVideoPlayData()` — Get playlist URLs

## Player Controls

**Chewie Cupertino Player Includes:**
- Play/Pause
- Seek slider
- Duration display
- Volume control (mute/unmute)
- Full screen
- Playback speed (user can adjust via controls)
- Subtitle/closed captions (if available)

## Error Handling

- Missing `.env` → Config Error Screen  
- API failures → Error display with retry button  
- Play data failure → Error message in player screen  
- Network errors → Caught via Dio interceptors  

## Dependencies Added

- `dio: ^5.4.0` — HTTP client
- `provider: ^6.1.0` — State management
- `chewie: ^1.8.0` — Video player
- `video_player: ^2.10.0` — Underlying video player plugin
- `flutter_dotenv: ^5.1.0` — Environment variable loading

## Notes

- All text fields have been removed
- Credentials now come from `.env` file only
- CDN hostname, token, and expires are optional (null if not in .env)
- Provider automatically handles state updates and rebuilds
- Chewie provides native iOS-style UI with full playlist controls
