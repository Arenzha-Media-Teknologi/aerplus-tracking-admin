import 'dart:convert';

import 'package:admin/models/employee.dart';
import 'package:admin/repositories/api.dart';

import 'package:http/http.dart' as http;


class EmployeeRespository {
  final EMPLOYEE_API_URL = "${base_url}/api/employees";

  Future<EmployeeModel> employee(num id) async {
    var response = await http.get(Uri.parse("$EMPLOYEE_API_URL/${id}"));
    var e = json.decode("${response.body}");

    EmployeeModel employees = EmployeeModel.fromJson(e['data']);
    return employees;
  }

  // Future<List<AttendanceModel>> attendances(var id) async {
  //   var response =
  //   await http.get(Uri.parse("${EMPLOYEE_API_URL}/${id}/attendances"));
  //   final data = jsonDecode(response.body);
  //   List<AttendanceModel> list = AttendanceModel.fromJsonToList(data['data']);
  //   return list;
  // }
  //
  // Future<List<AttendanceModel>> attendancePagination(
  //     var id, var page, start_date, end_date) async {
  //   var response = await http.get(Uri.parse(
  //       "${EMPLOYEE_API_URL}/${id}/attendances?pagination=true&page=1&per_page=2&start_date=${start_date}&end_date=${end_date}"));
  //   final data = jsonDecode(response.body);
  //   List<AttendanceModel> list = AttendanceModel.fromJsonToList(data['data']);
  //   return list;
  // }
  //
  // Future<List<SickModel>> sicks(var id) async {
  //   var response = await http
  //       .get(Uri.parse("${EMPLOYEE_API_URL}/${id}/sick-applications"));
  //   final data = jsonDecode(response.body);
  //   List<SickModel> list = SickModel.fromJsonToList(data['data']);
  //   return list;
  // }
  //
  // Future<List<PermissionModel>> permissions(var id) async {
  //   var response = await http
  //       .get(Uri.parse("${EMPLOYEE_API_URL}/${id}/permission-applications"));
  //   final data = jsonDecode(response.body);
  //   List<PermissionModel> list = PermissionModel.fromJsonToList(data['data']);
  //   return list;
  // }
  //
  // Future<List<LeaveModel>> leaves(var id) async {
  //   var response = await http
  //       .get(Uri.parse("${EMPLOYEE_API_URL}/${id}/leave-applications"));
  //   final data = jsonDecode(response.body);
  //   List<LeaveModel> list = LeaveModel.fromJsonToList(data['data']);
  //   return list;
  // }
  //
  // Future<ActiveLeaveModel> activeLeave(var id) async{
  //   var response = await http
  //       .get(Uri.parse("${EMPLOYEE_API_URL}/${id}/active-leave"));
  //   final data = jsonDecode(response.body);
  //   print("data ${data}");
  //   ActiveLeaveModel activeLeaveModel=ActiveLeaveModel.fromJson(data['data']);
  //   return activeLeaveModel;
  //
  // }


}
