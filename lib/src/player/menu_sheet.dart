import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/audios_sheet.dart';
import 'package:flutter_better_vlc_player/src/player/subtitles_sheet.dart';

class MenuSheet extends StatelessWidget {
  const MenuSheet({super.key, required this.controller});

  final VlcPlayerController controller;

  _onTapSubtitles(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.white,
              body: SubtitlesSheet(controller: controller),
            ),
      ),
    );
  }

  _onTapAudios(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.white,
              body: AudiosSheet(controller: controller),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16),
            margin: EdgeInsets.only(top: 8),
            child: Text(
              "菜单:",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 60),
              children: [
                ListTile(
                  title: Text(
                    "字幕",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _onTapSubtitles(context),
                ),
                ListTile(
                  title: Text(
                    "音轨",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _onTapAudios(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
