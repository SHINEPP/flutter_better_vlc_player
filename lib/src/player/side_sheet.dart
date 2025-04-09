import 'package:flutter/material.dart';

/// 右侧边弹窗
Future<T?> showRightSideSheet<T extends Object?>(
  BuildContext context,
  Widget child,
) => Navigator.push(
  context,
  PageRouteBuilder<T>(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder:
        (context, animation, secondaryAnimation) => Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.3, // 右侧弹窗宽度比例
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 10) {
                  Navigator.of(context).pop();
                }
              },
              child: Material(color: Colors.white, child: child),
            ),
          ),
        ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  ),
);

Future<T?> showRightSideSheetWithNavigator<T extends Object?>(
  BuildContext context,
  Widget child,
) => showRightSideSheet(
  context,
  ClipRRect(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    child: Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    ),
  ),
);

/// 底部弹窗
Future<T?> showBottomSideSheet<T extends Object?>(
  BuildContext context,
  Widget child,
) => showModalBottomSheet<T>(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) => child,
);

Future<T?> showBottomSideSheetWithNavigator<T extends Object?>(
  BuildContext context,
  Widget child,
) => showBottomSideSheet<T>(
  context,
  ClipRRect(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    child: Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    ),
  ),
);
