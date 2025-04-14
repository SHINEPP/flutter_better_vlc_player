import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/video_player_controls.dart';
import 'package:flutter_better_vlc_player/src/player/gesture_recognizer.dart';

class VideoPlayerFullScreen extends StatefulWidget {
  const VideoPlayerFullScreen({super.key, required this.controller});

  final VlcPlayerController controller;

  @override
  State<VideoPlayerFullScreen> createState() => _VideoPlayerFullScreenState();
}

class _VideoPlayerFullScreenState extends State<VideoPlayerFullScreen> {
  bool _showControls = false;
  double _controlsOpacity = 0.0;
  Timer? _hideControlsTimer;

  void _toggleControls() {
    _hideControlsTimer?.cancel();

    setState(() {
      _showControls = true;
      _controlsOpacity = 1.0;
    });

    _hideControlsTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsOpacity = 0.0;
        });
      }
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _hideControlsTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.controller,
            child: GestureVideoPlayer(
              aspectRatio: aspectRatio,
              onTap: _toggleControls,
              controller: widget.controller,
            ),
          ),
          Visibility(
            visible: _showControls,
            child: Container(
              alignment: Alignment.topLeft,
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: _controlsOpacity,
                  duration: Duration(milliseconds: 500),
                  child: VideoPlayerMenu(
                    controller: widget.controller,
                    isFullScreen: true,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showControls,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: _controlsOpacity,
                  duration: Duration(milliseconds: 500),
                  child: VideoPlayerControls(
                    controller: widget.controller,
                    isFullScreen: true,
                    onFullScreen: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
