import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/_models.dart';
import '../services/hive_service.dart';

class RecipeSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String LAST_SYNC_KEY = 'last_recipe_sync';
  static const String LAST_RECIPE_DATE_KEY = 'last_recipe_date';
  static const int SYNC_INTERVAL_DAYS = 7;

  // 로컬에서 레시피 데이터 로드 (Hive 사용)
  Future<List<Recipe>> loadLocalRecipes() async {
    try {
      return HiveService.getRecipes();
    } catch (e) {
      print('Error loading local recipes from Hive: $e');
      return [];
    }
  }

  // 로컬에 레시피 데이터 저장 (Hive 사용)
  Future<void> saveLocalRecipes(List<Recipe> recipes) async {
    try {
      await HiveService.saveRecipes(recipes);

      // 동기화 시간과 최신 레시피 날짜는 여전히 SharedPreferences 사용 (가벼운 메타데이터)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(LAST_SYNC_KEY, DateTime.now().millisecondsSinceEpoch);

      // 가장 최신 레시피의 createdAt 값을 저장
      if (recipes.isNotEmpty) {
        String latestDate = recipes
            .map((r) => r.createdAt)
            .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
        await prefs.setString(LAST_RECIPE_DATE_KEY, latestDate);
      }
    } catch (e) {
      print('Error saving local recipes to Hive: $e');
    }
  }

  // Firebase에서 레시피 개수 가져오기
  Future<int> getFirebaseRecipeCount() async {
    final AggregateQuerySnapshot snapshot = await _firestore
        .collection('recipes')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // 동기화가 필요한지 확인
  Future<bool> needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastSync = prefs.getInt(LAST_SYNC_KEY);

    final localRecipes = await loadLocalRecipes();
    // 로컬에 레시피가 하나도 없다면, lastSync 여부와 관계없이 무조건 동기화
    if (localRecipes.isEmpty) {
      return true;
    }

    if (lastSync == null) {
      return true;
    }

    final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSync);
    final daysSinceLastSync = DateTime.now().difference(lastSyncDate).inDays;
    if (daysSinceLastSync >= SYNC_INTERVAL_DAYS) {
      final firebaseRecipeCount = await getFirebaseRecipeCount();
      return localRecipes.length != firebaseRecipeCount;
    }

    return false;
  }

  // 새 레시피 확인 및 가져오기
  Future<List<Recipe>> fetchNewRecipes(String lastDate) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('recipes')
          .where('createdAt', isGreaterThan: lastDate)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Timestamp를 String으로 변환
        if (data['createdAt'] is Timestamp) {
          final timestamp = data['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          // YYYYMMDDHHmmss 형식으로 변환
          data['createdAt'] = date.year.toString() +
              date.month.toString().padLeft(2, '0') +
              date.day.toString().padLeft(2, '0') +
              date.hour.toString().padLeft(2, '0') +
              date.minute.toString().padLeft(2, '0') +
              date.second.toString().padLeft(2, '0');
        }

        return Recipe.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching new recipes: $e');
      return [];
    }
  }

  // Firebase에서 모든 레시피 가져오기
  Future<List<Recipe>> fetchFirebaseRecipes() async {
    final QuerySnapshot snapshot = await _firestore.collection('recipes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Firebase document ID 추가
      data['id'] = doc.id;

      // Timestamp를 String으로 변환
      if (data['createdAt'] is Timestamp) {
        final timestamp = data['createdAt'] as Timestamp;
        final date = timestamp.toDate();
        // YYYYMMDDHHmmss 형식으로 변환
        data['createdAt'] = date.year.toString() +
            date.month.toString().padLeft(2, '0') +
            date.day.toString().padLeft(2, '0') +
            date.hour.toString().padLeft(2, '0') +
            date.minute.toString().padLeft(2, '0') +
            date.second.toString().padLeft(2, '0');
      } else if (data['createdAt'] == null) {
        // createdAt이 없는 경우 기본값 설정
        data['createdAt'] = "20240204000000";
      }

      return Recipe.fromJson(data);
    }).toList();
  }

  // 메인 동기화 함수
  Future<List<Recipe>> syncRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (await needsSync()) {
        // 전체 동기화 필요
        final recipes = await fetchFirebaseRecipes();
        if (recipes.isNotEmpty) {
          await saveLocalRecipes(recipes);
        }
        return recipes;
      } else {
        // 증분 동기화 시도
        final localRecipes = await loadLocalRecipes();
        final lastDate = prefs.getString(LAST_RECIPE_DATE_KEY) ?? "20240204000000";
        final newRecipes = await fetchNewRecipes(lastDate);

        if (newRecipes.isNotEmpty) {
          // 중복 방지를 위해 ID 기준으로 새 레시피만 추가
          final existingIds = localRecipes.map((r) => r.id).toSet();
          final uniqueNewRecipes = newRecipes.where((r) => !existingIds.contains(r.id)).toList();

          if (uniqueNewRecipes.isNotEmpty) {
            final mergedRecipes = [...localRecipes, ...uniqueNewRecipes];
            await saveLocalRecipes(mergedRecipes);
            return mergedRecipes;
          }
        }

        return localRecipes;
      }
    } catch (e) {
      print('Error syncing recipes: $e');
      print('Stack trace: ${StackTrace.current}');
      return await loadLocalRecipes(); // 에러 발생시 로컬 데이터 반환
    }
  }
}