import 'package:flutter/widgets.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/core/vlc_player_controller.dart';

class VlcPlayer extends StatefulWidget {
  const VlcPlayer({
    super.key,

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
  });

  final VlcPlayerController controller;
  final double aspectRatio;
  final Widget? placeholder;

  @override
  VlcPlayerState createState() => VlcPlayerState();
}

class VlcPlayerState extends State<VlcPlayer> {
  bool _isInitialized = false;
  int? _viewId;

  @override
  void initState() {
    super.initState();
    _isInitialized = widget.controller.value.isInitialized;
    _viewId = widget.controller.viewId;
    // Need to listen for initialization events since the actual initialization value
    // becomes available after asynchronous initialization finishes.
    widget.controller.addOnInitListener(_onVideoInitListener);
  }

  _onVideoInitListener() {
    if (!mounted) {
      return;
    }

    final isInitialized = widget.controller.value.isInitialized;
    if (isInitialized != _isInitialized) {
      setState(() {
        _isInitialized = isInitialized;
        _viewId = widget.controller.viewId;
      });
    }
  }

  @override
  void didUpdateWidget(VlcPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onVideoInitListener);
      _isInitialized = widget.controller.value.isInitialized;
      _viewId = widget.controller.viewId;
      widget.controller.addListener(_onVideoInitListener);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_onVideoInitListener);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          Offstage(
            offstage: _isInitialized,
            child: widget.placeholder ?? Container(),
          ),
          Offstage(
            offstage: !_isInitialized,
            child:
                _viewId != null
                    ? VlcPlayerPlatform.instance.buildView(_viewId!)
                    : Container(),
          ),
        ],
      ),
    );
  }
}
