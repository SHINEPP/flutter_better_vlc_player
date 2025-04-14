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
        body: GestureRecognizer(
          onTap: () => _value.value = "点击",
          onLongPressStart: () => _value.value = "长按开始",
          onLongPressEnd: () => _value.value = "长按结束",
          onSlideLeftUpdate: (v) => _value.value = "左滑:$v",
          onSlideLeftEnd: (v) => _value.value = "左滑到:$v",
          onSlideRightUpdate: (v) => _value.value = "右滑:$v",
          onSlideRightEnd: (v) => _value.value = "右滑到:$v",
          onSlideLeftUpUpdate: (v) => _value.value = "左侧上滑:$v",
          onSlideLeftUpEnd: (v) => _value.value = "左侧上滑到:$v",
          onSlideLeftDownUpdate: (v) => _value.value = "左侧下滑:$v",
          onSlideLeftDownEnd: (v) => _value.value = "左侧下滑到:$v",
          onSlideRightUpUpdate: (v) => _value.value = "右侧上滑:$v",
          onSlideRightUpEnd: (v) => _value.value = "右侧上滑到:$v",
          onSlideRightDownUpdate: (v) => _value.value = "右侧下滑:$v",
          onSlideRightDownEnd: (v) => _value.value = "右侧下滑到:$v",
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

class GestureRecognizer extends StatefulWidget {
  const GestureRecognizer({
    super.key,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onSlideLeftStart,
    this.onSlideLeftUpdate,
    this.onSlideLeftEnd,
    this.onSlideRightStart,
    this.onSlideRightUpdate,
    this.onSlideRightEnd,
    this.onSlideLeftUpStart,
    this.onSlideLeftUpUpdate,
    this.onSlideLeftUpEnd,
    this.onSlideLeftDownStart,
    this.onSlideLeftDownUpdate,
    this.onSlideLeftDownEnd,
    this.onSlideRightUpStart,
    this.onSlideRightUpUpdate,
    this.onSlideRightUpEnd,
    this.onSlideRightDownStart,
    this.onSlideRightDownUpdate,
    this.onSlideRightDownEnd,
    required this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final VoidCallback? onSlideLeftStart;
  final ValueChanged<double>? onSlideLeftUpdate;
  final ValueChanged<double>? onSlideLeftEnd;
  final VoidCallback? onSlideRightStart;
  final ValueChanged<double>? onSlideRightUpdate;
  final ValueChanged<double>? onSlideRightEnd;
  final VoidCallback? onSlideLeftUpStart;
  final ValueChanged<double>? onSlideLeftUpUpdate;
  final ValueChanged<double>? onSlideLeftUpEnd;
  final VoidCallback? onSlideLeftDownStart;
  final ValueChanged<double>? onSlideLeftDownUpdate;
  final ValueChanged<double>? onSlideLeftDownEnd;
  final VoidCallback? onSlideRightUpStart;
  final ValueChanged<double>? onSlideRightUpUpdate;
  final ValueChanged<double>? onSlideRightUpEnd;
  final VoidCallback? onSlideRightDownStart;
  final ValueChanged<double>? onSlideRightDownUpdate;
  final ValueChanged<double>? onSlideRightDownEnd;

  final Widget child;

  @override
  GestureRecognizerState createState() => GestureRecognizerState();
}

class GestureRecognizerState extends State<GestureRecognizer> {
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
          if (widget.onSlideLeftStart != null) {
            widget.onSlideLeftStart!();
          }
        } else {
          _sideType = SideType.right;
          if (widget.onSlideRightStart != null) {
            widget.onSlideRightStart!();
          }
        }
      } else {
        // 垂直方向滑动
        if (dy < 0) {
          if (details.localPosition.dx < size.width / 2) {
            _sideType = SideType.leftUp;
            if (widget.onSlideLeftUpStart != null) {
              widget.onSlideLeftUpStart!();
            }
          } else {
            _sideType = SideType.rightUp;
            if (widget.onSlideRightUpStart != null) {
              widget.onSlideRightUpStart!();
            }
          }
        } else {
          if (details.localPosition.dx < size.width / 2) {
            _sideType = SideType.leftDown;
            if (widget.onSlideLeftDownStart != null) {
              widget.onSlideLeftDownStart!();
            }
          } else {
            _sideType = SideType.rightDown;
            if (widget.onSlideRightDownStart != null) {
              widget.onSlideRightDownStart!();
            }
          }
        }
      }
    }

    switch (_sideType) {
      case SideType.none:
        break;
      case SideType.left:
        _sideXRatio += dx / size.width;
        if (widget.onSlideLeftUpdate != null) {
          widget.onSlideLeftUpdate!(min(max(-_sideXRatio, 0), 1));
        }
        break;
      case SideType.right:
        _sideXRatio += dx / size.width;
        if (widget.onSlideRightUpdate != null) {
          widget.onSlideRightUpdate!(min(max(_sideXRatio, 0), 1));
        }
        break;
      case SideType.leftUp:
        _sideYRatio += dy / size.height;
        if (widget.onSlideLeftUpUpdate != null) {
          widget.onSlideLeftUpUpdate!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.leftDown:
        _sideYRatio += dy / size.height;
        if (widget.onSlideLeftDownUpdate != null) {
          widget.onSlideLeftDownUpdate!(min(max(_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightUp:
        _sideYRatio += dy / size.height;
        if (widget.onSlideRightUpUpdate != null) {
          widget.onSlideRightUpUpdate!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightDown:
        _sideYRatio += dy / size.height;
        if (widget.onSlideRightDownUpdate != null) {
          widget.onSlideRightDownUpdate!(min(max(_sideYRatio, 0), 1));
        }
        break;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    switch (_sideType) {
      case SideType.none:
        break;
      case SideType.left:
        if (widget.onSlideLeftEnd != null) {
          widget.onSlideLeftEnd!(min(max(-_sideXRatio, 0), 1));
        }
        break;
      case SideType.right:
        if (widget.onSlideRightEnd != null) {
          widget.onSlideRightEnd!(min(max(_sideXRatio, 0), 1));
        }
        break;
      case SideType.leftUp:
        if (widget.onSlideLeftUpEnd != null) {
          widget.onSlideLeftUpEnd!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.leftDown:
        if (widget.onSlideLeftDownEnd != null) {
          widget.onSlideLeftDownEnd!(min(max(_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightUp:
        if (widget.onSlideRightUpEnd != null) {
          widget.onSlideRightUpEnd!(min(max(-_sideYRatio, 0), 1));
        }
        break;
      case SideType.rightDown:
        if (widget.onSlideRightDownEnd != null) {
          widget.onSlideRightDownEnd!(min(max(_sideYRatio, 0), 1));
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
      behavior: HitTestBehavior.opaque,
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
