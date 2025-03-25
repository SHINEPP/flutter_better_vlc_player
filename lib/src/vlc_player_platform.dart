import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';

final VlcPlayerPlatform vlcPlayerPlatform =
    VlcPlayerPlatform.instance
      // This will clear all open videos on the platform when a full restart is
      // performed.
      ..init();
