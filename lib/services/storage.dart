import 'dart:convert';

import 'package:mmkv_flutter/mmkv_flutter.dart';

class Storage {
  static Future<MmkvFlutter> getInstance() async {
    return await MmkvFlutter.getInstance();
  }

  static Future<Map> getMap(String key, {Map defaultValue}) async {
    String s = await (await getInstance()).getString(key);
    if (s == null || s.isEmpty) return defaultValue;
    return jsonDecode(s);
  }

  static setMap(String key, Map value) async {
    if (value == null) return (await getInstance()).removeByKey(key);
    return (await getInstance()).setString(key, jsonEncode(value));
  }
}
