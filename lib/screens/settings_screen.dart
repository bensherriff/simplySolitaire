import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:solitaire/utilities.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final logger = Logger("SettingsScreenState");
  bool leftHandMode = false;
  bool dealThree = false;
  bool hints = false;

  @override
  void initState() {
    super.initState();
    if (Utilities.hasData('leftHandMode')) {
      leftHandMode = Utilities.readData('leftHandMode');
    } else {
      Utilities.writeData('leftHandMode', leftHandMode).then((value) => logger.fine("Set leftHandMode to $leftHandMode"));
    }
    if (Utilities.hasData('dealThree')) {
      dealThree = Utilities.readData('dealThree');
    } else {
      Utilities.writeData('dealThree', dealThree).then((value) => logger.fine("Set dealThree to $dealThree"));
    }
    if (Utilities.hasData('hints')) {
      hints = Utilities.readData('hints');
    } else {
      Utilities.writeData('hints', hints).then((value) => logger.fine("Set hints to $hints"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff392850),
      appBar: AppBar(
       backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Settings"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.undo,
              color: Colors.white
            ),
            onPressed: () {
              Get.back();
            },
          )
        ],
        automaticallyImplyLeading: false
      ),
      body: Stack(
        children: [
          SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Play Modes'),
                tiles: [
                  SettingsTile.switchTile(
                    title: const Text('Left-Handed Mode'),
                    initialValue: leftHandMode,
                    onToggle: (value) {
                      Utilities.writeData('leftHandMode', value).then((value) => setState(() {
                        leftHandMode = value;
                      }));

                    }
                  ),
                  SettingsTile.switchTile(
                    title: const Text('Deal Three Cards'),
                    initialValue: dealThree,
                    onToggle: (value) {
                      Utilities.writeData('dealThree', value).then((value) => setState(() {
                        dealThree = value;
                      }));
                    }
                  ),
                  SettingsTile.switchTile(
                    title: const Text('Hints'),
                    initialValue: hints,
                    onToggle: (value) {
                      Utilities.writeData('hints', value).then((value) => setState(() {
                        hints = value;
                      }));
                    }
                  )
                ]
              )
            ],
          ),
        ],
      )
    );
  }
}