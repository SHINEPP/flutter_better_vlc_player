import 'package:flutter/material.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';

class SpeedSheet extends StatefulWidget {
  const SpeedSheet({super.key, required this.controller});

  final VlcPlayerController controller;

  @override
  State<SpeedSheet> createState() => _SpeedSheetState();
}

class _SpeedSheetState extends State<SpeedSheet> {
  final _speed = <double>[];
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _updateSpeed();
  }

  _updateSpeed() async {
    final speed = await widget.controller.getPlaybackSpeed() ?? 1.0;
    _speed.clear();
    _speed.addAll([0.5, 1, 1.2, 1.25, 1.5, 2, 2.5, 3, 4, 5, 6]);
    _selectedIndex = _speed.indexWhere((s) => (s - speed).abs() < 0.1);
    debugPrint("_initAudios(), _selectedIndex = $_selectedIndex");
    setState(() {});
  }

  _onTapAudio(double speed) async {
    _selectedIndex = _speed.indexWhere((s) => (s - speed).abs() < 0.1);
    debugPrint("_onTapAudio(), _selectedIndex = $_selectedIndex");
    await widget.controller.setPlaybackSpeed(speed);
    await _updateSpeed();
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
              "倍速:",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _speed.length,
              padding: EdgeInsets.only(bottom: 60),
              itemBuilder: (context, index) {
                final selected = index == _selectedIndex;
                return ListTile(
                  selected: selected,
                  title: Text(
                    "x${_speed[index]}",
                    style: TextStyle(
                      color: selected ? Colors.blue : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _onTapAudio(_speed[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
