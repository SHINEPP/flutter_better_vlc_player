import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(GestureDemo());

class GestureDemo extends StatefulWidget {
  const GestureDemo({super.key});

  @override
  State<GestureDemo> createState() => _GestureDemoState();
}

class _GestureDemoState extends State<GestureDemo> {
  final _value = ValueNotifier<String>("请滑动");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: VideoPlayerGesture(
          onTap: () => _value.value = "点击",
          onLongPressStart: () => _value.value = "长按开始",
          onLongPressEnd: () => _value.value = "长按结束",
          onSideLeft: (v) => _value.value = "左滑:$v",
          onSideRight: (v) => _value.value = "右滑:$v",
          onSideLeftUp: (v) => _value.value = "左侧上滑:$v",
          onSideLeftDown: (v) => _value.value = "左侧下滑:$v",
          onSideRightUp: (v) => _value.value = "右侧上滑:$v",
          onSideRightDown: (v) => _value.value = "右侧下滑:$v",
          child: Container(
            color: Colors.grey,
            alignment: Alignment.center,
            child: ValueListenableBuilder(
              valueListenable: _value,
              builder: (context, value, child) {
                return Text(value, style: TextStyle(fontSize: 28));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class VideoPlayerGesture extends StatefulWidget {
  const VideoPlayerGesture({
    super.key,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onSideLeft,
    this.onSideRight,
    this.onSideLeftUp,
    this.onSideLeftDown,
    this.onSideRightUp,
    this.onSideRightDown,
    required this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final ValueChanged<double>? onSideLeft;
  final ValueChanged<double>? onSideRight;
  final ValueChanged<double>? onSideLeftUp;
  final ValueChanged<double>? onSideLeftDown;
  final ValueChanged<double>? onSideRightUp;
  final ValueChanged<double>? onSideRightDown;

  final Widget child;

  @override
  VideoPlayerGestureState createState() => VideoPlayerGestureState();
}

class VideoPlayerGestureState extends State<VideoPlayerGesture> {
  static const _sideThreshold = 20;

  Offset _startPosition = Offset.zero;

  void _onTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (widget.onLongPressStart != null) {
      widget.onLongPressStart!();
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (widget.onLongPressEnd != null) {
      widget.onLongPressEnd!();
    }
  }

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final currentPosition = details.globalPosition;
    final dx = currentPosition.dx - _startPosition.dx;
    final dy = currentPosition.dy - _startPosition.dy;

    final absDx = dx.abs();
    final absDy = dy.abs();
    final size = MediaQuery.of(context).size;

    if (absDx > absDy) {
      // 水平方向滑动
      final ratio = min(absDx / size.width, 1.0);
      if (dx > _sideThreshold) {
        if (widget.onSideRight != null) {
          widget.onSideRight!(ratio);
        }
      } else if (dx < -_sideThreshold) {
        if (widget.onSideLeft != null) {
          widget.onSideLeft!(ratio);
        }
      }
    } else {
      // 垂直方向滑动
      final ratio = min(absDy / size.height, 1.0);
      if (dy < -_sideThreshold) {
        if (_startPosition.dx < size.width / 2) {
          if (widget.onSideLeftUp != null) {
            widget.onSideLeftUp!(ratio);
          }
        } else {
          if (widget.onSideRightUp != null) {
            widget.onSideRightUp!(ratio);
          }
        }
      } else if (dy > _sideThreshold) {
        if (_startPosition.dx < size.width / 2) {
          if (widget.onSideLeftDown != null) {
            widget.onSideLeftDown!(ratio);
          }
        } else {
          if (widget.onSideRightDown != null) {
            widget.onSideRightDown!(ratio);
          }
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}
