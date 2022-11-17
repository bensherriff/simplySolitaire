import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solitaire/screens/menu_screen.dart';
import 'package:get/get.dart';

final MenuScreen menuScreen = Get.put(MenuScreen());

void main() async {
  await GetStorage.init('storage');
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