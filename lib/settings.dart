import 'dart:collection';

import 'package:get/get.dart';

class Settings {
  final Rx<HashMap<String, bool>> _settings = HashMap<String, bool>().obs;

  bool? get(String key) {
    return _settings.value[key];
  }

  void set(String key, bool value) {
    _settings.value[key] = value;
  }
}