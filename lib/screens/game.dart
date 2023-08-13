import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solitaire/game_timer.dart';
import 'package:solitaire/move.dart';
import 'package:solitaire/screens/home.dart';
import 'package:solitaire/settings.dart';
import 'package:solitaire/utilities.dart';

enum GameMode {
  klondike,
  spider
}

extension GameModeExt on GameMode {
  String toShortString() {
    return toString().split('.').last.capitalizeFirst!;
  }
}

abstract class GameScreen extends StatefulWidget {
  static const int maxSeed = 4294967296;
  final GameMode gameMode;
  final GameStyle style;
  final Settings settings;

  bool initialized = false;
  int seed = -1;
  Moves moves = Moves(gameMode: GameMode.klondike);
  GameTimer timer = Get.put(GameTimer());
  bool autoMove = false;

  GameScreen({
    Key? key,
    required this.gameMode,
    required this.style,
    required this.settings
  }) : super(key: key);

  void newGame({seed = -1}) {
    timer.stopTimer(reset: true);
    initialized = false;
    this.seed = seed;
    autoMove = false;
    Get.to(() => this);
  }

  void customGame();

  void restartGame() {
    timer.stopTimer(reset: true);
    initialized = false;
    autoMove = false;
    Get.to(() => this);
  }
}

abstract class GameScreenState<T extends GameScreen> extends State<T> {
  final logger = Logger("GameScreenState");
  @override
  void initState() {
    super.initState();
    if (widget.initialized || Utilities.hasData(widget.gameMode.toShortString())) {
      loadState();
    } else {
      if (widget.seed == -1) {
        initializeRandomGame();
      } else {
        initializeGame(widget.seed);
      }
    }
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
              onPressed: () {
                showDialog(context: context, builder: (BuildContext context) {
                  return gameSettings();
                });
              },
              icon: const Icon(Icons.settings)
          ),
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
                Text("Points", style: GoogleFonts.quicksand(color: Colors.white))
              ]
            ),
          ),
          (widget.moves.isNotEmpty)? IconButton(
              icon: const Icon(Icons.undo),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () async {
                widget.autoMove = false;
                Move? lastMove = widget.moves.pop();
                if (lastMove != null) {
                  await undoMove(lastMove);
                }
                setState(() {});
              }
          ) : IconButton(
            icon: const Icon(null),
            iconSize: 30.0,
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget bottomNavBar() {
    return BottomAppBar(
      color: widget.style.barColor,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
          height: 75.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: IconButton(
                    icon: const Icon(Icons.home),
                    iconSize: 30.0,
                    color: Colors.white,
                    onPressed: () {
                      widget.timer.stopTimer(reset: false);
                      widget.autoMove = false;
                      saveState();
                      Home menuScreen = Get.find();
                      Get.to(() => menuScreen);
                    }
                ),
              ),
              const VerticalDivider(),
              Expanded(child: IconButton(
                  icon: const Icon(Icons.add),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Start New Game?", style: GoogleFonts.quicksand()),
                        actions: [
                          TextButton(child: Text("Yes", style: GoogleFonts.quicksand()), onPressed: () {
                            Navigator.pop(context);
                            widget.newGame();
                            initializeRandomGame();
                          }),
                          TextButton(child: Text("No", style: GoogleFonts.quicksand()), onPressed: () {
                            Navigator.pop(context);
                          }),
                        ],
                      );
                    });
                  }
              )),
              const VerticalDivider(),
              Expanded(child: IconButton(
                  icon: const Icon(Icons.restart_alt),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Restart Game?", style: GoogleFonts.quicksand()),
                        actions: [
                          TextButton(child: Text("Yes", style: GoogleFonts.quicksand()), onPressed: () {
                            Navigator.pop(context);
                            widget.restartGame();
                            initializeGame(widget.seed);
                          }),
                          TextButton(child: Text("No", style: GoogleFonts.quicksand()), onPressed: () {
                            Navigator.pop(context);
                          }),
                        ],
                      );
                    });
                  }
              )),
              Utilities.readData(Settings.hints)? const VerticalDivider(): const SizedBox(),
              Utilities.readData(Settings.hints)? Expanded(child: IconButton(
                icon: const Icon(Icons.help),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: () {

                }
              )): const SizedBox()
            ],
          )
      ),
    );
  }

  Widget gameSettings() {
    return AlertDialog(
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Settings",
                  style: GoogleFonts.quicksand(
                      fontSize: 28
                  )
              ),
              Column(
                children: widget.settings.value.entries.map((setting) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(setting.key, style: GoogleFonts.quicksand()),
                        Switch(
                          value: setting.value,
                          onChanged: (value) => {
                            Utilities.writeData(setting.key, value).then((value) => {
                              setState(() {
                                widget.settings.set(setting.key, value);
                              }),
                            })
                          },
                        ),
                      ]
                  );
                }).toList(),
              ),
              const Divider(),
              widget.seed != -1? TextButton(
                onPressed: () async => await Clipboard.setData(ClipboardData(text: Utilities.seedToString(widget.seed))),
                child: Text(
                    "Seed: ${Utilities.seedToString(widget.seed)}",
                    style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54
                    )
                ),
              ) : const SizedBox(),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      return Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                            'v${snapshot.data!.version} build ${snapshot.data!.buildNumber}',
                            style: GoogleFonts.quicksand(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600
                            )
                        ),
                      );
                    default:
                      return const SizedBox();
                  }
                },
              )
            ]
        )
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
                            Text("You won!",
                                style: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black)),
                            const SizedBox(height: 15),
                            Text("Points: ${widget.moves.totalPoints().toString()}",
                                style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black),
                                textAlign: TextAlign.center
                            ),
                            const SizedBox(height: 15),
                            Text('Time: ${widget.timer.time()}',
                                style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black),
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
                                  child: Text("Replay", style: GoogleFonts.quicksand(fontSize: 18)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    initializeRandomGame();
                                  },
                                  child: Text("New\nGame", style: GoogleFonts.quicksand(fontSize: 18)),
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
                                  child: Text("Main\nMenu", style: GoogleFonts.quicksand(fontSize: 18)),
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
    setState(() {
      widget.seed = (random.nextInt(GameScreen.maxSeed));
    });
    initializeGame(widget.seed);
  }

  void saveState() {
    Map<String, dynamic> dataMap = toJson();
    String dataString = jsonEncode(dataMap);
    Utilities.writeData(widget.gameMode.toShortString(), dataString).then((value) => {
      logger.fine("${widget.gameMode.toShortString()} state saved")
    });
  }

  void loadState() {
    String dataString = Utilities.readData(widget.gameMode.toShortString());
    logger.fine("${widget.gameMode.toShortString()} state loaded");
    Map<String, dynamic> dataMap = jsonDecode(dataString);
    fromJson(dataMap);
  }

  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
  void initializeGame(int seed, {bool debug = false});
  Future<void> undoMove(Move move);
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