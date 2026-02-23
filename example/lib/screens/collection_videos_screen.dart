import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:blurhash/blurhash.dart';
import 'package:bunny_stream_flutter_example/models/bunny_collection.dart'
    as models;
import 'package:bunny_stream_flutter_example/models/video_detail.dart';
import 'package:bunny_stream_flutter_example/models/player_mode.dart';
import 'package:bunny_stream_flutter_example/config_extended.dart';
import 'package:bunny_stream_flutter_example/screens/video_player_screen.dart';
import 'package:bunny_stream_flutter/bunny_stream_flutter.dart';

class CollectionVideosScreen extends StatefulWidget {
  final models.BunnyCollection collection;
  final PlayerMode playerMode;

  const CollectionVideosScreen({
    super.key,
    required this.collection,
    required this.playerMode,
  });

  @override
  State<CollectionVideosScreen> createState() => _CollectionVideosScreenState();
}

class _CollectionVideosScreenState extends State<CollectionVideosScreen> {
  List<VideoDetailsModel> _videos = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bunny = BunnyStreamFlutter();

      // Initialize Bunny Stream with configuration from BunnyConfig.
      await bunny.initialize(
        accessKey: BunnyConfig.accessKey,
        libraryId: BunnyConfig.libraryId,
        cdnHostname: BunnyConfig.cdnHostname,
        token: BunnyConfig.secureToken,
        expires: BunnyConfig.tokenExpires,
      );

      final videos = await bunny.listVideos(
        libraryId: BunnyConfig.libraryId,
        collectionId: widget.collection.guid,
      );

      final videoDetails = videos
          .map((video) => VideoDetailsModel.fromJson(video.raw))
          .toList();

      developer.log(
        'Fetched ${videoDetails.length} videos for collection ${widget.collection.guid}',
        name: 'CollectionVideosScreen',
      );

      if (mounted) {
        setState(() {
          _videos = videoDetails;
          _isLoading = false;
        });
      }
    } on BunnyStreamException catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Bunny error: ${e.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading videos: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.displayName),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchVideos, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(child: Text('No videos in this collection'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _VideoTile(
          video: video,
          collection: widget.collection,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(
                  collection: widget.collection,
                  videoId: video.guid,
                  playerMode: widget.playerMode,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _VideoTile extends StatelessWidget {
  final VideoDetailsModel video;
  final models.BunnyCollection collection;
  final VoidCallback onTap;

  const _VideoTile({
    required this.video,
    required this.collection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    developer.log(
      'Video ${video.guid} - Title: ${video.title}, Duration: ${video.durationMinutes}, Views: ${video.views}',
      name: '_VideoTile',
    );
    final title = video.displayTitle;
    final thumbnailFileName = video.thumbnailFileName?.trim() ?? '';
    final thumbnailBlurhash = video.thumbnailBlurhash?.trim() ?? '';
    final thumbnailUrl = _buildThumbnailUrl(video, thumbnailFileName);
    final durationText = video.durationMinutes;
    final views = video.views;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 120,
              height: 80,
              color: Colors.grey[300],
              child: thumbnailUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildThumbnailPlaceholder(blurhash: thumbnailBlurhash),
                        Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildThumbnailPlaceholder(
                              blurhash: thumbnailBlurhash,
                            );
                          },
                        ),
                      ],
                    )
                  : _buildThumbnailPlaceholder(blurhash: thumbnailBlurhash),
            ),
            // Title and info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (durationText != null)
                      Text(
                        durationText,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    if (views != null)
                      Text(
                        '$views views',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            // Play icon
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.play_circle_outline,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a fully-qualified thumbnail URL for a video.
  ///
  /// Returns `null` when the thumbnail file name is empty or when the video
  /// GUID is missing. If [thumbnailFileName] is already an absolute URL, it is
  /// returned unchanged.
  ///
  /// For relative thumbnail names, this method uses the configured CDN host
  /// when available; otherwise, it falls back to Bunny's default host format:
  /// `vz-<libraryId>.b-cdn.net`.
  String? _buildThumbnailUrl(
    VideoDetailsModel video,
    String thumbnailFileName,
  ) {
    final thumbnailName = thumbnailFileName.trim();
    if (thumbnailName.isEmpty) return null;

    if (thumbnailName.startsWith('http://') ||
        thumbnailName.startsWith('https://')) {
      return thumbnailName;
    }

    final guid = video.guid?.trim() ?? '';
    if (guid.isEmpty) return null;

    final configuredHost = BunnyConfig.cdnHostname?.trim();
    final libraryId = video.videoLibraryId ?? BunnyConfig.libraryId;
    final host = (configuredHost != null && configuredHost.isNotEmpty)
        ? configuredHost
        : 'vz-$libraryId.b-cdn.net';

    return 'https://$host/$guid/$thumbnailName';
  }

  /// Builds a thumbnail placeholder using a decoded blurhash when provided.
  ///
  /// Falls back to a neutral placeholder when decoding is pending, fails, or
  /// when [blurhash] is empty.
  Widget _buildThumbnailPlaceholder({required String blurhash}) {
    if (blurhash.isNotEmpty) {
      return FutureBuilder<Uint8List?>(
        future: BlurHash.decode(blurhash, 32, 24),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null) {
            return Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            );
          }

          return Container(color: Colors.grey[350]);
        },
      );
    }

    return Container(
      color: Colors.grey[400],
      child: const Center(child: Icon(Icons.video_library, size: 40)),
    );
  }
}
