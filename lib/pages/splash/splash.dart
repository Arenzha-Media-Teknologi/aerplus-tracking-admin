import 'dart:async';

import 'package:admin/assets/colors.dart';
import 'package:admin/pages/auth/signin.dart';
import 'package:admin/repositories/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SplassPage extends StatefulWidget {
  @override
  _SplassPageState createState() => _SplassPageState();
}

class _SplassPageState extends State<SplassPage> {
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 4),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => RepositoryProvider(
              create: (context) => AuthRepository(),
              child: AuthPage(),
            ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
              top: Get.mediaQuery.size.height / 2 - 80,
              child: Image.asset(
                "assets/images/logo.png",
                width: Get.mediaQuery.size.width,
                height: 170,
              )),
          Positioned(
            bottom: 20,
            child: Container(
              width: Get.mediaQuery.size.width,
              child: Center(
                  child: Text(
                    "Aerplus - Admin",
                    style: TextStyle(
                        color: baseColor,
                        fontSize: 16,
                        fontFamily: "Roboto-medium",
                        letterSpacing: 0.5),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
