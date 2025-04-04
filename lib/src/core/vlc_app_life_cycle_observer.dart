import 'package:flutter/widgets.dart';
import 'package:flutter_better_vlc_player/src/core/vlc_player_controller.dart';

class VlcAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  VlcAppLifeCycleObserver(this._controller);

  final VlcPlayerController _controller;
  bool _wasPlayingBeforePause = false;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
      default:
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
