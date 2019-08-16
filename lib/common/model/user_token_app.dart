import 'package:json_annotation/json_annotation.dart';

part 'user_token_app.g.dart';

@JsonSerializable()
class UserTokenApp {

  String name;

  String url;

  @JsonKey(name: 'client_id')
  String clientId;

  UserTokenApp({this.name, this.url, this.clientId});

  factory UserTokenApp.fromJson(Map<String, dynamic> json) => _$UserTokenAppFromJson(json);

  Map<String, dynamic> toJson() => _$UserTokenAppToJson(this);

}