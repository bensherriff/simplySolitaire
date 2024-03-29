import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:solitaire/screens/game.dart';
import 'package:solitaire/screens/klondike.dart';
import 'package:solitaire/utilities.dart';

class CustomSettings extends StatefulWidget {
  final GameStyle style;
  final int seed;

  const CustomSettings({super.key, required this.style, this.seed = 0 });

  @override
  CustomSettingsState createState() => CustomSettingsState();
}

class CustomSettingsState extends State<CustomSettings> {
  late GameStyle style;
  int seed = -1;
  bool validSeed = true;

  @override
  void initState() {
    super.initState();
    style = widget.style;
    seed = widget.seed;
  }

  @override
  Widget build(BuildContext context) {
    KlondikeScreen klondikeScreen = Get.find();
    return Scaffold(
        backgroundColor: style.backgroundColor,
        appBar: AppBar(
          backgroundColor: style.barColor,
          title: Text("Custom Game", style: GoogleFonts.quicksand()),
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                    title: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Seed',
                        hintText: 'A blank seed will start a random game',
                      ),
                      initialValue: seed == -1? '': Utilities.seedToString(seed),
                      onChanged: (value) => _validateSeed(value),
                    )
                ),
                SettingsTile(
                  title: ElevatedButton(
                    style: Utilities.buttonStyle(),
                    onPressed: () {
                      if (valid) {
                        klondikeScreen.newGame(seed: seed);
                      }
                    },
                    child: Text("Start", style: Utilities.buttonTextStyle())
                  )
                )
              ]
            )
          ],
        )
    );
  }

  void _validateSeed(String value) {
    if (value.isEmpty) {
      setState(() {
        validSeed = true;
        seed = -1;
      });
    // } else if (RegExp(r'^#?([0-9a-fA-F]{4}|[0-9a-fA-F]{8})$').hasMatch(value)) {
    } else if (RegExp(r'^#?([0-9a-fA-F]{8})$').hasMatch(value)) {
      setState(() {
        validSeed = true;
        seed = Utilities.stringToSeed(value);
      });
    } else {
      validSeed = false;
    }
  }

  bool get valid => validSeed;
}