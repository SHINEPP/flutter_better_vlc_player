
import 'flutter_better_vlc_player_platform_interface.dart';

class FlutterBetterVlcPlayer {
  Future<String?> getPlatformVersion() {
    return FlutterBetterVlcPlayerPlatform.instance.getPlatformVersion();
  }
}
