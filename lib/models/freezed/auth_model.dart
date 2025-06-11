import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
@HiveType(typeId: 5)
class UserProfile with _$UserProfile {
  factory UserProfile({
    @HiveField(0) required String uid,
    @HiveField(1) required String email,
    @HiveField(2) required String name,
    @HiveField(3) String? photoURL,
    @HiveField(4) required LoginProvider provider,
    @HiveField(5) @Default(0) int points,           // 포인트 (상점 화폐)
    @HiveField(6) @Default(0) int experience,       // 총 경험치
    @HiveField(7) @Default(1) int level,            // 현재 레벨
    @HiveField(8) @Default(false) bool isUsingBadgeProfile,  // 뱃지 프로필 사용 여부
    @HiveField(9) String? mainBadgeId,              // 메인 뱃지 ID
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

@HiveType(typeId: 6)
enum LoginProvider {
  @HiveField(0)
  google,
  @HiveField(1)
  kakao,
  @HiveField(2)
  none,
}