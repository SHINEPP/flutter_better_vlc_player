import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';

class AudiosSheet extends StatefulWidget {
  const AudiosSheet({super.key, required this.controller});

  final VlcPlayerController controller;

  @override
  State<AudiosSheet> createState() => _AudiosSheetState();
}

class _AudiosSheetState extends State<AudiosSheet> {
  final _audios = <_Audio>[];
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _initAudios();
  }

  _initAudios() async {
    final selectedTrack = await widget.controller.getAudioTrack();
    final audioTracks = await widget.controller.getAudioTracks();
    final audios =
        audioTracks.entries
            .map((e) => _Audio(index: e.key, title: e.value))
            .toList();
    _audios.clear();
    _audios.addAll(audios);
    _selectedIndex = audios.indexWhere((s) => s.index == selectedTrack);
    setState(() {});
  }

  _onTapAudio(_Audio subtitle) async {
    _selectedIndex = _audios.indexOf(subtitle);
    await widget.controller.setAudioTrack(subtitle.index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16),
            margin: EdgeInsets.only(top: 8),
            child: Text(
              "音轨:",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _audios.length,
              padding: EdgeInsets.only(bottom: 60),
              itemBuilder: (context, index) {
                return ListTile(
                  selected: index == _selectedIndex,
                  title: Text(
                    _audios[index].title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _onTapAudio(_audios[index]),
                  selectedColor: Colors.blue,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Audio {
  final int index;
  final String title;

  _Audio({required this.index, required this.title});
}
