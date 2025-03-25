import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player_platform_interface.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBetterVlcPlayerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBetterVlcPlayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterBetterVlcPlayerPlatform initialPlatform = FlutterBetterVlcPlayerPlatform.instance;

  test('$MethodChannelFlutterBetterVlcPlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBetterVlcPlayer>());
  });

  test('getPlatformVersion', () async {
    FlutterBetterVlcPlayer flutterBetterVlcPlayerPlugin = FlutterBetterVlcPlayer();
    MockFlutterBetterVlcPlayerPlatform fakePlatform = MockFlutterBetterVlcPlayerPlatform();
    FlutterBetterVlcPlayerPlatform.instance = fakePlatform;

    expect(await flutterBetterVlcPlayerPlugin.getPlatformVersion(), '42');
  });
}
