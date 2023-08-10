import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:solitaire/screens/home.dart';
import 'package:get/get.dart';
import 'dart:developer';

final Home home = Get.put(const Home());

void main() async {
  Logger.root.level = Level.FINER;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name} | ${record.time} | ${record.message}');
  });
  await Get.putAsync(() => GetStorage.init('storage'));
  runApp(GetMaterialApp(
    home: home,
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: ThemeMode.dark,
    debugShowCheckedModeBanner: false,
  ));
}


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static const String _title = 'Simply Solitaire';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: home,
    );
  }
}