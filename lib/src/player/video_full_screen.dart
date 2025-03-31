import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/video_controls.dart';

class VideoFullScreen extends StatefulWidget {
  const VideoFullScreen({super.key, required this.controller});

  final VlcPlayerController controller;

  @override
  State<VideoFullScreen> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
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
      setState(() {
        _controlsOpacity = 0.0;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _showControls = false;
        });
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
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            VlcPlayer(
              controller: widget.controller,
              aspectRatio: aspectRatio,
              placeholder: CupertinoActivityIndicator(
                radius: 14,
                color: Colors.white,
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
                    child: VideoControls(
                      controller: widget.controller,
                      onTapFullScreen: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
