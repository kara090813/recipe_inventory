import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_badge_model.freezed.dart';
part 'user_badge_model.g.dart';

@freezed
@HiveType(typeId: 15)
class UserBadgeProgress with _$UserBadgeProgress {
  factory UserBadgeProgress({
    @HiveField(0) required String badgeId,
    @HiveField(1) @Default(0) int currentProgress,
    @HiveField(2) @Default(false) bool isUnlocked,
    @HiveField(3) DateTime? unlockedAt,
    @HiveField(4) @Default(false) bool isMainBadge, // 메인 뱃지로 설정 여부
    @HiveField(5) DateTime? progressUpdatedAt,
    // 추가 메타데이터
    @HiveField(6) @Default({}) Map<String, dynamic> metadata, // 추가 진행도 정보
  }) = _UserBadgeProgress;

  factory UserBadgeProgress.fromJson(Map<String, dynamic> json) => _$UserBadgeProgressFromJson(json);
}

@freezed
@HiveType(typeId: 16)
class BadgeStats with _$BadgeStats {
  factory BadgeStats({
    @HiveField(0) @Default(0) int totalBadges,
    @HiveField(1) @Default(0) int unlockedBadges,
    @HiveField(2) @Default(0) int weakBadges,
    @HiveField(3) @Default(0) int mediumBadges,
    @HiveField(4) @Default(0) int strongBadges,
    @HiveField(5) @Default(0) int hellBadges,
    @HiveField(6) DateTime? lastUpdated,
  }) = _BadgeStats;

  factory BadgeStats.fromJson(Map<String, dynamic> json) => _$BadgeStatsFromJson(json);
}