// To parse this JSON data, do
//
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  UserData({
    required this.name,
    required this.gender,
    required this.birthday,
    required this.email,
    required this.height,
    this.weight,
  });

  String name;
  String gender;
  DateTime birthday;
  String email;
  int height;
  List<Weight>? weight;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        name: json["name"],
        gender: json["gender"],
        height: json["height"],
        birthday: DateTime.parse(json["birthday"]),
        email: json["email"],
        weight:
            List<Weight>.from(json["weight"].map((x) => Weight.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "gender": gender,
        "height": height,
        "birthday":
            "${birthday.year.toString().padLeft(4, '0')}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}",
        "email": email,
      };
}

class Weight {
  Weight({
    required this.date,
    required this.data,
  });

  DateTime date;
  int data;

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
        date: DateTime.parse(json["date"]),
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "data": data,
      };
}
