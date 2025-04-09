import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';

class SubtitlesSheet extends StatefulWidget {
  const SubtitlesSheet({super.key, required this.controller});

  final VlcPlayerController controller;

  @override
  State<SubtitlesSheet> createState() => _SubtitlesSheetState();
}

class _SubtitlesSheetState extends State<SubtitlesSheet> {
  final _subtitles = <_Subtitle>[];
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _initSubtitles();
  }

  _initSubtitles() async {
    final selectedTrack = await widget.controller.getSpuTrack();
    final spuTracks = await widget.controller.getSpuTracks();
    final subtitles =
        spuTracks.entries
            .map((e) => _Subtitle(index: e.key, title: e.value))
            .toList();
    _subtitles.clear();
    _subtitles.addAll(subtitles);
    _selectedIndex = subtitles.indexWhere((s) => s.index == selectedTrack);
    setState(() {});
  }

  _onTapSubtitle(_Subtitle subtitle) async {
    _selectedIndex = _subtitles.indexOf(subtitle);
    await widget.controller.setSpuTrack(subtitle.index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "字幕:",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _subtitles.length,
            padding: EdgeInsets.only(bottom: 60),
            itemBuilder: (context, index) {
              return ListTile(
                selected: index == _selectedIndex,
                title: Text(
                  _subtitles[index].title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _onTapSubtitle(_subtitles[index]),
                selectedColor: Colors.blue,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Subtitle {
  final int index;
  final String title;

  _Subtitle({required this.index, required this.title});
}
