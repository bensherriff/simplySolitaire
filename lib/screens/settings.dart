import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: Text("Settings", style: GoogleFonts.quicksand()),
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
                title: Text('Play Modes', style: GoogleFonts.quicksand()),
                tiles: [
                  SettingsTile.switchTile(
                    title: Text('Left-Handed Mode', style: GoogleFonts.quicksand()),
                    initialValue: leftHandMode,
                    onToggle: (value) {
                      Utilities.writeData('leftHandMode', value).then((value) => setState(() {
                        leftHandMode = value;
                      }));

                    }
                  ),
                  SettingsTile.switchTile(
                    title: Text('Deal Three Cards', style: GoogleFonts.quicksand()),
                    initialValue: dealThree,
                    onToggle: (value) {
                      Utilities.writeData('dealThree', value).then((value) => setState(() {
                        dealThree = value;
                      }));
                    }
                  ),
                  SettingsTile.switchTile(
                    title: Text('Hints', style: GoogleFonts.quicksand()),
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
        ],
      )
    );
  }
}