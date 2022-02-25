import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solitaire/spider.dart';
import 'package:solitaire/utilities.dart';
import 'game_screen.dart';
import 'klondike_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {

  final KlondikeScreen klondikeScreen = Get.put(KlondikeScreen());
  final SpiderScreen spiderScreen = Get.put(SpiderScreen());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return PageView(
      children: <Widget>[
        Container(
          child: gameMenu(klondikeScreen),
        ),
        Container(
          child: gameMenu(spiderScreen),
        ),
      ],
    );
  }

  Scaffold gameMenu(GameScreen gameScreen) {
    return Scaffold(
        backgroundColor: gameScreen.backgroundColor,
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
                            padding: EdgeInsets.fromLTRB(0,100,0,16),
                            child: Text(Utilities.applicationName,
                                style: TextStyle(
                                    fontSize: 46.0,
                                    color: Colors.white
                                ))
                        )
                      ]
                  ),const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text("Created by Benjamin Sherriff",
                          style: TextStyle(
                              color: Utilities.textColor
                          ),)
                      ]
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(gameScreen.gameName,
                          style: TextStyle(
                            fontSize: 36,
                            color: Utilities.textColor
                          ),
                        )
                      ]
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        newGame(gameScreen)
                      ]
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        continueGame(gameScreen)
                      ]
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        replayGame(gameScreen)
                      ]
                  ),
                ],
              )
            ]
        )
    );
  }

  Widget newGame(GameScreen gameScreen) {
    return ElevatedButton(
        onPressed: () => {
          gameScreen.initialized = false,
          gameScreen.seed = -1,
          Get.to(() => gameScreen)
        },
        child: Text("New Game",
          style: textStyle()
        ),
        style: buttonStyle()
    );
  }

  Widget continueGame(GameScreen gameScreen) {
    if (gameScreen.initialized) {
      return ElevatedButton(
        onPressed: () => {
          Get.to(() => gameScreen)
        },
        child: Text("Continue",
            style: textStyle()
        ),
        style: buttonStyle(),
      );
    } else {
      return ElevatedButton(
        onPressed: () {},
        child: const Text(""),
        style: hiddenButtonStyle(gameScreen.backgroundColor),
      );
    }
  }

  Widget replayGame(GameScreen gameScreen) {
    if (gameScreen.initialized && gameScreen.seed != -1) {
      return ElevatedButton(
          onPressed: () => {
            gameScreen.initialized = false,
            Get.to(() => gameScreen)
          },
          child: Text('Replay',
              style: textStyle()
          ),
          style: buttonStyle()
      );
    } else {
      return ElevatedButton(
        onPressed: (){},
        child: const Text(""),
        style: hiddenButtonStyle(gameScreen.backgroundColor),
      );
    }
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
        primary: Utilities.buttonBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0)
        ),
    );
  }

  ButtonStyle hiddenButtonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
        primary: backgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0)
        ),
        elevation: 0.0,
        shadowColor: Colors.transparent
    );
  }

  TextStyle textStyle() {
    return TextStyle(
        fontSize: 36.0,
        color: Utilities.buttonTextColor
    );
  }
}