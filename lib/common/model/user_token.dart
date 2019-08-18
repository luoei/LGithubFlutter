import 'dart:core';

import 'package:github/common/model/user_token_app.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_token.g.dart';

@JsonSerializable()
class UserToken {

  UserTokenApp app;

  @JsonKey(name: 'hashed_token')
  String hashedToken;

  String note;

  @JsonKey(name: 'note_url')
  dynamic noteUrl;

  @JsonKey(name: 'create_at')
  String updatedAt;

  @JsonKey(name: 'token_last_eight')
  String tokenLastEight;

  dynamic fingerprint;

  @JsonKey(name: 'created_at')
  String createdAt;

  int id;

  List<String> scopes;

  String url;

  String token;

  UserToken({this.app,this.hashedToken, this.note, this.noteUrl, this.updatedAt, this.tokenLastEight, this.fingerprint, this.createdAt, this.id, this.scopes, this.url, this.token});

  factory UserToken.fromJson(Map<String, dynamic> json) => _$UserTokenFromJson(json);

  Map<String, dynamic> toJson() => _$UserTokenToJson(this);

}

