import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_better_vlc_player_platform_interface.dart';

/// An implementation of [FlutterBetterVlcPlayerPlatform] that uses method channels.
class MethodChannelFlutterBetterVlcPlayer extends FlutterBetterVlcPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_better_vlc_player');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
