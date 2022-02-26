import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({Key? key}) : super(key: key);

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
      extendBodyBehindAppBar: true,
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
      )
    );
  }
}