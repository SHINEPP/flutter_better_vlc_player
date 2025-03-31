import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player_example/videoplayer/video_controls.dart';
import 'package:flutter_better_vlc_player_example/videoplayer/video_full_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> with WidgetsBindingObserver {
  late VlcPlayerController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    debugPrint("MyApp, initState()");
    _controller = VlcPlayerController.network(
      'https://media.w3.org/2010/05/sintel/trailer.mp4',
    );
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
          builder: (context) => VideoFullScreen(controller: _controller),
        ),
      );
    }

    await WakelockPlus.disable();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      debugPrint("MyApp, didChangeAppLifecycleState(), detached");
      _controller.dispose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    debugPrint("MyApp, dispose()");
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VlcPlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
            placeholder: CupertinoActivityIndicator(
              radius: 14,
              color: Colors.white,
            ),
          ),
          VideoControls(
            controller: _controller,
            onTapFullScreen: () {
              _onPushFullScreen(context);
            },
          ),
        ],
      ),
    );
  }
}
