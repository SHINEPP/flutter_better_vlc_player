import 'package:flutter/widgets.dart';
import 'package:flutter_better_vlc_player/src/player/vlc_player_controller.dart';
import 'package:flutter_better_vlc_player/src/player/vlc_player_platform.dart';

// ignore: prefer_match_file_name
class VlcPlayer extends StatefulWidget {
  final VlcPlayerController controller;
  final double aspectRatio;
  final Widget? placeholder;
  final bool virtualDisplay;

  const VlcPlayer({
    /// The [VlcPlayerController] responsible for the video being rendered in
    /// this widget.
    required this.controller,

    /// The aspect ratio used to display the video.
    /// This MUST be provided, however it could simply be (parentWidth / parentHeight) - where parentWidth and
    /// parentHeight are the width and height of the parent perhaps as defined by a LayoutBuilder.
    required this.aspectRatio,

    /// Before the platform view has initialized, this placeholder will be rendered instead of the video player.
    /// This can simply be a [CircularProgressIndicator] (see the example.)
    this.placeholder,

    /// Specify whether Virtual displays or Hybrid composition is used on Android.
    /// iOS only uses Hybrid composition.
    this.virtualDisplay = true,
    super.key,
  });

  @override
  VlcPlayerState createState() => VlcPlayerState();
}

class VlcPlayerState extends State<VlcPlayer> {
  bool _isInitialized = false;

  //ignore: avoid_late_keyword
  late VoidCallback _listener;
  int? _textureId;

  VlcPlayerState() {
    _listener = () {
      if (!mounted) return;
      //
      final isInitialized = widget.controller.value.isInitialized;
      if (isInitialized != _isInitialized) {
        setState(() {
          _isInitialized = isInitialized;
        });
      }

      final int? newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  @override
  void initState() {
    super.initState();
    _isInitialized = widget.controller.value.isInitialized;
    _textureId = widget.controller.textureId;
    // Need to listen for initialization events since the actual initialization value
    // becomes available after asynchronous initialization finishes.
    widget.controller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: <Widget>[
          Offstage(
            offstage: _isInitialized,
            child: widget.placeholder ?? Container(),
          ),
          Offstage(
            offstage: !_isInitialized,
            child:
                _textureId != null
                    ? vlcPlayerPlatform.buildView(
                      _textureId!,
                      virtualDisplay: widget.virtualDisplay,
                    )
                    : Container(),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(VlcPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_listener);
      _isInitialized = widget.controller.value.isInitialized;
      _textureId = widget.controller.textureId;
      widget.controller.addListener(_listener);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }
}
