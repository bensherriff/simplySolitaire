import 'package:flutter/material.dart';

import 'game_screen.dart';

class SpiderScreen extends GameScreen {

  SpiderScreen({Key? key}) : super(key: key, gameMode: GameMode.spider, backgroundColor: const Color(0xFF0a9396));

  @override
  SpiderScreenState createState() => SpiderScreenState();
}

class SpiderScreenState extends GameScreenState<SpiderScreen> {
  @override
  void initState() {
    if (!widget.initialized) {
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: const Column(
        children: <Widget>[
          SizedBox(
            height: 80.0,
          ),
          SizedBox(
            height: 16.0,
          )
        ]
      ),
      bottomNavigationBar: bottomNavBar(0xFF0b3f40, (move) => {}),
    );
  }

  @override
  void initializeGame(int seed, {bool debug = false}) {

  }

  @override
  Map toJson() => {};

  @override
  void fromJson(Map<String, dynamic> json) {
  }
}