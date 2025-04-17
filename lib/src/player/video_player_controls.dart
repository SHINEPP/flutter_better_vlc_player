import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/brightness_utils.dart';
import 'package:flutter_better_vlc_player/src/player/gesture_recognizer.dart';
import 'package:flutter_better_vlc_player/src/player/sheet/menu_sheet.dart';
import 'package:flutter_better_vlc_player/src/player/sheet/side_sheet.dart';

import 'video_track_shape.dart';

/// 顶部控制
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
    _controller.addListener(_updateVideoValue);
    _updateVideoValue();
  }

  void _updateVideoValue() {
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
    _controller.removeListener(_updateVideoValue);
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

/// 触摸控制
enum GestureTipType { none, forward, rewind, volume, brightness }

class GestureTip {
  GestureTip({required this.type, required this.message});

  final GestureTipType type;
  final String message;

  factory GestureTip.none() =>
      GestureTip(type: GestureTipType.none, message: "");

  factory GestureTip.forward(String message) =>
      GestureTip(type: GestureTipType.forward, message: message);

  factory GestureTip.retreat(String message) =>
      GestureTip(type: GestureTipType.rewind, message: message);

  factory GestureTip.volume(String message) =>
      GestureTip(type: GestureTipType.volume, message: message);

  factory GestureTip.brightness(String message) =>
      GestureTip(type: GestureTipType.brightness, message: message);
}

class GestureVideoPlayer extends StatefulWidget {
  const GestureVideoPlayer({
    super.key,
    required this.controller,
    required this.aspectRatio,
    required this.isFullScreen,
    this.onTap,
  });

  final VlcPlayerController controller;
  final double aspectRatio;
  final bool isFullScreen;
  final VoidCallback? onTap;

  @override
  State<GestureVideoPlayer> createState() => _GestureVideoPlayerState();
}

class _GestureVideoPlayerState extends State<GestureVideoPlayer> {
  late VlcPlayerController _controller;
  final _tip = ValueNotifier<GestureTip>(GestureTip.none());
  var _lastPlaybackSpeed = 1.0;

  var _startPosition = 0;
  var _showPosition = 0;
  var _totalDuration = 0;

  var _startBrightness = 0.0;
  var _startVolume = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  /// long press
  void _onLongPressStart() async {
    _lastPlaybackSpeed = await _controller.getPlaybackSpeed() ?? 1.0;
    await _controller.setPlaybackSpeed(3);
    _tip.value = GestureTip.forward("快进 3x");
  }

  void _onLongPressEnd() async {
    await _controller.setPlaybackSpeed(_lastPlaybackSpeed);
    _tip.value = GestureTip.none();
  }

  /// left
  void _onSlideHorizonStart() async {
    final position = await _controller.getPosition();
    final duration = await _controller.getDuration();
    _startPosition = position.inMilliseconds;
    _totalDuration = duration.inMilliseconds;
  }

  void _onSlideHorizonUpdate(double ratio) async {
    final minute = widget.isFullScreen ? 15 : 5;
    _showPosition = _startPosition + (minute * 60 * 1000 * ratio).toInt();
    final position = Duration(
      milliseconds: min(max(_showPosition, 0), _totalDuration),
    );
    final positionText = position.toString().split('.').first.padLeft(8, '0');
    _tip.value =
        ratio > 0
            ? GestureTip.forward("快进 $positionText")
            : GestureTip.retreat("快退 $positionText");
  }

  void _onSlideHorizonEnd(double ratio) async {
    final position = Duration(
      milliseconds: min(max(_showPosition, 0), _totalDuration),
    );
    await _controller.seekTo(position);
    _tip.value = GestureTip.none();
  }

  /// left up or down
  void _onSlideLeftVerticalStart() async {
    _startBrightness = await BrightNessUtils.systemBrightness;
  }

  void _onSlideLeftVerticalUpdate(double ratio) async {
    final brightness = min(max(_startBrightness + ratio, 0.0), 1.0);
    await BrightNessUtils.setSystemBrightness(brightness);
    _tip.value = GestureTip.brightness(
      "${(brightness * 100).toStringAsFixed(0)}%",
    );
  }

  void _onSlideLeftVerticalEnd(double ratio) async {
    final brightness = min(max(_startBrightness + ratio, 0.0), 1.0);
    await BrightNessUtils.setSystemBrightness(brightness);
    _tip.value = GestureTip.none();
  }

  /// right up or down
  void _onSlideRightVerticalStart() async {
    _startVolume = await _controller.getVolume() ?? 0;
  }

  void _onSlideRightVerticalUpdate(double ratio) async {
    final volume = min(max(_startVolume + ratio * 100, 0), 100);
    await _controller.setVolume(volume.toInt());
    _tip.value = GestureTip.volume("${volume.toInt()}");
  }

  void _onSlideRightVerticalEnd(double ratio) async {
    final volume = min(max(_startVolume + ratio * 100, 0), 100);
    await _controller.setVolume(volume.toInt());
    _tip.value = GestureTip.none();
  }

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
            onSlideHorizonStart: _onSlideHorizonStart,
            onSlideHorizonUpdate: _onSlideHorizonUpdate,
            onSlideHorizonEnd: _onSlideHorizonEnd,
            onSlideLeftVerticalStart: _onSlideLeftVerticalStart,
            onSlideLeftVerticalUpdate: _onSlideLeftVerticalUpdate,
            onSlideLeftVerticalEnd: _onSlideLeftVerticalEnd,
            onSlideRightVerticalStart: _onSlideRightVerticalStart,
            onSlideRightVerticalUpdate: _onSlideRightVerticalUpdate,
            onSlideRightVerticalEnd: _onSlideRightVerticalEnd,
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
                visible: value.type != GestureTipType.none,
                child: Container(
                  alignment: Alignment(0, -0.333),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.black12,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _getGestureTipTypeIcon(value.type),
                        SizedBox(width: 4),
                        Text(
                          value.message,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
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

  Widget _getGestureTipTypeIcon(GestureTipType type) {
    switch (type) {
      case GestureTipType.none:
        return Container();
      case GestureTipType.forward:
        return Icon(Icons.fast_forward, size: 20, color: Colors.white);
      case GestureTipType.rewind:
        return Icon(Icons.fast_rewind, size: 20, color: Colors.white);
      case GestureTipType.volume:
        return Icon(Icons.volume_up, size: 20, color: Colors.white);
      case GestureTipType.brightness:
        return Icon(Icons.brightness_7, size: 16, color: Colors.white);
    }
  }
}
