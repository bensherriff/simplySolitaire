import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

class OptionsScreen extends StatefulWidget {
  OptionsScreen({Key? key}) : super(key: key);

  bool leftHandMode = false;
  bool drawOne = true;
  bool hints = false;

  @override
  OptionsScreenState createState() => OptionsScreenState();
}

class OptionsScreenState extends State<OptionsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a9396),
      appBar: AppBar(
       backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Settings"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
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
                  tiles: [
                    SettingsTile.switchTile(
                        title: const Text('Left-Hand Mode'),
                        leading: const Icon(Icons.front_hand),
                        initialValue: widget.leftHandMode,
                        onToggle: (value) {
                          setState(() {
                            widget.leftHandMode = value;
                          });
                        }
                    ),
                    SettingsTile.switchTile(
                        title: const Text('Draw One'),
                        initialValue: widget.drawOne,
                        onToggle: (value) {
                          setState(() {
                            widget.drawOne = value;
                          });
                        }
                    ),
                    SettingsTile.switchTile(
                        title: const Text('Hints'),
                        initialValue: widget.hints,
                        onToggle: (value) {
                          setState(() {
                            widget.hints = value;
                          });
                        }
                    )
                  ]
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, bottom: 6.0),
            child:  FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'v${snapshot.data!.version} build ${snapshot.data!.buildNumber}',
                        style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey
                        ),),
                    );
                  default:
                    return const SizedBox();
                }
              },
            )
          )
        ],
      )
    );
  }
}