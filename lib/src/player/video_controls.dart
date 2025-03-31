import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';

import 'video_track_shape.dart';

/// 底部控制
class VideoControls extends StatefulWidget {
  const VideoControls({
    super.key,
    required this.controller,
    required this.onTapFullScreen,
  });

  final VlcPlayerController controller;
  final VoidCallback onTapFullScreen;

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
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

  void _onSliderPositionChanged(double progress) async {
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
                    ? Icon(Icons.pause, size: 20)
                    : Icon(Icons.play_arrow, size: 20),
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
                onChanged: _onSliderPositionChanged,
              ),
            ),
          ),
          Text(duration, style: TextStyle(color: Colors.white, fontSize: 14)),
          IconButton(
            iconSize: 40,
            icon: Icon(Icons.fullscreen, size: 20),
            color: Colors.white,
            onPressed: widget.onTapFullScreen,
          ),
        ],
      ),
    );
  }
}
