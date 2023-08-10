import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solitaire/screens/grid_dashboard.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff392850),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 90,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Simply Solitaire", style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold
                        )
                    )),
                    const SizedBox(height: 4),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            return Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'v${snapshot.data!.version} build ${snapshot.data!.buildNumber}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                              )),
                            );
                          default:
                            return const SizedBox();
                        }
                      },
                    )
                  ]
                ),
                IconButton(
                  alignment: Alignment.center,
                  icon: const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 46),
                  onPressed: () {},
                )
              ],
            )
          ),
          const SizedBox(
            height: 40
          ),
          const GridDashboard()
        ]
      )
    );
  }
}