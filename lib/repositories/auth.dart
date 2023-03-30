import 'dart:convert';
import 'package:admin/pages/nav.dart';
import 'package:admin/repositories/api.dart';
import 'package:admin/session/session.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class AuthRepository {
  Session session = new Session();

  Future<void> auth(
      {required String username, required String password}) async {
    try {

      final body = jsonEncode({
        "username": "${username.toString()}",
        "password": "${password.toString()}"
      });
      final response = await http.post(
          Uri.parse("$base_url/api/hrd-auth/mobile/signin/admin"),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: body);

      final data = jsonDecode(response.body);
      print("data ${data}");

      if (data['code'] == 200) {
        session.saveData(username.toString(), "", data['data']['id'], true,
            data['data']['name']);


        Get.offAll(Nav());

        // if (data['data']['credential']['mobileAccessType'] == "regular") {
        //   Get.offAll(Nav());
        // } else {
        //   throw "Have no access to this app";
        // }
      } else {
        throw "${data['message']}";
      }
    } on Exception catch (e) {
      throw "${e}";
    }
  }
}
