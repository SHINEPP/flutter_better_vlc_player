import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: VideoPlayer(
            key: _key,
            controller: VlcPlayerController.network(
              'http://192.168.1.14:9000/video/长相思(1-2)/Lost.You.Forever.S01E05.2023.1080p.NF.WEB-DL.DDP2.0.H264-PanWEB.mkv',
            ),
          ),
        ),
      ),
    );
  }
}
