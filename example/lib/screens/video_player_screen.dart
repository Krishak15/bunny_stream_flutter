import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:bunny_stream_flutter_example/models/bunny_collection.dart'
    as models;
import 'package:bunny_stream_flutter_example/config_extended.dart';
import 'package:bunny_stream_flutter/bunny_stream_flutter.dart';

enum VideoQuality { auto, p360, p720, p1080 }

extension VideoQualityExt on VideoQuality {
  String get label {
    switch (this) {
      case VideoQuality.auto:
        return 'Auto';
      case VideoQuality.p360:
        return '360p';
      case VideoQuality.p720:
        return '720p';
      case VideoQuality.p1080:
        return '1080p';
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final models.BunnyCollection collection;
  final String? videoId;

  const VideoPlayerScreen({super.key, required this.collection, this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  String? _error;
  VideoQuality _selectedQuality = VideoQuality.auto;
  BunnyVideoPlayData? _cachedPlayData;
  List<VideoQuality> _availableQualities = [VideoQuality.auto];

  @override
  void initState() {
    super.initState();
    final resolvedVideoId =
        widget.videoId?.trim() ?? BunnyConfig.videoId.trim();
    if (resolvedVideoId.isNotEmpty) {
      _initializePlayer(resolvedVideoId);
    } else {
      _error = 'No video ID provided';
    }
  }

  Future<void> _initializePlayer(String videoId) async {
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

      // Fetch video metadata to get available resolutions
      final videoMetadata = await bunny.getVideo(
        libraryId: BunnyConfig.libraryId,
        videoId: videoId,
      );

      developer.log(
        'Video metadata fetched | availableResolutions=${videoMetadata.availableResolutions}',
        name: 'VideoPlayerScreen',
      );

      // Build available quality options based on actual resolutions
      _availableQualities = _buildAvailableQualities(
        videoMetadata.availableResolutions,
      );

      // Get play data from plugin
      final playData = await bunny.getVideoPlayData(
        libraryId: BunnyConfig.libraryId,
        videoId: videoId,
        token: BunnyConfig.secureToken,
        expires: BunnyConfig.tokenExpires,
      );

      _cachedPlayData = playData;

      developer.log(
        'Play data URLs for videoId=$videoId | playlistUrl=${playData.playlistUrl} | fallbackUrl=${playData.fallbackUrl}',
        name: 'VideoPlayerScreen',
      );

      await _loadQuality(_selectedQuality, playData);
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
          _error = 'Error loading video: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<VideoQuality> _buildAvailableQualities(List<String> resolutions) {
    final qualities = <VideoQuality>[VideoQuality.auto];

    // Map Bunny resolution strings to quality enum
    for (final res in resolutions) {
      switch (res) {
        case '360p':
          qualities.add(VideoQuality.p360);
          break;
        case '720p':
          qualities.add(VideoQuality.p720);
          break;
        case '1080p':
          qualities.add(VideoQuality.p1080);
          break;
      }
    }

    developer.log(
      'Available qualities: ${qualities.map((q) => q.label).join(", ")}',
      name: 'VideoPlayerScreen',
    );

    return qualities;
  }

  Future<void> _loadQuality(
    VideoQuality quality,
    BunnyVideoPlayData playData,
  ) async {
    final url = _getUrlForQuality(quality, playData);

    developer.log(
      'Selected video URL for playback (${quality.label}): $url',
      name: 'VideoPlayerScreen',
    );

    if (url.isEmpty) {
      developer.log(
        'No playable URL available for quality ${quality.label}',
        name: 'VideoPlayerScreen',
      );
      setState(() {
        _error = 'No playable URL available for ${quality.label}';
        _isLoading = false;
      });
      return;
    }

    // Store current position if switching quality
    final currentPosition = _videoPlayerController?.value.position;
    final wasPlaying = _videoPlayerController?.value.isPlaying ?? false;

    // Dispose old controllers
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    final videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await videoController.initialize();

    // Restore position if switching quality
    if (currentPosition != null && currentPosition > Duration.zero) {
      await videoController.seekTo(currentPosition);
    }

    final chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: wasPlaying || currentPosition == null,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).primaryColor,
        handleColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey[300]!,
      ),
    );

    _videoPlayerController = videoController;
    _chewieController = chewieController;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getUrlForQuality(VideoQuality quality, BunnyVideoPlayData playData) {
    switch (quality) {
      case VideoQuality.auto:
        return playData.playlistUrl.trim().isNotEmpty
            ? playData.playlistUrl
            : playData.fallbackUrl;
      case VideoQuality.p360:
        return playData.url360p;
      case VideoQuality.p720:
        return playData.url720p;
      case VideoQuality.p1080:
        return playData.url1080p;
    }
  }

  Future<void> _changeQuality(VideoQuality newQuality) async {
    if (_cachedPlayData == null || _selectedQuality == newQuality) return;

    setState(() {
      _selectedQuality = newQuality;
      _isLoading = true;
    });

    await _loadQuality(newQuality, _cachedPlayData!);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.displayName),
        centerTitle: true,
        actions: [
          if (_chewieController != null && _availableQualities.length > 1)
            PopupMenuButton<VideoQuality>(
              icon: const Icon(Icons.settings),
              tooltip: 'Quality',
              onSelected: _changeQuality,
              itemBuilder: (context) => [
                for (final quality in _availableQualities)
                  PopupMenuItem(
                    value: quality,
                    child: Row(
                      children: [
                        if (_selectedQuality == quality)
                          const Icon(Icons.check, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(quality.label),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final retryVideoId = widget.videoId?.trim() ?? BunnyConfig.videoId.trim();

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
            if (retryVideoId.isNotEmpty)
              ElevatedButton(
                onPressed: () => _initializePlayer(retryVideoId),
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    if (_chewieController == null) {
      return const Center(child: Text('No video loaded'));
    }

    return Column(
      children: [
        Expanded(child: Chewie(controller: _chewieController!)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.collection.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.collection.videoCount} videos in collection',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
