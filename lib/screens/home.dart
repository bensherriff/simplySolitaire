import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        backgroundColor: const Color(0xff2a114d),
        bottomOpacity: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Center(
              child: Text("Simply Solitaire", style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w400
              )),
            ),
            Positioned(
              top: 0,
              right: -10,
              child: IconButton(
                padding: const EdgeInsets.only(),
                alignment: Alignment.center,
                icon: const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 38),
                onPressed: () {},
              )
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff2a114d),
              Color(0xff392850),
              Color(0xff2a114d),
            ]
          )
        ),
        child: const Column(
            children: <Widget>[
              SizedBox(height: 40),
              GridDashboard()
            ]
        ),
      )
    );
  }
}