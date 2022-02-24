
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:solitaire/utilities.dart';
import 'controller.dart';
import 'playing_card.dart';
import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {

  GameScreen gameScreen = GameScreen(seed: -1);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final Controller c = Get.put(Controller());

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0,100,0,100),
                    child: Text(Utilities.applicationName,
                        style: TextStyle(
                            fontSize: 36.0,
                            color: Colors.white
                        ))
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  newGame()
                ]
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  continueGame()
                ]
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    replayGame()
                  ]
              )
            ],
          )
        ]
      )
    );
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      primary: Utilities.buttonBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0)
      )
    );
  }

  TextStyle textStyle() {
    return TextStyle(
        fontSize: 36.0,
        color: Utilities.buttonTextColor
    );
  }

  Widget newGame() {
    return ElevatedButton(
        onPressed: () => Get.to(() => gameScreen),
        child: Text("New Game",
          style: textStyle()
        ),
        style: buttonStyle()
    );
  }

  Widget replayGame() {
    if (gameScreen.seed != -1) {
      return ElevatedButton(
        onPressed: () => Get.to(() => GameScreen(seed: gameScreen.seed)),
        child: Text('Replay',
          style: textStyle()
        ),
        style: buttonStyle()
      );
    } else {
      return Container();
    }
  }

  Widget continueGame() {
    if (GameScreen.currentGameInitialized) {
      return ElevatedButton(
        onPressed: () => Get.back(),
        child: Text("Continue",
          style: textStyle()
        ),
        style: buttonStyle()
      );
    } else {
      return Container();
    }
  }
}