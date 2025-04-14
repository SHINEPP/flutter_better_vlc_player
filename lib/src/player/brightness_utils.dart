import 'package:flutter/cupertino.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightNessUtils {
  BrightNessUtils._internal();

  static Future<double> get systemBrightness async {
    try {
      return await ScreenBrightness.instance.system;
    } catch (e) {
      debugPrint("e = $e");
    }
    return 0;
  }

  static Future<void> setSystemBrightness(double brightness) async {
    try {
      await ScreenBrightness.instance.setSystemScreenBrightness(brightness);
    } catch (e) {
      debugPrint("e = $e");
    }
  }
}
