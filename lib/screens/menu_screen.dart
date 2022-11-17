import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solitaire/screens/options_screen.dart';
import 'package:solitaire/screens/spider_screen.dart';
import 'package:solitaire/utilities.dart';
import 'game_screen.dart';
import 'klondike_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  final OptionsScreen _optionsScreen = Get.put(OptionsScreen());
  final KlondikeScreen _klondikeScreen = Get.put(KlondikeScreen());
  final SpiderScreen _spiderScreen = Get.put(SpiderScreen());

  final PageController _pageController = PageController(initialPage: 0);
  List<Widget> _pages = [];
  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    _pages.add(_klondikeScreen);
    _pages.add(_spiderScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white
            ),
            onPressed: () {
              Get.to(() => _optionsScreen);
            },
          )
        ],
        automaticallyImplyLeading: false
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _activePage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (BuildContext context, int index) {
              return gameMenu(_pages[index % _pages.length] as GameScreen);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 30,
            child: Container(
              color: Colors.black54,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _pages.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    onTap: () {
                      _pageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                    child: CircleAvatar(
                      radius: 8,
                      // check if a dot is connected to the current page
                      // if true, give it a different color
                      backgroundColor: _activePage == index
                          ? Colors.grey
                          : Colors.black12,
                    ),
                  ),
                )),
              ),
            ),
          )
        ]
      )
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
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,100,0,16),
                    child: Text(gameScreen.gameMode.toShortString(),
                        style: const TextStyle(
                            fontSize: 46.0,
                            color: Colors.white
                        )
                    )
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: newGame(gameScreen)
                  )
                ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                        child: continueGame(gameScreen)
                    )
                  ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                        child: replayGame(gameScreen)
                    )
                  ]
              )
            ],
          )
        ]
      )
    );
  }

  Widget newGame(GameScreen gameScreen) {
    return ElevatedButton(
        onPressed: () => {
          gameScreen.timer.resetTimer(),
          gameScreen.initialized = false,
          gameScreen.seed = -1,
          Get.to(() => gameScreen)
        },
        style: buttonStyle(),
        child: Text("New Game",
          style: textStyle()
        )
    );
  }

  Widget continueGame(GameScreen gameScreen) {
    if (gameScreen.initialized) {
      return ElevatedButton(
        onPressed: () => {
          Get.to(() => gameScreen)
        },
        style: buttonStyle(),
        child: Text("Continue",
            style: textStyle()
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () {},
        style: hiddenButtonStyle(gameScreen.backgroundColor),
        child: const Text(""),
      );
    }
  }

  Widget replayGame(GameScreen gameScreen) {
    if (gameScreen.initialized && gameScreen.seed != -1) {
      return ElevatedButton(
          onPressed: () => {
            gameScreen.timer.resetTimer(),
            gameScreen.initialized = false,
            Get.to(() => gameScreen)
          },
          style: buttonStyle(),
          child: Text('Replay',
              style: textStyle()
          )
      );
    } else {
      return ElevatedButton(
        onPressed: (){},
        style: hiddenButtonStyle(gameScreen.backgroundColor),
        child: const Text(""),
      );
    }
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
        backgroundColor: Utilities.buttonBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0)
        ),
    );
  }

  ButtonStyle hiddenButtonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
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