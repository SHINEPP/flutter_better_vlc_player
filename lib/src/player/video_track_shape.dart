import 'package:flutter/material.dart';

class VideoTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final activePaint =
        Paint()
          ..color =
              sliderTheme.activeTrackColor! // active 颜色
          ..style = PaintingStyle.fill;

    final inactivePaint =
        Paint()
          ..color =
              sliderTheme.inactiveTrackColor! // inactive 颜色
          ..style = PaintingStyle.fill;

    final activeHeight = 5.0; // active 轨道高度
    final inactiveHeight = 5.0; // inactive 轨道高度

    final activeRect = RRect.fromLTRBR(
      offset.dx,
      offset.dy + (parentBox.size.height - activeHeight) / 2,
      thumbCenter.dx,
      offset.dy + (parentBox.size.height + activeHeight) / 2,
      Radius.circular(8),
    );

    final inactiveRect = RRect.fromLTRBR(
      thumbCenter.dx,
      offset.dy + (parentBox.size.height - inactiveHeight) / 2,
      offset.dx + parentBox.size.width,
      offset.dy + (parentBox.size.height + inactiveHeight) / 2,
      Radius.circular(8),
    );

    context.canvas.drawRRect(activeRect, activePaint);
    context.canvas.drawRRect(inactiveRect, inactivePaint);
  }
}
