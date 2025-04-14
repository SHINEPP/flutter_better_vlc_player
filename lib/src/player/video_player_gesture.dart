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
          onSideLeftUpdate: (v) => _value.value = "左滑:$v",
          onSideLeftEnd: (v) => _value.value = "左滑到:$v",
          onSideRightUpdate: (v) => _value.value = "右滑:$v",
          onSideRightEnd: (v) => _value.value = "右滑到:$v",
          onSideLeftUpUpdate: (v) => _value.value = "左侧上滑:$v",
          onSideLeftUpEnd: (v) => _value.value = "左侧上滑到:$v",
          onSideLeftDownUpdate: (v) => _value.value = "左侧下滑:$v",
          onSideLeftDownEnd: (v) => _value.value = "左侧下滑到:$v",
          onSideRightUpUpdate: (v) => _value.value = "右侧上滑:$v",
          onSideRightUpEnd: (v) => _value.value = "右侧上滑到:$v",
          onSideRightDownUpdate: (v) => _value.value = "右侧下滑:$v",
          onSideRightDownEnd: (v) => _value.value = "右侧下滑到:$v",
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

enum SideType { none, left, right, leftUp, leftDown, rightUp, rightDown }

class VideoPlayerGesture extends StatefulWidget {
  const VideoPlayerGesture({
    super.key,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onSideLeftUpdate,
    this.onSideLeftEnd,
    this.onSideRightUpdate,
    this.onSideRightEnd,
    this.onSideLeftUpUpdate,
    this.onSideLeftUpEnd,
    this.onSideLeftDownUpdate,
    this.onSideLeftDownEnd,
    this.onSideRightUpUpdate,
    this.onSideRightUpEnd,
    this.onSideRightDownUpdate,
    this.onSideRightDownEnd,
    required this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final ValueChanged<double>? onSideLeftUpdate;
  final ValueChanged<double>? onSideLeftEnd;
  final ValueChanged<double>? onSideRightUpdate;
  final ValueChanged<double>? onSideRightEnd;
  final ValueChanged<double>? onSideLeftUpUpdate;
  final ValueChanged<double>? onSideLeftUpEnd;
  final ValueChanged<double>? onSideLeftDownUpdate;
  final ValueChanged<double>? onSideLeftDownEnd;
  final ValueChanged<double>? onSideRightUpUpdate;
  final ValueChanged<double>? onSideRightUpEnd;
  final ValueChanged<double>? onSideRightDownUpdate;
  final ValueChanged<double>? onSideRightDownEnd;

  final Widget child;

  @override
  VideoPlayerGestureState createState() => VideoPlayerGestureState();
}

class VideoPlayerGestureState extends State<VideoPlayerGesture> {
  var _sideType = SideType.none;
  double _sideXRatio = 0;
  double _sideYRatio = 0;

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
    _sideXRatio = 0;
    _sideYRatio = 0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    final absDx = dx.abs();
    final absDy = dy.abs();
    final size = MediaQuery.of(context).size;

    // 确定方向
    if (_sideType == SideType.none) {
      // 水平方向滑动
      if (absDx > absDy) {
        if (dx < 0) {
          _sideType = SideType.left;
        } else {
          _sideType = SideType.right;
        }
      } else {
        // 垂直方向滑动
        if (dy < 0) {
          if (details.localPosition.dx < size.width / 2) {
            _sideType = SideType.leftUp;
          } else {
            _sideType = SideType.rightUp;
          }
        } else {
          if (details.localPosition.dx < size.width / 2) {
            _sideType = SideType.leftDown;
          } else {
            _sideType = SideType.rightDown;
          }
        }
      }
    }

    switch (_sideType) {
      case SideType.none:
        break;
      case SideType.left:
        _sideXRatio += dx / size.width;
        if (widget.onSideLeftUpdate != null) {
          widget.onSideLeftUpdate!(min(max(-_sideXRatio, 0), 1));
        }
        break;
      case SideType.right:
        _sideXRatio += dx / size.width;
        if (widget.onSideRightUpdate != null) {
          widget.onSideRightUpdate!(min(max(_sideXRatio, 0), 1));
        }
        break;
      case SideType.leftUp:
        _sideYRatio += dy / size.height;
        if (widget.onSideLeftUpUpdate != null) {
          widget.onSideLeftUpUpdate!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.leftDown:
        _sideYRatio += dy / size.height;
        if (widget.onSideLeftDownUpdate != null) {
          widget.onSideLeftDownUpdate!(min(max(_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightUp:
        _sideYRatio += dy / size.height;
        if (widget.onSideRightUpUpdate != null) {
          widget.onSideRightUpUpdate!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightDown:
        _sideYRatio += dy / size.height;
        if (widget.onSideRightDownUpdate != null) {
          widget.onSideRightDownUpdate!(min(max(_sideYRatio, 0), 1));
        }
        break;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    switch (_sideType) {
      case SideType.none:
        break;
      case SideType.left:
        if (widget.onSideLeftEnd != null) {
          widget.onSideLeftEnd!(min(max(-_sideXRatio, 0), 1));
        }
        break;
      case SideType.right:
        if (widget.onSideRightEnd != null) {
          widget.onSideRightEnd!(min(max(_sideXRatio, 0), 1));
        }
        break;
      case SideType.leftUp:
        if (widget.onSideLeftUpEnd != null) {
          widget.onSideLeftUpEnd!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.leftDown:
        if (widget.onSideLeftDownEnd != null) {
          widget.onSideLeftDownEnd!(min(max(_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightUp:
        if (widget.onSideRightUpEnd != null) {
          widget.onSideRightUpEnd!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightDown:
        if (widget.onSideRightDownEnd != null) {
          widget.onSideRightDownEnd!(min(max(_sideYRatio, 0), 1));
        }
        break;
    }
    _sideXRatio = 0;
    _sideYRatio = 0;
    _sideType = SideType.none;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
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
