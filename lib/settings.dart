import 'dart:collection';

import 'package:get/get.dart';

class Settings {
  final Rx<HashMap<String, bool>> _settings = HashMap<String, bool>().obs;
  static const String leftHandMode = "Left-Handed Mode";
  static const String hints = "Hints";

  Settings(Map<String, bool> initialSettings) {
    _settings.value[Settings.leftHandMode] = false;
    _settings.value[Settings.hints] = false;
    _settings.value.addAll(initialSettings);
  }

  bool? get(String key) {
    return _settings.value[key];
  }

  void set(String key, bool value) {
    _settings.value[key] = value;
  }

  Map<String, bool> get value => _settings.value;
}