import 'dart:convert';

class AttendancesModel {
  num? id;
  String? name;
  String? number;

  AttendancesModel({this.name, this.number, this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
    };
  }

  factory AttendancesModel.fromJson(Map<String, dynamic> map) {
    return AttendancesModel(
        id: map["id"] ?? -1,
        name: map["name"] ?? "",
        number: map['number'] ?? "");
  }

  static List<AttendancesModel> fromJsonToList(List data) {
    return List<AttendancesModel>.from(data.map(
      (item) => AttendancesModel.fromJson(item),
    ));
  }

  static String toJson(AttendancesModel data) {
    final mapData = data.toMap();
    return json.encode(mapData);
  }
}
