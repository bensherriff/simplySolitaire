import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Settings {
  final Rx<HashMap<String, bool>> _settings = HashMap<String, bool>().obs;
  Color backgroundColor;
  Color barColor;
  Color textColor;

  static const String leftHandMode = "Left-Handed Mode";
  static const String hints = "Hints";

  Settings(Map<String, bool> initialSettings, {
    required this.backgroundColor,
    required this.barColor,
    this.textColor = Colors.white
  }) {
    _settings.value[Settings.leftHandMode] = false;
    _settings.value[Settings.hints] = false;
    _settings.value.addAll(initialSettings);
  }

  bool? get(String key) {
    return _settings.value[key];
  }

  bool has(String key) {
    return _settings.value[key] != null;
  }

  void set(String key, bool value) {
    _settings.value[key] = value;
  }

  Map<String, bool> get value => _settings.value;

  Map<String, dynamic> toJson() => {
    'settings': _settings.value,
    'backgroundColor': backgroundColor.value,
    'barColor': barColor.value,
    'textColor': textColor.value
  };

  void fromJson(Map<String, dynamic> json) {
    _settings.value = HashMap<String, bool>.from(json['settings']);
    backgroundColor = Color(json['backgroundColor']);
    barColor = Color(json['barColor']);
    textColor = Color(json['textColor']);
  }
}