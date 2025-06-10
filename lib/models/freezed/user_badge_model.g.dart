// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_badge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserBadgeProgressAdapter extends TypeAdapter<UserBadgeProgress> {
  @override
  final int typeId = 15;

  @override
  UserBadgeProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserBadgeProgress(
      badgeId: fields[0] as String,
      currentProgress: fields[1] as int,
      isUnlocked: fields[2] as bool,
      unlockedAt: fields[3] as DateTime?,
      isMainBadge: fields[4] as bool,
      progressUpdatedAt: fields[5] as DateTime?,
      metadata: (fields[6] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserBadgeProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.badgeId)
      ..writeByte(1)
      ..write(obj.currentProgress)
      ..writeByte(2)
      ..write(obj.isUnlocked)
      ..writeByte(3)
      ..write(obj.unlockedAt)
      ..writeByte(4)
      ..write(obj.isMainBadge)
      ..writeByte(5)
      ..write(obj.progressUpdatedAt)
      ..writeByte(6)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBadgeProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeStatsAdapter extends TypeAdapter<BadgeStats> {
  @override
  final int typeId = 16;

  @override
  BadgeStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeStats(
      totalBadges: fields[0] as int,
      unlockedBadges: fields[1] as int,
      weakBadges: fields[2] as int,
      mediumBadges: fields[3] as int,
      strongBadges: fields[4] as int,
      hellBadges: fields[5] as int,
      lastUpdated: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeStats obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.totalBadges)
      ..writeByte(1)
      ..write(obj.unlockedBadges)
      ..writeByte(2)
      ..write(obj.weakBadges)
      ..writeByte(3)
      ..write(obj.mediumBadges)
      ..writeByte(4)
      ..write(obj.strongBadges)
      ..writeByte(5)
      ..write(obj.hellBadges)
      ..writeByte(6)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserBadgeProgressImpl _$$UserBadgeProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$UserBadgeProgressImpl(
      badgeId: json['badgeId'] as String,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
      isMainBadge: json['isMainBadge'] as bool? ?? false,
      progressUpdatedAt: json['progressUpdatedAt'] == null
          ? null
          : DateTime.parse(json['progressUpdatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$UserBadgeProgressImplToJson(
        _$UserBadgeProgressImpl instance) =>
    <String, dynamic>{
      'badgeId': instance.badgeId,
      'currentProgress': instance.currentProgress,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'isMainBadge': instance.isMainBadge,
      'progressUpdatedAt': instance.progressUpdatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

_$BadgeStatsImpl _$$BadgeStatsImplFromJson(Map<String, dynamic> json) =>
    _$BadgeStatsImpl(
      totalBadges: (json['totalBadges'] as num?)?.toInt() ?? 0,
      unlockedBadges: (json['unlockedBadges'] as num?)?.toInt() ?? 0,
      weakBadges: (json['weakBadges'] as num?)?.toInt() ?? 0,
      mediumBadges: (json['mediumBadges'] as num?)?.toInt() ?? 0,
      strongBadges: (json['strongBadges'] as num?)?.toInt() ?? 0,
      hellBadges: (json['hellBadges'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$BadgeStatsImplToJson(_$BadgeStatsImpl instance) =>
    <String, dynamic>{
      'totalBadges': instance.totalBadges,
      'unlockedBadges': instance.unlockedBadges,
      'weakBadges': instance.weakBadges,
      'mediumBadges': instance.mediumBadges,
      'strongBadges': instance.strongBadges,
      'hellBadges': instance.hellBadges,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
