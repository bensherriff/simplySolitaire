import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solitaire/screens/game_screen.dart';
import 'package:solitaire/screens/klondike_screen.dart';
import 'package:solitaire/screens/settings_screen.dart';
import 'package:solitaire/screens/spider_screen.dart';

class GridDashboard extends StatefulWidget {
  const GridDashboard({Key? key}): super(key: key);

  @override
  GridDashboardState createState() => GridDashboardState();
}

class GridDashboardState extends State<GridDashboard> {
  final List<MenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    KlondikeScreen klondikeScreen = Get.put(KlondikeScreen());
    SpiderScreen spiderScreen = Get.put(SpiderScreen());
    SettingsScreen optionsScreen = Get.put(const SettingsScreen());

    menuItems.add(MenuItem(
      title: "Klondike",
      subtitle: gameSeedSubtitle(klondikeScreen),
      // backgroundColor: const Color(0xFF357960),
      image: "assets/cards/spades.png",
      screen: klondikeScreen
    ));
    menuItems.add(MenuItem(
      title: "Spider",
      subtitle: "Coming Soon!",
      // backgroundColor: const Color(0xFF0a9396),
      image: "assets/cards/diamonds.png",
        screen: spiderScreen,
      disabled: true
    ));
    menuItems.add(MenuItem(
      title: "FreeCell",
      subtitle: "Coming Soon!",
      // backgroundColor: const Color(0xFF357960),
      image: "assets/cards/hearts.png",
      screen: spiderScreen,
      disabled: true
    ));
    menuItems.add(MenuItem(
      title: "Pyramid",
      subtitle: "Coming Soon!",
      // backgroundColor: const Color(0xFF0a9396),
      image: "assets/cards/clubs.png",
      screen: spiderScreen,
      disabled: true
    ));
    menuItems.add(MenuItem(
      title: "TriPeaks",
      subtitle: "Coming Soon!",
      // backgroundColor: const Color(0xFF357960),
      image: "assets/cards/spades.png",
      screen: spiderScreen,
      disabled: true
    ));
    menuItems.add(MenuItem(
      title: "Settings",
      backgroundColor: const Color(0xFF6e6e6e),
      image: "assets/gear.png",
      screen: optionsScreen
    ));
  }

  String gameSeedSubtitle(GameScreen gameScreen) {
    if (gameScreen.initialized && gameScreen.seed != -1) {
      return gameScreen.seed.toRadixString(16);
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GridView.count(
        childAspectRatio: 1.0,
        crossAxisCount: 2,
        padding: const EdgeInsets.only(left: 16, right: 16),
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        children: menuItems.map((menuItem) {
          return Container(
            decoration: BoxDecoration(
              color: menuItem.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3)
                )
              ]
            ),
            child: MaterialButton(
              disabledColor: Colors.black54,
              disabledTextColor: Colors.black54,
              disabledElevation: 0,
              onPressed: menuItem.disabled? null: menuItem.screen is GameScreen? () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert(menuItem.screen as GameScreen);
                  }
                );
              }: () {
                Get.to(() => menuItem.screen);
              },
              child: menuItem.title.isNotEmpty || menuItem.subtitle.isNotEmpty? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    menuItem.image,
                    width: 42,
                  ),
                  const SizedBox(height: 8),
                  Text(menuItem.title, style: GoogleFonts.quicksand(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600
                      )
                  )),
                  const SizedBox(height: 8),
                  Text(menuItem.subtitle, style: GoogleFonts.quicksand(
                      textStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      )
                  )),
                ],
              ): Center(
                child: Image.asset(
                  menuItem.image,
                  width: 100,
                ),
              ),
            ),
          );
        }).toList(),
      )
    );
  }
}

Widget alert(GameScreen gameScreen) {
  return AlertDialog(
    backgroundColor: Colors.transparent,
    content: Container(
      constraints: BoxConstraints(
        minHeight: 5,
        maxHeight: gameScreen.initialized? 220 : 100
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          continueGameButton(gameScreen),
          const SizedBox(height: 20),
          newGameButton(gameScreen),
          const SizedBox(height: 20),
          restartGameButton(gameScreen)
        ],
      )
    )
  );
}

Widget newGameButton(GameScreen gameScreen) {
  return ElevatedButton(
    onPressed: () => gameScreen.newGame(),
    style: buttonStyle(),
    child: Text("New Game", style: buttonTextStyle())
  );
}

Widget continueGameButton(GameScreen gameScreen) {
  if (gameScreen.initialized) {
    return ElevatedButton(
      onPressed: () => Get.to(() => gameScreen),
      style: buttonStyle(),
      child: Text("Continue", style: buttonTextStyle()),
    );
  } else {
    return const SizedBox();
  }
}

Widget restartGameButton(GameScreen gameScreen) {
  if (gameScreen.initialized && gameScreen.seed != -1) {
    return ElevatedButton(
        onPressed: () => gameScreen.restartGame(),
        style: buttonStyle(),
        child: Text('Restart', style: buttonTextStyle())
    );
  } else {
    return const SizedBox();
  }
}

TextStyle buttonTextStyle() {
  return GoogleFonts.quicksand(
    textStyle: const TextStyle(
      color: Colors.white,
      fontSize: 38,
      fontWeight: FontWeight.w400
    )
  );
}

ButtonStyle buttonStyle() {
  return ElevatedButton.styleFrom(
    minimumSize: const Size(230, 60),
    backgroundColor: const Color(0xFF55688a),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0)
    ),
  );
}

class MenuItem {
  String title;
  String subtitle;
  Color backgroundColor;
  String image;
  StatefulWidget screen;
  bool disabled;

  MenuItem({
    this.title = '',
    this.subtitle = '',
    this.backgroundColor = const Color(0xFF55688a),
    required this.image,
    required this.screen,
    this.disabled = false,
  });
}
