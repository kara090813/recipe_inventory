// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 5;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      uid: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      photoURL: fields[3] as String?,
      provider: fields[4] as LoginProvider,
      points: fields[5] as int,
      experience: fields[6] as int,
      level: fields[7] as int,
      isUsingBadgeProfile: fields[8] != null ? fields[8] as bool : false,
      mainBadgeId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.photoURL)
      ..writeByte(4)
      ..write(obj.provider)
      ..writeByte(5)
      ..write(obj.points)
      ..writeByte(6)
      ..write(obj.experience)
      ..writeByte(7)
      ..write(obj.level)
      ..writeByte(8)
      ..write(obj.isUsingBadgeProfile)
      ..writeByte(9)
      ..write(obj.mainBadgeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoginProviderAdapter extends TypeAdapter<LoginProvider> {
  @override
  final int typeId = 6;

  @override
  LoginProvider read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoginProvider.google;
      case 1:
        return LoginProvider.kakao;
      case 2:
        return LoginProvider.none;
      default:
        return LoginProvider.google;
    }
  }

  @override
  void write(BinaryWriter writer, LoginProvider obj) {
    switch (obj) {
      case LoginProvider.google:
        writer.writeByte(0);
        break;
      case LoginProvider.kakao:
        writer.writeByte(1);
        break;
      case LoginProvider.none:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      points: (json['points'] as num?)?.toInt() ?? 0,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      isUsingBadgeProfile: json['isUsingBadgeProfile'] as bool? ?? false,
      mainBadgeId: json['mainBadgeId'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'photoURL': instance.photoURL,
      'provider': _$LoginProviderEnumMap[instance.provider]!,
      'points': instance.points,
      'experience': instance.experience,
      'level': instance.level,
      'isUsingBadgeProfile': instance.isUsingBadgeProfile,
      'mainBadgeId': instance.mainBadgeId,
    };

const _$LoginProviderEnumMap = {
  LoginProvider.google: 'google',
  LoginProvider.kakao: 'kakao',
  LoginProvider.none: 'none',
};
