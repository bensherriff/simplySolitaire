import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solitaire/game_timer.dart';
import 'package:solitaire/screens/options_screen.dart';
import 'package:solitaire/storage.dart';
import 'package:solitaire/move.dart';
import 'package:solitaire/screens/menu_screen.dart';

enum GameMode {
  klondike,
  spider
}

extension GameModeString on GameMode {
  String toShortString() {
    return toString().split('.').last.capitalizeFirst!;
  }
}

class GameScreen extends StatefulWidget {

  static const int maxSeed = 4294967296;

  final Storage storage;
  final Color backgroundColor;
  final GameMode gameMode;

  bool initialized = false;
  int seed = -1;
  Moves moves = Moves(gameMode: GameMode.klondike);
  GameTimer timer = Get.put(GameTimer());

  GameScreen({Key? key, required this.storage, required this.backgroundColor, required this.gameMode}) : super(key: key);

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState<T extends GameScreen> extends State<T> {

  final OptionsScreen optionsScreen = Get.find();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget bottomNavBar(int colorValue, Function(Move move) undoMove) {
    return BottomAppBar(
      color: Color(colorValue),
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
                  padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                  onPressed: () {
                    widget.timer.stopTimer(reset: false);
                    MenuScreen menuScreen = Get.find();
                    Get.to(() => menuScreen);
                  }
              ),
              Obx(() => widget.timer.buildTime()),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.moves.totalPoints().toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      const Text("Points", style: TextStyle(color: Colors.white) )
                    ]
                ),
              ),
              (widget.moves.isNotEmpty)? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 30.0,
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                  onPressed: () {
                    Move? lastMove = widget.moves.pop();
                    if (lastMove != null) {
                      undoMove(lastMove);
                    }
                  }
              ) : IconButton(
                icon: const Icon(null),
                iconSize: 30.0,
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                onPressed: () {},
              )
            ],
          )
      ),
    );
  }
}