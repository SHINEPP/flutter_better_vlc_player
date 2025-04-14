import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/menu_sheet.dart';
import 'package:flutter_better_vlc_player/src/player/side_sheet.dart';
import 'package:flutter_better_vlc_player/src/player/video_player_gesture.dart';

import 'video_track_shape.dart';

/// 底部控制
class VideoPlayerControls extends StatefulWidget {
  const VideoPlayerControls({
    super.key,
    required this.controller,
    required this.onFullScreen,
    required this.isFullScreen,
  });

  final VlcPlayerController controller;
  final VoidCallback onFullScreen;
  final bool isFullScreen;

  @override
  State<VideoPlayerControls> createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  late VlcPlayerController _controller;

  double sliderValue = 0.0;
  String position = '';
  String duration = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_onValueListener);
  }

  void _onValueListener() {
    if (!mounted || !_controller.value.isInitialized) {
      return;
    }

    final oPosition = _controller.value.position;
    final oDuration = _controller.value.duration;
    final posValue = oPosition.inMilliseconds;
    final durValue = oDuration.inMilliseconds;

    setState(() {
      position = oPosition.toString().split('.').first.padLeft(8, '0');
      duration = oDuration.toString().split('.').first.padLeft(8, '0');
      sliderValue = durValue > 0 && posValue >= 0 ? posValue / durValue : 0;
    });
  }

  Future<void> _togglePlaying() async {
    _controller.value.isPlaying
        ? await _controller.pause()
        : await _controller.play();
  }

  void _onPositionChanged(double progress) async {
    final time = _controller.value.duration.inMilliseconds * progress;
    await _controller.setTime(time.toInt());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_onValueListener);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          IconButton(
            color: Colors.white,
            iconSize: 40,
            icon:
                _controller.value.isPlaying
                    ? Icon(Icons.pause, size: 24)
                    : Icon(Icons.play_arrow, size: 24),
            onPressed: _togglePlaying,
          ),
          Text(position, style: TextStyle(color: Colors.white, fontSize: 14)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                trackShape: VideoTrackShape(),
              ),
              child: Slider(
                padding: EdgeInsets.symmetric(horizontal: 16),
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                value: sliderValue,
                min: 0.0,
                max: 1.0,
                onChanged: _onPositionChanged,
              ),
            ),
          ),
          Text(duration, style: TextStyle(color: Colors.white, fontSize: 14)),
          IconButton(
            iconSize: 40,
            icon: Icon(
              widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 24,
            ),
            color: Colors.white,
            onPressed: widget.onFullScreen,
          ),
        ],
      ),
    );
  }
}

/// 底部控制
class VideoPlayerMenu extends StatelessWidget {
  const VideoPlayerMenu({
    super.key,
    required this.controller,
    required this.isFullScreen,
  });

  final VlcPlayerController controller;
  final bool isFullScreen;

  void _onTapMenu(BuildContext context) {
    if (isFullScreen) {
      showRightSideSheetWithNavigator(
        context,
        MenuSheet(controller: controller),
      );
    } else {
      showBottomSideSheetWithNavigator(
        context,
        MenuSheet(controller: controller),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            iconSize: 40,
            icon: Icon(Icons.more_vert, size: 24),
            color: Colors.white,
            onPressed: () => _onTapMenu(context),
          ),
        ],
      ),
    );
  }
}

/// 触摸控制
class GestureVideoPlayer extends StatefulWidget {
  const GestureVideoPlayer({
    super.key,
    required this.controller,
    required this.aspectRatio,
    this.onTap,
  });

  final VlcPlayerController controller;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  State<GestureVideoPlayer> createState() => _GestureVideoPlayerState();
}

class _GestureVideoPlayerState extends State<GestureVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayerGesture(
            onTap: widget.onTap,
            child: VlcPlayer(
              controller: widget.controller,
              aspectRatio: widget.aspectRatio,
              placeholder: CupertinoActivityIndicator(
                radius: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
