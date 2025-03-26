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

    _controller = VlcPlayerController.network(
      'https://media.w3.org/2010/05/sintel/trailer.mp4',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('VLC')),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VlcPlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
                placeholder: CircularProgressIndicator(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
