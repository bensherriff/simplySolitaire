import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OptionsScreen extends StatefulWidget {
  OptionsScreen({Key? key}) : super(key: key);

  bool leftHandMode = false;

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
      body: Column(
        children: <Widget>[
          Row(
           children: <Widget>[
             const Padding(
               padding: EdgeInsets.only(left: 28.0, right: 28.0),
               child: Text("Left-handed"),
             ),
             Checkbox(
                 value: widget.leftHandMode,
                 onChanged: (bool? value) {
                   setState(() {
                     widget.leftHandMode = value!;
                   });
                 }
             )
           ],
          )
        ]
      ),
    );
  }
}