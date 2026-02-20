import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:bunny_stream_flutter_example/models/bunny_collection.dart'
    as models;
import 'package:bunny_stream_flutter_example/config_extended.dart';
import 'package:bunny_stream_flutter_example/screens/video_player_screen.dart';
import 'package:bunny_stream_flutter/bunny_stream_flutter.dart';

class CollectionVideosScreen extends StatefulWidget {
  final models.BunnyCollection collection;

  const CollectionVideosScreen({super.key, required this.collection});

  @override
  State<CollectionVideosScreen> createState() => _CollectionVideosScreenState();
}

class _CollectionVideosScreenState extends State<CollectionVideosScreen> {
  List<BunnyVideo> _videos = [];
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

      developer.log(
        'Fetched ${videos.length} videos for collection ${widget.collection.guid}',
        name: 'CollectionVideosScreen',
      );

      if (mounted) {
        setState(() {
          _videos = videos;
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
                  videoId: video.id,
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
  final BunnyVideo video;
  final models.BunnyCollection collection;
  final VoidCallback onTap;

  const _VideoTile({
    required this.video,
    required this.collection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = video.raw['title'] as String? ?? 'Untitled Video';
    final thumbnail =
        video.raw['thumbnail'] as String? ??
        video.raw['previewUrl'] as String? ??
        '';
    final length = video.raw['length'] as int?;
    final views = video.raw['views'] as int?;

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
              child: thumbnail.isNotEmpty
                  ? Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[400],
                          child: const Center(
                            child: Icon(Icons.video_library, size: 40),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[400],
                      child: const Center(
                        child: Icon(Icons.video_library, size: 40),
                      ),
                    ),
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
                    if (length != null)
                      Text(
                        '${(length / 60).toStringAsFixed(1)} min',
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
}
