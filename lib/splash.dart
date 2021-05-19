import 'dart:async';

import 'package:eplaza/awein.dart';
import 'package:eplaza/home.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  /// -----------------------------------------
  /// Initstate and timer for splash screen
  /// -----------------------------------------

  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer(Duration(seconds: 3), () {
      Navigator.push(
        context,
        PageTransition(
          duration: Duration(seconds: 1),
          type: PageTransitionType.rightToLeft,
          child: HomePage(),
        ),
      );
    });
  }

  double _height;
  double _width;
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Container(
      height: _height,
      width: _width,
      color: Color(0xff0c0c0c),
      child: Image.asset(
        'asset/splash.png',
        fit: BoxFit.fitWidth,
      ),
    ));
  }
}
