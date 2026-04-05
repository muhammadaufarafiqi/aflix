import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../theme/app_theme.dart';

class YoutubePlayerWrapper extends StatefulWidget {
  final String videoId;
  final String title;
  final VoidCallback onBack;

  const YoutubePlayerWrapper({
    super.key,
    required this.videoId,
    required this.title,
    required this.onBack,
  });

  @override
  State<YoutubePlayerWrapper> createState() => _YoutubePlayerWrapperState();
}

class _YoutubePlayerWrapperState extends State<YoutubePlayerWrapper> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primary,
        progressColors: ProgressBarColors(
          playedColor: AppTheme.primary,
          handleColor: AppTheme.primary,
        ),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: widget.onBack,
          ),
          title: Text(widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: Center(child: player),
      ),
    );
  }
}