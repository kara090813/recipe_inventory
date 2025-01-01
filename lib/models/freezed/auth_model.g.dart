// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoURL: json['photoURL'] as String?,
      provider: $enumDecode(_$LoginProviderEnumMap, json['provider']),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'photoURL': instance.photoURL,
      'provider': _$LoginProviderEnumMap[instance.provider]!,
    };

const _$LoginProviderEnumMap = {
  LoginProvider.google: 'google',
  LoginProvider.kakao: 'kakao',
  LoginProvider.none: 'none',
};
