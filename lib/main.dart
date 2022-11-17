import 'package:flutter/material.dart';
import 'package:solitaire/screens/menu_screen.dart';
import 'package:get/get.dart';

final MenuScreen menuScreen = Get.put(const MenuScreen());

void main() => runApp(GetMaterialApp(home: menuScreen));

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