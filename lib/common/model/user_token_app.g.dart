// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token_app.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTokenApp _$UserTokenAppFromJson(Map<String, dynamic> json) {
  return UserTokenApp(
    name: json['name'] as String,
    url: json['url'] as String,
    clientId: json['client_id'] as String,
  );
}

Map<String, dynamic> _$UserTokenAppToJson(UserTokenApp instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'client_id': instance.clientId,
    };
