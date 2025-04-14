import 'dart:math';

import 'package:flutter/material.dart';

enum SideType { none, horizon, leftVertical, rightVertical }

class GestureRecognizer extends StatefulWidget {
  const GestureRecognizer({
    super.key,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onSlideHorizonStart,
    this.onSlideHorizonUpdate,
    this.onSlideHorizonEnd,
    this.onSlideLeftVerticalStart,
    this.onSlideLeftVerticalUpdate,
    this.onSlideLeftVerticalEnd,
    this.onSlideRightVerticalStart,
    this.onSlideRightVerticalUpdate,
    this.onSlideRightVerticalEnd,
    required this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  final VoidCallback? onSlideHorizonStart;
  final ValueChanged<double>? onSlideHorizonUpdate;
  final ValueChanged<double>? onSlideHorizonEnd;

  final VoidCallback? onSlideLeftVerticalStart;
  final ValueChanged<double>? onSlideLeftVerticalUpdate;
  final ValueChanged<double>? onSlideLeftVerticalEnd;

  final VoidCallback? onSlideRightVerticalStart;
  final ValueChanged<double>? onSlideRightVerticalUpdate;
  final ValueChanged<double>? onSlideRightVerticalEnd;

  final Widget child;

  @override
  GestureRecognizerState createState() => GestureRecognizerState();
}

class GestureRecognizerState extends State<GestureRecognizer> {
  var _sideType = SideType.none;
  double _width = 0;
  double _height = 0;
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
    final size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
    _sideType = SideType.none;
    _sideXRatio = 0;
    _sideYRatio = 0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    // 确定方向
    if (_sideType == SideType.none) {
      // 水平方向滑动
      if (dx.abs() > dy.abs()) {
        _sideType = SideType.horizon;
        if (widget.onSlideHorizonStart != null) {
          widget.onSlideHorizonStart!();
        }
      } else {
        // 垂直方向滑动
        if (details.localPosition.dx < _width / 2) {
          _sideType = SideType.leftVertical;
          if (widget.onSlideLeftVerticalStart != null) {
            widget.onSlideLeftVerticalStart!();
          }
        } else {
          _sideType = SideType.rightVertical;
          if (widget.onSlideRightVerticalStart != null) {
            widget.onSlideRightVerticalStart!();
          }
        }
      }
    }

    switch (_sideType) {
      case SideType.none:
        break;
      case SideType.horizon:
        _sideXRatio += dx / _width;
        if (widget.onSlideHorizonUpdate != null) {
          widget.onSlideHorizonUpdate!(min(max(_sideXRatio, -1), 1));
        }
        break;
      case SideType.leftVertical:
        _sideYRatio += -dy / _height;
        if (widget.onSlideLeftVerticalUpdate != null) {
          widget.onSlideLeftVerticalUpdate!(min(max(_sideYRatio, -1), 1));
        }
        break;
      case SideType.rightVertical:
        _sideYRatio += -dy / _height;
        if (widget.onSlideRightVerticalUpdate != null) {
          widget.onSlideRightVerticalUpdate!(min(max(_sideYRatio, -1), 1));
        }
        break;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    switch (_sideType) {
      case SideType.none:
        break;
      case SideType.horizon:
        if (widget.onSlideHorizonEnd != null) {
          widget.onSlideHorizonEnd!(min(max(_sideXRatio, -1), 1));
        }
        break;
      case SideType.leftVertical:
        if (widget.onSlideLeftVerticalEnd != null) {
          widget.onSlideLeftVerticalEnd!(min(max(_sideYRatio, -1), 1));
        }
        break;
      case SideType.rightVertical:
        if (widget.onSlideRightVerticalEnd != null) {
          widget.onSlideRightVerticalEnd!(min(max(_sideYRatio, -1), 1));
        }
        break;
    }
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
