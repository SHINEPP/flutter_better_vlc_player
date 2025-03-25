import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_better_vlc_player_method_channel.dart';

abstract class FlutterBetterVlcPlayerPlatform extends PlatformInterface {
  /// Constructs a FlutterBetterVlcPlayerPlatform.
  FlutterBetterVlcPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBetterVlcPlayerPlatform _instance = MethodChannelFlutterBetterVlcPlayer();

  /// The default instance of [FlutterBetterVlcPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBetterVlcPlayer].
  static FlutterBetterVlcPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBetterVlcPlayerPlatform] when
  /// they register themselves.
  static set instance(FlutterBetterVlcPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
