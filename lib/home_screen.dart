import 'package:animated_background/animated_background.dart' as bg;
import 'package:flutter/material.dart';
import 'package:portfolio/background/space_field.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bg.AnimatedBackground(
        behaviour: SpaceBehaviour(),
        vsync: this,
        key: GlobalKey(),
        child: Center(
          child: Container(
            child: Text("KC"),
          ),
        ),
      ),
    );
  }
}
