import 'dart:math';
import 'dart:ui';

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
          onSideLeftUpdate: (v) => _value.value = "左滑:$v",
          onSideRightUpdate: (v) => _value.value = "右滑:$v",
          onSideLeftUpUpdate: (v) => _value.value = "左侧上滑:$v",
          onSideLeftDownUpdate: (v) => _value.value = "左侧下滑:$v",
          onSideRightUpUpdate: (v) => _value.value = "右侧上滑:$v",
          onSideRightDownUpdate: (v) => _value.value = "右侧下滑:$v",
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

enum SideType {
  none,
  left,
  right,
  leftUp,
  leftDown,
  rightUp,
  rightDown,
}

class VideoPlayerGesture extends StatefulWidget {
  const VideoPlayerGesture({
    super.key,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onSideLeftUpdate,
    this.onSideRightUpdate,
    this.onSideLeftUpUpdate,
    this.onSideLeftDownUpdate,
    this.onSideRightUpUpdate,
    this.onSideRightDownUpdate,
    required this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final ValueChanged<double>? onSideLeftUpdate;
  final ValueChanged<double>? onSideRightUpdate;
  final ValueChanged<double>? onSideLeftUpUpdate;
  final ValueChanged<double>? onSideLeftDownUpdate;
  final ValueChanged<double>? onSideRightUpUpdate;
  final ValueChanged<double>? onSideRightDownUpdate;

  final Widget child;

  @override
  VideoPlayerGestureState createState() => VideoPlayerGestureState();
}

class VideoPlayerGestureState extends State<VideoPlayerGesture> {
  static const _sideThreshold = 20;

  var _startPosition = Offset.zero;
  var _sideType = SideType.none;

  // 滑动最新值
  double _sideHorizonRatio = 0;
  double _sideVerticalRatio = 0;

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
    _sideType = SideType.none;
    _startPosition = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final currentPosition = details.globalPosition;
    final dx = currentPosition.dx - _startPosition.dx;
    final dy = currentPosition.dy - _startPosition.dy;

    final absDx = dx.abs();
    final absDy = dy.abs();
    final size = MediaQuery.of(context).size;

    if (_sideType == SideType.none) {
      
    }


    if (absDx > absDy) {
      // 水平方向滑动
      final ratio = min(absDx / size.width, 1.0);
      _sideHorizonRatio = ratio;
      if (dx > _sideThreshold) {
        if (widget.onSideRightUpdate != null) {
          widget.onSideRightUpdate!(ratio);
        }
      } else if (dx < -_sideThreshold) {
        if (widget.onSideLeftUpdate != null) {
          widget.onSideLeftUpdate!(ratio);
        }
      }
    } else {
      // 垂直方向滑动
      final ratio = min(absDy / size.height, 1.0);
      _sideVerticalRatio = ratio;
      if (dy < -_sideThreshold) {
        if (_startPosition.dx < size.width / 2) {
          if (widget.onSideLeftUpUpdate != null) {
            widget.onSideLeftUpUpdate!(ratio);
          }
        } else {
          if (widget.onSideRightUpUpdate != null) {
            widget.onSideRightUpUpdate!(ratio);
          }
        }
      } else if (dy > _sideThreshold) {
        if (_startPosition.dx < size.width / 2) {
          if (widget.onSideLeftDownUpdate != null) {
            widget.onSideLeftDownUpdate!(ratio);
          }
        } else {
          if (widget.onSideRightDownUpdate != null) {
            widget.onSideRightDownUpdate!(ratio);
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
