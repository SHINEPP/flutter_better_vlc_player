import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/gesture_recognizer.dart';
import 'package:flutter_better_vlc_player/src/player/menu_sheet.dart';
import 'package:flutter_better_vlc_player/src/player/side_sheet.dart';

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
  late VlcPlayerController _controller;
  final _tip = ValueNotifier<String>("");
  var _lastPlaybackSpeed = 1.0;

  var _startPosition = 0;
  var _showPosition = 0;
  var _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  /// long press
  void _onLongPressStart() async {
    _lastPlaybackSpeed = await _controller.getPlaybackSpeed() ?? 1.0;
    await _controller.setPlaybackSpeed(3);
    _tip.value = "快进 x3";
  }

  void _onLongPressEnd() async {
    await _controller.setPlaybackSpeed(_lastPlaybackSpeed);
    _tip.value = "";
  }

  /// left
  void _onSlideLeftStart() async {
    final position = await _controller.getPosition();
    _startPosition = position.inMilliseconds;
  }

  void _onSlideLeftUpdate(double ratio) async {
    _showPosition = _startPosition - (30000 * ratio).toInt();
    final position = Duration(milliseconds: max(_showPosition, 0));
    final positionText = position.toString().split('.').first.padLeft(8, '0');
    _tip.value = "快退 $positionText";
  }

  void _onSlideLeftEnd(double ratio) async {
    final position = Duration(milliseconds: min(_showPosition, _totalDuration));
    await _controller.seekTo(position);
    _tip.value = "";
  }

  /// right
  void _onSlideRightStart() async {
    final position = await _controller.getPosition();
    final duration = await _controller.getDuration();
    _startPosition = position.inMilliseconds;
    _totalDuration = duration.inMilliseconds;
  }

  void _onSlideRightUpdate(double ratio) async {
    _showPosition = _startPosition + (30000 * ratio).toInt();
    final position = Duration(milliseconds: min(_showPosition, _totalDuration));
    final positionText = position.toString().split('.').first.padLeft(8, '0');
    _tip.value = "快进 $positionText";
  }

  void _onSlideRightEnd(double ratio) async {
    final position = Duration(milliseconds: min(_showPosition, _totalDuration));
    await _controller.seekTo(position);
    _tip.value = "";
  }

  /// left up or down
  void _onSlideLeftUpStart() async {}

  void _onSlideLeftUpUpdate(double ratio) async {}

  void _onSlideLeftUpEnd(double ration) async {}

  void _onSlideLeftDownStart() async {}

  void _onSlideLeftDownUpdate(double ratio) async {}

  void _onSlideLeftDownEnd(double ratio) async {}

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureRecognizer(
            onTap: widget.onTap,
            onLongPressStart: _onLongPressStart,
            onLongPressEnd: _onLongPressEnd,
            onSlideLeftStart: _onSlideLeftStart,
            onSlideLeftUpdate: _onSlideLeftUpdate,
            onSlideLeftEnd: _onSlideLeftEnd,
            onSlideRightStart: _onSlideRightStart,
            onSlideRightUpdate: _onSlideRightUpdate,
            onSlideRightEnd: _onSlideRightEnd,
            onSlideLeftUpStart: _onSlideLeftUpStart,
            onSlideLeftUpUpdate: _onSlideLeftUpUpdate,
            onSlideLeftUpEnd: _onSlideLeftUpEnd,
            onSlideLeftDownStart: _onSlideLeftDownStart,
            onSlideLeftDownUpdate: _onSlideLeftDownUpdate,
            onSlideLeftDownEnd: _onSlideLeftDownEnd,
            child: VlcPlayer(
              controller: widget.controller,
              aspectRatio: widget.aspectRatio,
              placeholder: CupertinoActivityIndicator(
                radius: 14,
                color: Colors.white,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _tip,
            builder: (context, value, child) {
              return Visibility(
                visible: true,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black12,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
