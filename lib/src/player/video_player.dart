import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/video_player_controls.dart';
import 'package:flutter_better_vlc_player/src/player/video_player_full_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key, required this.controller});

  final VlcPlayerController controller;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> with WidgetsBindingObserver {
  late VlcPlayerController _controller;

  static final _aspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = widget.controller;
  }

  _onPushFullScreen(BuildContext context) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await WakelockPlus.enable();

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerFullScreen(controller: _controller),
        ),
      );
    }

    await WakelockPlus.disable();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _controller.dispose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoPlayerMenu(controller: _controller, isFullScreen: false),
          Hero(
            tag: _controller,
            child: VlcPlayer(
              controller: _controller,
              aspectRatio: _aspectRatio,
              placeholder: CupertinoActivityIndicator(
                radius: 14,
                color: Colors.white,
              ),
            ),
          ),
          VideoPlayerControls(
            controller: _controller,
            isFullScreen: false,
            onFullScreen: () {
              _onPushFullScreen(context);
            },
          ),
        ],
      ),
    );
  }
}
