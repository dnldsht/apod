import 'package:flutter/services.dart';

class Wall {
  static const int HOME = 1;
  static const int LOCK = 2;
  static const int BOTH = 3;
  static const int SYSTEM = 4;
  static const platform = MethodChannel("org.hora.wall");

  static Future setWallPaper(String fileName, {int mode = BOTH}) async {
    var method = 'both';
    switch (mode) {
      case HOME:
        method = 'home';
        break;
      case LOCK:
        method = 'lock';
        break;
      case SYSTEM:
        method = 'system';
        break;
      default:
    }

    return await platform.invokeMethod(method, fileName);
  }
}
