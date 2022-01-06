import 'dart:convert';
import 'dart:io';

import 'package:admin/pages/track/track.dart';
import 'package:admin/session/session.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Session session = new Session();

class Repositories {
  var base_url = "https://bd1b-202-80-216-55.ngrok.io";

  Future<void> loginEmployee(
      BuildContext context, var username, var password) async {
    try {
      final body = jsonEncode({
        "username": "${username.toString()}",
        "password": "${password.toString()}"
      });
      final response = await http.post(Uri.parse("$base_url/api/hrd-auth/signin"),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: body);

      final data = jsonDecode(response.body);

      if (data['code'] == 200) {
        session.saveData(username.toString(), "", data['data']['id']);
        if (data['data']['credential']['mobileAccessType'] == "admin") {
          Get.to(TrackingAdmin());
          print(data['data']['id'].toString());
        } 
      } else {
        print("ts${data['message']}");
      }
    } on Exception catch (e) {
      print("error ${e}");
    }
  }
}
