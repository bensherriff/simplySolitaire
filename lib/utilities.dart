import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'menu_screen.dart';

class Utilities {

  static const String applicationName = "Simple Solitaire";
  static Color textColor = Colors.white;
  // static Color backgroundColor = Color(0xFF1E3F20);
  static Color backgroundColor = const Color(0xFF357960);
  // static Color buttonBackgroundColor = Color(0xFF1A1F16);
  static Color buttonBackgroundColor = Colors.white;
  static Color buttonTextColor = const Color(0xFF1A1F16);

  static baseAppBar(List<Widget> widgets) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          menuIcon(),
          const Text(applicationName)
        ],
      ),
      elevation: 0.0,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      actions: widgets,
    );
  }

  static menuIcon() {
    return IconButton(
      onPressed: () {
        Get.to(() => MenuScreen());
      }, icon: Icon(
        Icons.menu,
        color: textColor,
      ),
    );
  }
}