import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solitaire/game_timer.dart';
import 'package:solitaire/screens/options_screen.dart';

import '../deck.dart';
import '../move.dart';
import 'options_screen.dart';

enum GameMode {
  klondike,
  spider
}

class GameScreen extends StatefulWidget {

  static const int maxSeed = 4294967296;

  final Color backgroundColor;
  final String gameName;

  bool initialized = false;
  int seed = -1;
  Moves moves = Moves();
  GameTimer timer = Get.put(GameTimer());

  GameScreen({Key? key, required this.backgroundColor, required this.gameName}) : super(key: key);

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState<T extends GameScreen> extends State<T> {

  final OptionsScreen optionsScreen = Get.find();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}