import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

class OptionsScreen extends StatefulWidget {
  OptionsScreen({Key? key}) : super(key: key);

  bool leftHandMode = false;
  bool drawOne = true;

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
      body: SettingsList(
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
              )
            ]
          )
        ],
      )

    );
  }
}