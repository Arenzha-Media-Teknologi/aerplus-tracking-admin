import 'package:shared_preferences/shared_preferences.dart';

class Session{

  void  saveData(var username,email,employee_id) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('employee_id', employee_id);
    sharedPreferences.setBool('isTrack',false);
    sharedPreferences.setString('username', username);
    sharedPreferences.setString("email", email);

  }

}