import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:solitaire/screens/menu_screen.dart';
import 'package:get/get.dart';
import 'dart:developer';

final MenuScreen menuScreen = Get.put(const MenuScreen());

void main() async {
  // Logger.root.level = Level.ALL;
  Logger.root.level = Level.FINER;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name} | ${record.time} | ${record.message}');
  });
  await Get.putAsync(() => GetStorage.init('storage'));
  runApp(GetMaterialApp(home: menuScreen));
}


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static const String _title = 'Simple Solitaire';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: menuScreen,
    );
  }
}