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
  late VlcPlayerController _controller;

  @override
  void initState() {
    super.initState();

    debugPrint("MyApp, initState()");
    _controller = VlcPlayerController.network(
      'https://media.w3.org/2010/05/sintel/trailer.mp4',
    );
  }

  @override
  void dispose() {
    super.dispose();

    debugPrint("MyApp, dispose()");
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: VlcPlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
            placeholder: CircularProgressIndicator(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
