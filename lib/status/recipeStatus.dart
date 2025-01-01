import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/_models.dart';
import '../models/recipeSyncService.dart';

class RecipeStatus extends ChangeNotifier {
  final RecipeSyncService _syncService = RecipeSyncService();
  List<Recipe> _recipes = [];
  List<Recipe> _recommendedRecipes = [];
  Set<String> _favoriteRecipeIds = {}; // 좋아요 누른 레시피 ID 목록
  bool _isLoading = true;
  String _searchQuery = '';

  static const String FAVORITE_RECIPES_KEY = 'favorite_recipes';

  RecipeStatus() {
    _initializeRecipes();
  }

  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void cacheRecommendedRecipes(List<Recipe> recipes) {
    _recommendedRecipes = recipes;
  }

  List<Recipe> get cachedRecommendedRecipes => _recommendedRecipes;

  // Getters
  List<Recipe> get recipes => _recipes;

  bool get isLoading => _isLoading;

  List<Recipe> get favoriteRecipes =>
      _recipes.where((recipe) => _favoriteRecipeIds.contains(recipe.id)).toList();

  Future<void> _initializeRecipes() async {
    await _loadFavoriteRecipes();
    await refreshRecipes();
  }

  Future<void> refreshRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Syncing recipes...");
      _recipes = await _syncService.syncRecipes();
      print("Synced recipes count: ${_recipes.length}");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading recipes: $e');
      print('Stack trace: ${StackTrace.current}');
      _isLoading = false;
      notifyListeners();
    }
  }
  // 좋아요 상태 불러오기
  Future<void> _loadFavoriteRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteList = prefs.getStringList(FAVORITE_RECIPES_KEY) ?? [];
      _favoriteRecipeIds = Set.from(favoriteList);
      notifyListeners();
    } catch (e) {
      print('Error loading favorite recipes: $e');
    }
  }

  // 좋아요 상태 저장
  Future<void> _saveFavoriteRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(FAVORITE_RECIPES_KEY, _favoriteRecipeIds.toList());
    } catch (e) {
      print('Error saving favorite recipes: $e');
    }
  }

  // 좋아요 토글
  Future<void> toggleFavorite(String recipeId) async {
    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }
    await _saveFavoriteRecipes();
    notifyListeners();
  }

  // 좋아요 상태 확인
  bool isFavorite(String recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }

  Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(FAVORITE_RECIPES_KEY); // SharedPreferences에서 데이터 삭제
      _favoriteRecipeIds.clear(); // Set 초기화
      notifyListeners();
    } catch (e) {
      print('Error clearing favorite recipes: $e');
    }
  }

  // 필터링된 레시피 가져오기
  List<Recipe> getFilteredRecipes({
    String? searchQuery,
    String? recipeType,
    String? difficulty,
    RangeValues? ingredientCount,
  }) {
    print(searchQuery);
    return _recipes.where((recipe) {
      // 검색어 매칭 (제목과 서브타이틀 모두 검색)
      bool matchesSearch = searchQuery == null
          ? true
          : recipe.title.toLowerCase().contains(searchQuery!.toLowerCase()) ||
              recipe.sub_title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              recipe.recipe_tags
                  .any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));

      // 음식 종류 필터링
      bool matchesType = recipeType == null ||
          recipeType == '전체' ||
          recipeType.split(',').contains(recipe.recipe_type);

      // 난이도 필터링
      bool matchesDifficulty = difficulty == null ||
          difficulty == '전체' ||
          difficulty.split(',').contains(recipe.difficulty);

      // 재료 개수 필터링
      bool matchesIngredientCount = ingredientCount == null ||
          (recipe.ingredients_cnt >= ingredientCount.start &&
              recipe.ingredients_cnt <= ingredientCount.end);

      return matchesSearch && matchesType && matchesDifficulty && matchesIngredientCount;
    }).toList();
  }
}
