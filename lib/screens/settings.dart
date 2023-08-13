import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solitaire/utilities.dart';

class Settings extends StatefulWidget {
  final String settingsKey;
  final Map<String, bool> settings;
  final int seed;

  const Settings({
    Key? key,
    required this.settingsKey,
    this.settings = const <String, bool>{},
    this.seed = -1
  }) : super(key: key);

  static const String leftHandMode = "Left-Handed Mode";
  static const String hints = "Hints";

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final logger = Logger("SettingsScreenState");
  late HashMap<String, bool> settings;

  @override
  void initState() {
    super.initState();
    settings = Get.put(HashMap(), tag: "${widget.settingsKey}_settings");
    settings.addAll(widget.settings);
    for (MapEntry<String, bool> entry in settings.entries) {
      if (Utilities.hasData(entry.key)) {
        settings[entry.key] = Utilities.readData(entry.key);
      } else {
        Utilities.writeData(entry.key, entry.value).then((value) => {
          settings[entry.key] = Utilities.readData(entry.key)
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: settings.entries.map((setting) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(setting.key, style: GoogleFonts.quicksand()),
                  Switch(
                    value: setting.value,
                    onChanged: (value) => {
                      Utilities.writeData(setting.key, value).then((value) => {
                        setState(() {settings[setting.key] = value;})
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
}