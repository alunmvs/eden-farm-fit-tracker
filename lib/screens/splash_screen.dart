import 'dart:async';

import 'package:eden_farm_tech_test_hartono/screens/home_screen.dart';
import 'package:eden_farm_tech_test_hartono/screens/sign_in_screen.dart';
import 'package:eden_farm_tech_test_hartono/widgets/slide_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  User? user;
  @override
  void initState() {
    super.initState();
    checkState();
    _controller = AnimationController(vsync: this);
  }

  void checkState() async {
    Timer(Duration(seconds: 3), () {
      user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
            context, SlideToLeftRoute(page: SignInScreen()));
      } else {
        Navigator.pushReplacement(
            context, SlideToLeftRoute(page: HomeScreen()));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Center(
            child: Text(
          'FIT TRACKER\nEDEN FARM',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        )),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Text(
                  'By: Hartono - alunmvs@gmail.com',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
        )
      ],
    ));
  }
}
