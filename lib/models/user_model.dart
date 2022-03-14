import 'dart:convert';

class UserModel {
  final String user;
  final String password;
  final List modelData;
  UserModel({
    required this.user,
    required this.password,
    required this.modelData,
  });

  UserModel.fromJson(Map<String, dynamic> parsedJson)
      : user = parsedJson['user'],
        password = parsedJson['password'],
        modelData = parsedJson['modelData'];

  Map<String, dynamic> toMap() => <String, dynamic>{
        'user': user,
        'password': password,
        'modelData': json.encode(modelData)
      };
}
