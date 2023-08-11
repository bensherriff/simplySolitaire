import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solitaire/game_timer.dart';
import 'package:solitaire/screens/settings_screen.dart';
import 'package:solitaire/move.dart';
import 'package:solitaire/screens/home.dart';
import 'package:solitaire/utilities.dart';

enum GameMode {
  klondike,
  spider
}

extension GameModeString on GameMode {
  String toShortString() {
    return toString().split('.').last.capitalizeFirst!;
  }
}

abstract class GameScreen extends StatefulWidget {
  static const int maxSeed = 4294967296;
  final GameMode gameMode;
  final GameStyle style;

  bool initialized = false;
  int seed = -1;
  Moves moves = Moves(gameMode: GameMode.klondike);
  GameTimer timer = Get.put(GameTimer());

  GameScreen({
    Key? key,
    required this.gameMode,
    required this.style
  }) : super(key: key);

  void newGame() {
    timer.stopTimer(reset: true);
    initialized = false;
    seed = -1;
    Get.to(() => this);
  }

  void restartGame() {
    timer.stopTimer(reset: true);
    initialized = false;
    Get.to(() => this);
  }
}

abstract class GameScreenState<T extends GameScreen> extends State<T> {
  final SettingsScreen optionsScreen = Get.find();

  @override
  void initState() {
    super.initState();
    Utilities.writeData('gameMode', widget.gameMode.toString());
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget topScoreBar() {
    return AppBar(
      backgroundColor: widget.style.barColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Obx(() => widget.timer.buildTime()),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.moves.totalPoints().toString(),
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
                const Text("Points", style: TextStyle(color: Colors.white))
              ]
            ),
          ),
          Text(widget.seed.toRadixString(16).toUpperCase(), style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white54
          )),
        ],
      ),
    );
  }

  Widget bottomNavBar(Function(Move move) undoMove) {
    return BottomAppBar(
      color: widget.style.barColor,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
          height: 75.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  icon: const Icon(Icons.home),
                  iconSize: 30.0,
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  onPressed: () {
                    widget.timer.stopTimer(reset: false);
                    Home menuScreen = Get.find();
                    Get.to(() => menuScreen);
                  }
              ),
              IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 30.0,
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  onPressed: () {
                    setState(() {
                      widget.newGame();
                      initializeRandomGame();
                    });
                  }
              ),
              IconButton(
                  icon: const Icon(Icons.restart_alt),
                  iconSize: 30.0,
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  onPressed: () {
                    setState(() {
                      widget.restartGame();
                      initializeGame(widget.seed);
                    });
                  }
              ),
              (widget.moves.isNotEmpty)? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 30.0,
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  onPressed: () {
                    setState(() {
                      Move? lastMove = widget.moves.pop();
                      if (lastMove != null) {
                        undoMove(lastMove);
                      }
                    });
                  }
              ) : IconButton(
                icon: const Icon(null),
                iconSize: 30.0,
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                onPressed: () {},
              )
            ],
          )
      ),
    );
  }

  void handleWin() {
    widget.timer.stopTimer(reset: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Stack(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(left: 20, top: 35, right: 20, bottom: 20),
                      margin: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(0,5)),
                          ]
                      ),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text("You won!",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 15),
                            Text("Points: ${widget.moves.totalPoints().toString()}",
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center
                            ),
                            const SizedBox(height: 15),
                            Text('Time: ${widget.timer.time()}',
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    initializeGame(widget.seed);
                                  },
                                  child: const Text("Replay", style: TextStyle(fontSize: 18)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    initializeRandomGame();
                                  },
                                  child: const Text("New\nGame", style: TextStyle(fontSize: 18)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Home screen = Get.find();
                                    setState(() {
                                      widget.timer.resetTimer();
                                      widget.initialized = false;
                                      widget.seed = -1;
                                    });
                                    Get.to(() => screen);
                                  },
                                  child: const Text("Main\nMenu", style: TextStyle(fontSize: 18)),
                                )
                              ],
                            )
                          ]
                      )
                  ),
                ]
            )
        );
      },
    );
  }

  void initializeRandomGame() {
    Random random = Random();
    widget.seed = (random.nextInt(GameScreen.maxSeed));
    initializeGame(widget.seed);
  }

  Map toJson();
  void fromJson(Map<String, dynamic> json);
  void initializeGame(int seed, {bool debug = false});
}

class GameStyle {
  final Color backgroundColor;
  final Color barColor;
  final Color textColor;

  GameStyle({
    required this.backgroundColor,
    required this.barColor,
    this.textColor = Colors.white
  });
}