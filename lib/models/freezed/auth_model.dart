// auth_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class UserProfile with _$UserProfile {
  factory UserProfile({
    required String uid,
    required String email,
    required String name,
    String? photoURL,
    required LoginProvider provider,  // AuthProvider -> LoginProvider로 변경
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

// AuthProvider -> LoginProvider로 변경
enum LoginProvider { google, kakao, none }