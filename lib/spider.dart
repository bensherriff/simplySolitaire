import 'package:flutter/material.dart';

import 'game_screen.dart';

class SpiderScreen extends GameScreen {

  SpiderScreen({Key? key}) : super(key: key, gameName: "Spider", backgroundColor: const Color(0xFF62BFED));

  @override
  SpiderScreenState createState() => SpiderScreenState();
}

class SpiderScreenState extends GameScreenState<SpiderScreen> {

}