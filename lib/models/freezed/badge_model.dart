import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

@freezed
@HiveType(typeId: 10)
class Badge with _$Badge {
  factory Badge({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String description,
    @HiveField(3) required String imagePath,
    @HiveField(4) required BadgeCategory category,
    @HiveField(5) required BadgeDifficulty difficulty,
    @HiveField(6) required BadgeCondition condition,
    @HiveField(7) @Default(true) bool isDesignComplete, // 디자인 완료 여부
    @HiveField(8) @Default(0) int sortOrder, // 정렬 순서
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

@freezed
@HiveType(typeId: 11)
class BadgeCondition with _$BadgeCondition {
  factory BadgeCondition({
    @HiveField(0) required BadgeType type,
    // 요리 횟수 관련
    @HiveField(1) int? targetCookingCount,
    // 연속 요리 관련
    @HiveField(2) int? consecutiveDays,
    // 난이도 관련
    @HiveField(3) String? difficulty,
    @HiveField(4) int? difficultyCount,
    // 음식 종류 관련
    @HiveField(5) String? recipeType,
    @HiveField(6) int? recipeTypeCount,
    // 시간대 관련
    @HiveField(7) int? timeRangeStart, // 시작 시간 (24시간 기준)
    @HiveField(8) int? timeRangeEnd, // 종료 시간 (24시간 기준)
    @HiveField(9) int? timeBasedCount,
    // 특별 조건
    @HiveField(10) int? wishlistCount, // 위시리스트 개수
    @HiveField(11) int? sameRecipeRetryCount, // 같은 레시피 반복 횟수
  }) = _BadgeCondition;

  factory BadgeCondition.fromJson(Map<String, dynamic> json) => _$BadgeConditionFromJson(json);
}

@HiveType(typeId: 12)
enum BadgeCategory {
  @HiveField(0)
  count('요리 횟수', '🏅', 'count'),

  @HiveField(1)
  continuous('연속 요리', '🔁', 'continuous'),

  @HiveField(2)
  difficulty('난이도', '🎯', 'difficulty'),

  @HiveField(3)
  type('레시피 타입', '🍱', 'type'),

  @HiveField(4)
  time('요리 시간', '⏰', 'time'),

  @HiveField(5)
  special('스페셜', '🌟', 'spec');

  const BadgeCategory(this.displayName, this.icon, this.folderName);
  final String displayName;
  final String icon;
  final String folderName;
}

@HiveType(typeId: 13)
enum BadgeDifficulty {
  @HiveField(0)
  weak('약불', '🔥', Color(0xFF4CAF50)),

  @HiveField(1)
  medium('중불', '🔥🔥', Color(0xFFFF9800)),

  @HiveField(2)
  strong('강불', '🔥🔥🔥', Color(0xFFFF5722)),

  @HiveField(3)
  hell('지옥불', '🔥🔥🔥🔥', Color(0xFF9C27B0));

  const BadgeDifficulty(this.displayName, this.icon, this.color);
  final String displayName;
  final String icon;
  final Color color;
}

@HiveType(typeId: 14)
enum BadgeType {
  @HiveField(0)
  totalCookingCount, // 전체 요리 횟수

  @HiveField(1)
  consecutiveCooking, // 연속 요리

  @HiveField(2)
  difficultyBasedCooking, // 난이도별 요리

  @HiveField(3)
  recipeTypeCooking, // 음식 종류별 요리

  @HiveField(4)
  timeBasedCooking, // 시간대별 요리

  @HiveField(5)
  wishlistCollection, // 위시리스트 수집

  @HiveField(6)
  recipeRetry, // 레시피 재도전
}