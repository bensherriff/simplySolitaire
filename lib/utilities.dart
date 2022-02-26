import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/menu_screen.dart';

class Utilities {

  static const String applicationName = "Simple Solitaire";
  static Color textColor = Colors.white;
  static Color buttonBackgroundColor = Colors.white;
  static Color buttonTextColor = const Color(0xFF1A1F16);

  // Standard 2.74x3.74
  static const double cardHeight = 70.0;
  static const double cardWidth = 51.28;

  static baseAppBar(Color backgroundColor, List<Widget> widgets) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          menuIcon(),
          const Text(applicationName,
            style: TextStyle(
              fontSize: 30
            ),
          )
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
        Get.to(() => const MenuScreen());
      }, icon: Icon(
        Icons.menu,
        color: textColor,
        size: 36.0,
      ),
    );
  }
}