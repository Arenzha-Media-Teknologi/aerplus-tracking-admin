import 'dart:convert';

import 'package:admin/models/employee.dart';

class CheckinModel {
  num? id;
  num? employeeId;
  String? dateTime;
  String? latitude;
  String? longitude;
  String? address;
  String? image;
  EmployeeModel? employee;

  CheckinModel(
      {this.id,
      this.employeeId,
      this.dateTime,
      this.latitude,
      this.longitude,
      this.image,
      this.address,
      this.employee});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'datetime': dateTime,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "image": image,
      "employee": employee
    };
  }

  factory CheckinModel.fromJson(Map<String, dynamic> map) {
    return CheckinModel(
        id: map["id"] ?? 0,
        employeeId: map["emmployee_id"] ?? 0,
        latitude: map['latitude'],
        longitude: map['longitude'],
        address: map['address'],
        image: map['image'],
        // map['oemployee'] != null ? OfficeModel.fromJson(map['office']) : null,
        employee: map['employee'] != null
            ? EmployeeModel.fromJson(map['employee'])
            : null,
        dateTime: map['datetime'] ?? "");
  }

  static List<CheckinModel> fromJsonToList(List data) {
    return List<CheckinModel>.from(data.map(
      (item) => CheckinModel.fromJson(item),
    ));
  }

  static String toJson(CheckinModel data) {
    final mapData = data.toMap();
    return json.encode(mapData);
  }
}
