// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserToken _$UserTokenFromJson(Map<String, dynamic> json) {
  return UserToken(
    app: json['app'] == null
        ? null
        : UserTokenApp.fromJson(json['app'] as Map<String, dynamic>),
    hashedToken: json['hashed_token'] as String,
    note: json['note'] as String,
    noteUrl: json['note_url'],
    updatedAt: json['create_at'] as String,
    tokenLastEight: json['token_last_eight'] as String,
    fingerprint: json['fingerprint'],
    createdAt: json['created_at'] as String,
    id: json['id'] as int,
    scopes: (json['scopes'] as List)?.map((e) => e as String)?.toList(),
    url: json['url'] as String,
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$UserTokenToJson(UserToken instance) => <String, dynamic>{
      'app': instance.app,
      'hashed_token': instance.hashedToken,
      'note': instance.note,
      'note_url': instance.noteUrl,
      'create_at': instance.updatedAt,
      'token_last_eight': instance.tokenLastEight,
      'fingerprint': instance.fingerprint,
      'created_at': instance.createdAt,
      'id': instance.id,
      'scopes': instance.scopes,
      'url': instance.url,
      'token': instance.token,
    };
