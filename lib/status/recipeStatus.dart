import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../models/recipeSyncService.dart';
import '../services/hive_service.dart';
import '_status.dart';

class RecipeStatus extends ChangeNotifier {
  static const int PAGE_SIZE = 10;
  final RecipeSyncService _syncService = RecipeSyncService();
  List<Recipe> _recipes = [];
  List<Recipe> _loadedRecipes = [];
  List<Recipe> _recommendedRecipes = [];
  Set<String> _favoriteRecipeIds = {}; // 좋아요 누른 레시피 ID 목록
  bool _isLoading = true;
  String _searchQuery = '';
  bool _hasMore = true;
  int _currentPage = 0;

  // 퀘스트 업데이트를 위한 콜백 함수
  Future<void> Function()? _questUpdateCallback;

  /// 퀘스트 업데이트 콜백 설정
  void setQuestUpdateCallback(Future<void> Function()? callback) {
    _questUpdateCallback = callback;
    print('RecipeStatus: Quest update callback set');
  }

  /// 퀘스트 업데이트 트리거
  Future<void> _triggerQuestUpdate() async {
    if (_questUpdateCallback != null) {
      try {
        await _questUpdateCallback!();
        print('RecipeStatus: Quest update triggered successfully');
      } catch (e) {
        print('RecipeStatus: Error triggering quest update: $e');
      }
    }
  }

  Recipe getRandomRecommendedRecipe(FoodStatus foodStatus, UserStatus userStatus, int count) {
    // 추천 알고리즘을 사용하여 상위 레시피 가져오기
    final recommendedRecipes = RecipeRecommendationService().getRecommendedRecipes(
      userStatus,
      foodStatus,
      this,
    );

    // 상위 5개 또는 전체 레시피 중 더 작은 숫자 선택
    final maxCount = min(count, recommendedRecipes.length);
    final topRecipes = recommendedRecipes.take(maxCount).toList();

    // 랜덤하게 하나 선택
    final random = Random();
    return topRecipes[random.nextInt(topRecipes.length)];
  }

  List<Recipe> get loadedRecipes => _loadedRecipes;
  bool get hasMore => _hasMore;

  // 레시피 ID로 레시피 찾기
  Recipe? findRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      print('레시피를 찾을 수 없습니다: $id');
      return null;
    }
  }

  Future<List<Recipe>> loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return _loadedRecipes;

    _isLoading = true;
    notifyListeners();

    try {
      final start = _currentPage * PAGE_SIZE;
      final end = start + PAGE_SIZE;

      if (start >= _recipes.length) {
        _hasMore = false;
        _isLoading = false;
        notifyListeners();
        return _loadedRecipes;
      }

      // 지연 시뮬레이션 (실제 API 호출 대체)
      await Future.delayed(Duration(milliseconds: 500));

      final newRecipes = _recipes.sublist(
          start,
          min(end, _recipes.length)
      );

      _loadedRecipes.addAll(newRecipes);
      _currentPage++;

      if (end >= _recipes.length) {
        _hasMore = false;
      }

    } catch (e) {
      print('Error loading recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _loadedRecipes;
  }

  // 필터나 검색 시 페이지네이션 초기화
  void resetPagination() {
    _loadedRecipes.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
    notifyListeners();
  }

  RecipeStatus() {
    _initializeRecipes();
  }

  void shuffleRecipes() {
    final random = Random();

    // 필터된 레시피가 있는 경우
    if (_loadedRecipes.isNotEmpty) {
      _loadedRecipes.shuffle(random);
      notifyListeners();
      return;
    }

    // 전체 레시피 셔플
    _recipes.shuffle(random);
    resetPagination();
    notifyListeners();
  }

  List<Recipe> _currentTabRecipes = [];

  void setCurrentTabRecipes(List<Recipe> recipes) {
    _currentTabRecipes = recipes;
    notifyListeners();
  }

  List<Recipe> get currentTabRecipes => _currentTabRecipes;

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
      shuffleRecipes();
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

  // 좋아요 상태 불러오기 (Hive 사용)
  Future<void> _loadFavoriteRecipes() async {
    try {
      final favoriteList = HiveService.getFavoriteRecipes();
      _favoriteRecipeIds = Set.from(favoriteList);
      notifyListeners();
    } catch (e) {
      print('Error loading favorite recipes from Hive: $e');
    }
  }

  // 좋아요 상태 저장 (Hive 사용)
  Future<void> _saveFavoriteRecipes() async {
    try {
      await HiveService.saveFavoriteRecipes(_favoriteRecipeIds.toList());
    } catch (e) {
      print('Error saving favorite recipes to Hive: $e');
    }
  }

  // ⭐ 수정된 부분: 좋아요 토글 시 퀘스트 업데이트 트리거
  Future<void> toggleFavorite(String recipeId) async {
    try {
      final bool wasAdded;

      if (_favoriteRecipeIds.contains(recipeId)) {
        _favoriteRecipeIds.remove(recipeId);
        await HiveService.removeFavoriteRecipe(recipeId);
        wasAdded = false;
        print('RecipeStatus: Recipe removed from favorites: $recipeId');
      } else {
        _favoriteRecipeIds.add(recipeId);
        await HiveService.addFavoriteRecipe(recipeId);
        wasAdded = true;
        print('RecipeStatus: Recipe added to favorites: $recipeId');
      }

      notifyListeners(); // 좋아요 상태 변경만 알림

      // 좋아요가 추가된 경우에만 퀘스트 업데이트 트리거
      if (wasAdded) {
        // 🎯 퀘스트 진행도 업데이트 트리거
        await _triggerQuestUpdate();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // 좋아요 상태 확인
  bool isFavorite(String recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }

  Future<void> clearAllFavorites() async {
    try {
      await HiveService.clearFavoriteRecipes();
      _favoriteRecipeIds.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing favorite recipes: $e');
    }
  }

  // 필터링된 레시피 가져오기
  List<Recipe> getFilteredRecipes(BuildContext context, {
    String? searchQuery,
    String? recipeType,
    String? difficulty,
    RangeValues? ingredientCount,
    RangeValues? matchRate,
  }) {
    final foodStatus = Provider.of<FoodStatus>(context, listen: false);

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
      bool matchesMatchRate = true;

      if (matchRate != null) {
        final currentMatchRate = foodStatus.calculateMatchRate(recipe.ingredients);
        matchesMatchRate = currentMatchRate >= matchRate.start &&
            currentMatchRate <= matchRate.end;
      }

      return matchesSearch && matchesType && matchesDifficulty &&
          matchesIngredientCount && matchesMatchRate;
    }).toList();
  }
}