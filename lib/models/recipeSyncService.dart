import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/_models.dart';

class RecipeSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String RECIPE_DATA_KEY = 'recipe_data';
  static const String LAST_SYNC_KEY = 'last_recipe_sync';
  static const int SYNC_INTERVAL_DAYS = 7;

  // 로컬에서 레시피 데이터 로드
  Future<List<Recipe>> loadLocalRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recipeData = prefs.getString(RECIPE_DATA_KEY);

    if (recipeData != null) {
      final List<dynamic> jsonList = json.decode(recipeData);
      return jsonList.map((json) => Recipe.fromJson(json)).toList();
    }
    return [];
  }

  // 로컬에 레시피 데이터 저장
  Future<void> saveLocalRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = json.encode(recipes.map((recipe) => recipe.toJson()).toList());
    await prefs.setString(RECIPE_DATA_KEY, jsonData);
    await prefs.setInt(LAST_SYNC_KEY, DateTime.now().millisecondsSinceEpoch);
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

    if (lastSync == null) return true;

    final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSync);
    final daysSinceLastSync = DateTime.now().difference(lastSyncDate).inDays;

    if (daysSinceLastSync >= SYNC_INTERVAL_DAYS) {
      // 로컬과 Firebase의 레시피 개수 비교
      final localRecipes = await loadLocalRecipes();
      final firebaseRecipeCount = await getFirebaseRecipeCount();

      return localRecipes.length != firebaseRecipeCount;
    }

    return false;
  }

  // Firebase에서 모든 레시피 가져오기
  Future<List<Recipe>> fetchFirebaseRecipes() async {
    final QuerySnapshot snapshot = await _firestore.collection('recipes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Firebase document ID 추가
      data['id'] = doc.id;
      return Recipe.fromJson(data);
    }).toList();
  }

  // 메인 동기화 함수
  Future<List<Recipe>> syncRecipes() async {
    try {
      if (await needsSync()) {
        final recipes = await fetchFirebaseRecipes();
        await saveLocalRecipes(recipes);
        return recipes;
      }
      return await loadLocalRecipes();
    } catch (e) {
      print('Error syncing recipes: $e');
      return await loadLocalRecipes(); // 에러 발생시 로컬 데이터 반환
    }
  }
}