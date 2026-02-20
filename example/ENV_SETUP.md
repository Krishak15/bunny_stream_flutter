# Environment Configuration Setup

## Quick Start

1. **Copy the template file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your Bunny credentials:**
   Edit `.env` and add your actual values:
   ```env
   BUNNY_ACCESS_KEY=your-stream-access-key
   ```

3. **Run the app:**
   ```bash
   fvm flutter run -d android
   # or
   fvm flutter run -d ios
   ```

## What goes in `.env`?

All fields from Bunny Stream console:

| Field | Source | Required | Example |
|-------|--------|----------|---------|
| `BUNNY_ACCESS_KEY` | Bunny console → Access Keys | Yes | `abc-xyz-...` |
| `BUNNY_CDN_HOSTNAME` | Bunny console → Pull Zone (optional) | No | `vz-12345.b-cdn.net` |
| `BUNNY_SECURE_TOKEN` | Issued by your backend (optional) | No | `secure-token-abc` |
| `BUNNY_EXPIRES` | Unix timestamp from backend (optional) | No | `1735689600` |

## Security notes

- **Never commit `.env` to git** — it's in `.gitignore`
- **For production:** Load credentials from a secure backend API, not `.env`
- **For development:** Use `.env` locally; each developer has their own copy with their credentials
- **Token auth:** If your Bunny library requires token-based playback, your backend must issue `BUNNY_SECURE_TOKEN` and `BUNNY_EXPIRES`

## Accessing config in code

```dart
import 'config.dart';

// In any widget/service:
final libraryId = BunnyConfig.libraryId;
final accessKey = BunnyConfig.accessKey;
final videoId = BunnyConfig.videoId;

// Check if fully configured
if (BunnyConfig.isConfigured) {
  print('Ready to use');
} else {
  print('Missing config: ${BunnyConfig.debugStatus()}');
}
```

## Troubleshooting

**"BUNNY_ACCESS_KEY is empty"**
- → `.env` file not found or not loaded
- → Run "Reload from .env" button in the example app

**App crashes on load with "Unable to load .env"**
- → Copy `.env.example` to `.env` first
- → Make sure `.env` is a valid text file
