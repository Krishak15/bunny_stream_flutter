import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:bunny_stream_flutter_example/models/bunny_collection.dart'
    as models;
import 'package:bunny_stream_flutter/bunny_stream_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.videoId != null) {
      _initializePlayer(widget.videoId!);
    }
  }

  Future<void> _initializePlayer(String videoId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bunny = BunnyStreamFlutter();

      // Get play data from plugin
      final playData = await bunny.getVideoPlayData(
        libraryId: widget.collection.videoLibraryId,
        videoId: videoId,
      );

      final url = playData.playlistUrl.trim().isNotEmpty
          ? playData.playlistUrl
          : playData.fallbackUrl;

      if (url.isEmpty) {
        setState(() {
          _error = 'No playable URL available';
          _isLoading = false;
        });
        return;
      }

      final videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoController.initialize();

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
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
            if (widget.videoId != null)
              ElevatedButton(
                onPressed: () => _initializePlayer(widget.videoId!),
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
