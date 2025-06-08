import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import 'hive_service.dart';

class MigrationService {
  static const String MIGRATION_COMPLETED_KEY = 'hive_migration_completed';
  static const String USER_PROFILE_MIGRATION_KEY = 'user_profile_migration_v2';

  static Future<void> migrateToHive() async {
    final prefs = await SharedPreferences.getInstance();

    // 이미 마이그레이션이 완료된 경우 스킵
    if (prefs.getBool(MIGRATION_COMPLETED_KEY) ?? false) {
      print('Hive 마이그레이션이 이미 완료됨');

      // UserProfile 추가 필드 마이그레이션 체크
      await _migrateUserProfileFields(prefs);
      return;
    }

    print('SharedPreferences에서 Hive로 데이터 마이그레이션 시작...');

    try {
      // 1. Recipe 데이터 마이그레이션
      await _migrateRecipes(prefs);

      // 2. Food 데이터 마이그레이션
      await _migrateFoods(prefs);

      // 3. CookingHistory 마이그레이션
      await _migrateCookingHistory(prefs);

      // 4. OngoingCooking 마이그레이션
      await _migrateOngoingCooking(prefs);

      // 5. UserProfile 마이그레이션
      await _migrateUserProfile(prefs);

      // 6. FavoriteRecipes 마이그레이션
      await _migrateFavoriteRecipes(prefs);

      // 마이그레이션 완료 표시
      await prefs.setBool(MIGRATION_COMPLETED_KEY, true);
      print('Hive 마이그레이션 완료');

    } catch (e) {
      print('마이그레이션 중 오류 발생: $e');
      // 마이그레이션 실패시에도 계속 진행하도록 함
    }
  }

  /// UserProfile에 새로 추가된 필드들(points, experience, level) 마이그레이션
  static Future<void> _migrateUserProfileFields(SharedPreferences prefs) async {
    try {
      // 이미 필드 마이그레이션이 완료된 경우 스킵
      if (prefs.getBool(USER_PROFILE_MIGRATION_KEY) ?? false) {
        return;
      }

      print('UserProfile 필드 마이그레이션 시작...');

      final userProfile = HiveService.getUserProfile();
      if (userProfile != null) {
        // 기존 UserProfile에 새 필드가 없는 경우 기본값으로 업데이트
        final updatedProfile = userProfile.copyWith(
          points: userProfile.points, // 이미 있으면 유지, 없으면 기본값(0) 적용
          experience: userProfile.experience, // 이미 있으면 유지, 없으면 기본값(0) 적용
          level: userProfile.level, // 이미 있으면 유지, 없으면 기본값(1) 적용
        );

        await HiveService.saveUserProfile(updatedProfile);
        print('UserProfile 필드 마이그레이션 완료');
      }

      await prefs.setBool(USER_PROFILE_MIGRATION_KEY, true);
    } catch (e) {
      print('UserProfile 필드 마이그레이션 오류: $e');
    }
  }

  static Future<void> _migrateRecipes(SharedPreferences prefs) async {
    try {
      final String? recipeData = prefs.getString('recipe_data');
      if (recipeData != null) {
        final List<dynamic> jsonList = json.decode(recipeData);
        final recipes = jsonList.map((json) {
          // createdAt이 없는 경우 기본값 설정
          if (!json.containsKey('createdAt')) {
            json['createdAt'] = "20240204000000";
          }
          return Recipe.fromJson(json);
        }).toList();

        await HiveService.saveRecipes(recipes);
        print('레시피 데이터 마이그레이션 완료: ${recipes.length}개');
      }
    } catch (e) {
      print('레시피 마이그레이션 오류: $e');
    }
  }

  static Future<void> _migrateFoods(SharedPreferences prefs) async {
    try {
      final String? foodListString = prefs.getString('foodList');
      if (foodListString != null) {
        final List<dynamic> jsonList = json.decode(foodListString);
        final foods = jsonList.map((jsonItem) =>
            Food.fromJson(jsonItem as Map<String, dynamic>)
        ).toList();

        await HiveService.saveFoods(foods);
        print('식재료 데이터 마이그레이션 완료: ${foods.length}개');
      }
    } catch (e) {
      print('식재료 마이그레이션 오류: $e');
    }
  }

  static Future<void> _migrateCookingHistory(SharedPreferences prefs) async {
    try {
      final String? historyJson = prefs.getString('cookingHistory');
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        final history = historyList.map((item) {
          // 기존 데이터 구조를 새로운 구조로 변환
          return CookingHistory(
            recipe: Recipe.fromJson(item['recipe']),
            dateTime: DateTime.parse(item['dateTime']),
          );
        }).toList();

        await HiveService.saveCookingHistory(history);
        print('요리 히스토리 마이그레이션 완료: ${history.length}개');
      }
    } catch (e) {
      print('요리 히스토리 마이그레이션 오류: $e');
    }
  }

  static Future<void> _migrateOngoingCooking(SharedPreferences prefs) async {
    try {
      final String? ongoingJson = prefs.getString('ongoingCooking');
      if (ongoingJson != null) {
        final List<dynamic> ongoingList = json.decode(ongoingJson);
        final ongoing = ongoingList.map((item) {
          return OngoingCooking(
            recipe: Recipe.fromJson(item['recipe']),
            startTime: DateTime.parse(item['startTime']),
          );
        }).toList();

        await HiveService.saveOngoingCooking(ongoing);
        print('진행 중인 요리 마이그레이션 완료: ${ongoing.length}개');
      }
    } catch (e) {
      print('진행 중인 요리 마이그레이션 오류: $e');
    }
  }

  static Future<void> _migrateUserProfile(SharedPreferences prefs) async {
    try {
      final String? userProfileJson = prefs.getString('userProfile');
      if (userProfileJson != null) {
        final Map<String, dynamic> profileData = json.decode(userProfileJson);

        // 새로 추가된 필드들에 기본값 설정
        if (!profileData.containsKey('points')) {
          profileData['points'] = 0;
        }
        if (!profileData.containsKey('experience')) {
          profileData['experience'] = 0;
        }
        if (!profileData.containsKey('level')) {
          profileData['level'] = 1;
        }

        final userProfile = UserProfile.fromJson(profileData);
        await HiveService.saveUserProfile(userProfile);
        print('사용자 프로필 마이그레이션 완료');
      }
    } catch (e) {
      print('사용자 프로필 마이그레이션 오류: $e');
    }
  }

  static Future<void> _migrateFavoriteRecipes(SharedPreferences prefs) async {
    try {
      final List<String>? favoriteList = prefs.getStringList('favorite_recipes');
      if (favoriteList != null) {
        await HiveService.saveFavoriteRecipes(favoriteList);
        print('좋아요 레시피 마이그레이션 완료: ${favoriteList.length}개');
      }
    } catch (e) {
      print('좋아요 레시피 마이그레이션 오류: $e');
    }
  }


  // 마이그레이션 후 SharedPreferences 정리 (선택사항)
  static Future<void> cleanupSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // 마이그레이션된 데이터 삭제
      await prefs.remove('recipe_data');
      await prefs.remove('foodList');
      await prefs.remove('cookingHistory');
      await prefs.remove('ongoingCooking');
      await prefs.remove('userProfile');
      await prefs.remove('favorite_recipes');

      print('SharedPreferences 정리 완료');
    } catch (e) {
      print('SharedPreferences 정리 오류: $e');
    }
  }
}