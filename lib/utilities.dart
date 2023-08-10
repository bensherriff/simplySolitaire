import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solitaire/playing_card.dart';

import 'screens/home.dart';

class Utilities {

  static const String applicationName = "Simple Solitaire";
  static Color textColor = Colors.white;
  static Color buttonBackgroundColor = Colors.white;
  static Color buttonTextColor = const Color(0xFF1A1F16);

  // Standard 2.74x3.74
  static const double cardHeight = 70.0;
  static const double cardWidth = 51.28;

  static var storage = GetStorage('storage');

  static Future<T> writeData<T>(String key, T value) async {
    await storage.write(key, value);
    return value;
  }
  
  static bool hasData(String key) {
    return storage.hasData(key);
  }

  static T readData<T>(String key) {
    return storage.read(key);
  }

  static SizedBox emptyCard() {
    return const SizedBox(
      height: cardHeight,
      width: cardWidth,
    );
  }

  static int countHiddenCards(List<PlayingCard> cards) {
    int hiddenCount = 0;
    for (PlayingCard card in cards) {
      if (!card.revealed) {
        hiddenCount++;
      }
    }
    return hiddenCount;
  }

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
        Home screen = Get.find();
        Get.to(() => screen);
      }, icon: Icon(
        Icons.menu,
        color: textColor,
        size: 36.0,
      ),
    );
  }
}