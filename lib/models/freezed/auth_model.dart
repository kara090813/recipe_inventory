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